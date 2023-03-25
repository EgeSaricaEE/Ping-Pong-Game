----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:26:24 06/29/2021 
-- Design Name: 
-- Module Name:    Sync - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.Constants.all;

entity Sync is
  Port (clock, bottomleft, bottomright, upperleft, upperright, start: in std_logic;     
        hSync, vSync: out std_logic;
        r, g: out std_logic_vector(2 downto 0);
		  b: out std_logic_vector(1 downto 0));        
end Sync;

architecture Behavioral of Sync is
--Defitions of the bitmaps for different images, they will be stored in the ROM 

--Synchronization Signals
signal hPosCurrent, hPosNext: integer range 1 to TOT_H;
signal vPosCurrent, vPosNext: integer range 1 to TOT_V;
--RGB Signals
signal rgbCurrent, rgbNext: std_logic_vector(7 downto 0);
--Intermediate Signals 
signal bottompaddleVisible, ballVisible, frameVisible, upperpaddleVisible, borderVisible: boolean;
signal bottompaddleCursor, upperpaddleCursor: integer range (FP_H + SP_H + BP_H + 1) to (TOT_H - PADDLE_WIDTH):= FP_H + SP_H + BP_H + VIS_H / 2 - (PADDLE_WIDTH + 1) / 2;
signal bottompaddleLeft, bottompaddleRight, upperpaddleLeft, upperpaddleRight: integer range 0 to PRESCALER_PADDLE:= 0;
signal ballCursorX: integer range (FP_H + SP_H + BP_H + 1) to (TOT_H - BALL_SIDE);
signal ballCursorY: integer range (FP_V + SP_V + BP_V + 1) to (TOT_V - BALL_SIDE);
signal ballMovementCounter: integer:= 0;
signal ballMovement: std_logic:= '0';
signal playing: std_logic;
signal newGame, player1wins, player2wins: std_logic;
signal paddleWidth: integer:= PADDLE_WIDTH; 
--Component that provides information about the balls position and game logic
component BallController is
    Port (start, move: in std_logic;
          paddleWidth: in integer;
          bottompaddlePos, upperpaddlePos: in integer range TOT_H - VIS_H + 1 to TOT_H - PADDLE_WIDTH;
          xPos: out integer range TOT_H - VIS_H + 1 to TOT_H - BALL_SIDE;
          yPos: out integer range TOT_V - VIS_V + 1 to TOT_V;
          newGame, play, player1won, player2won: out std_logic);
end component;
begin
    ballControl: BallController 
        port map (start => start,
                  move => ballMovement, 
                  paddleWidth => paddleWidth,
                  bottompaddlePos => bottompaddleCursor, 
                  upperpaddlePos => upperpaddleCursor,
                  xPos => ballCursorX,
                  yPos => ballCursorY,
                  newGame => newGame, 
                  play =>  playing,
                  player1won => player1wins,
                  player2won => player2wins);
    --The process involves the next state logic for the variables
    process(clock)
    begin 
        if clock'event and clock = '1' then
        --Producing the clock signal that will occur in the BallController module
            if ballMovementCounter = PRESCALER_BALL then
                ballMovement <= not ballMovement;
                ballMovementCounter <= 0;
            else 
                ballMovementCounter <= ballMovementCounter + 1;
            end if;
            --Button - bottom paddle control
            if playing = '1' then
                if bottomright = '1' and bottomleft = '0' then
                    bottompaddleRight <= bottompaddleRight + 1;
                    bottompaddleLeft <= 0;
                elsif bottomleft = '1' and bottomright = '0' then
                    bottompaddleLeft <= bottompaddleLeft + 1;
                    bottompaddleRight <= 0;
                else 
                    bottompaddleRight <= 0;
                    bottompaddleLeft <= 0;
                end if;
                --Adjusting the position of the player's paddle according to the specified constant to avoid debouncing
                if bottompaddleRight = (PRESCALER_PADDLE - 5000) and bottompaddleCursor < TOT_H - paddleWidth then
                    bottompaddleCursor <= bottompaddleCursor + 1;
                elsif bottompaddleLeft = (PRESCALER_PADDLE - 5000) and bottompaddleCursor > FP_H + SP_H + BP_H + 1 then
                    bottompaddleCursor <= bottompaddleCursor - 1;
                end if;  
                           --Button - upper paddle control
                if upperright = '1' and upperleft = '0' then
                    upperpaddleRight <= upperpaddleRight + 1;
                    upperpaddleLeft <= 0;
                elsif upperleft = '1' and upperright = '0' then
                    upperpaddleLeft <= upperpaddleLeft + 1;
                    upperpaddleRight <= 0;
                else 
                    upperpaddleRight <= 0;
                    upperpaddleLeft <= 0;
                end if;
                --Adjusting the position of the computer's paddle according to the specified constant to avoid debouncing    
                if upperpaddleRight = PRESCALER_PADDLE and upperpaddleCursor < TOT_H - PADDLE_WIDTH then
                    upperpaddleCursor <= upperpaddleCursor + 1;
                elsif upperpaddleLeft = PRESCALER_PADDLE and upperpaddleCursor > FP_H + SP_H + BP_H + 1 then
                    upperpaddleCursor <= upperpaddleCursor - 1;
                end if;                
            else --The initial positions of the paddles when the game stops
                bottompaddleCursor <= FP_H + SP_H + BP_H + VIS_H / 2 - (PADDLE_WIDTH + 1) / 2;
                upperpaddleCursor <= FP_H + SP_H + BP_H + VIS_H / 2 - (PADDLE_WIDTH + 1) / 2;
            end if;
            --Register to update the values of the synchronization adn rgb signals
            hPosCurrent <= hPosNext;
            vPosCurrent <= vPosNext;
            rgbCurrent <= rgbNext;
        end if;
    end process;
    --Cursor Position Selection                                                            
    bottompaddleVisible <= ((vPosCurrent = TOT_V - PADDLE_HEIGHT + 1) and (hPosCurrent > bottompaddleCursor + 8) and (hPosCurrent < bottompaddleCursor + paddleWidth - 8)) or
                     ((vPosCurrent = TOT_V - PADDLE_HEIGHT + 1) and (hPosCurrent > bottompaddleCursor + 7) and (hPosCurrent < bottompaddleCursor + paddleWidth - 7)) or
                     ((vPosCurrent = TOT_V - PADDLE_HEIGHT + 2) and (hPosCurrent > bottompaddleCursor + 6) and (hPosCurrent < bottompaddleCursor + paddleWidth - 6)) or
                     ((vPosCurrent = TOT_V - PADDLE_HEIGHT + 3) and (hPosCurrent > bottompaddleCursor + 5) and (hPosCurrent < bottompaddleCursor + paddleWidth - 5)) or
                     ((vPosCurrent = TOT_V - PADDLE_HEIGHT + 4) and (hPosCurrent > bottompaddleCursor + 4) and (hPosCurrent < bottompaddleCursor + paddleWidth - 4)) or
                     ((vPosCurrent = TOT_V - PADDLE_HEIGHT + 5) and (hPosCurrent > bottompaddleCursor + 3) and (hPosCurrent < bottompaddleCursor + paddleWidth - 3)) or
                     ((vPosCurrent = TOT_V - PADDLE_HEIGHT + 6) and (hPosCurrent > bottompaddleCursor + 2) and (hPosCurrent < bottompaddleCursor + paddleWidth - 2)) or
                     ((vPosCurrent = TOT_V - PADDLE_HEIGHT + 7) and (hPosCurrent > bottompaddleCursor + 1) and (hPosCurrent < bottompaddleCursor + paddleWidth - 1)) or
                     (((vPosCurrent = TOT_V - PADDLE_HEIGHT + 8) or (vPosCurrent = TOT_V - PADDLE_HEIGHT + 9) or (vPosCurrent = TOT_V - PADDLE_HEIGHT + 10)) 
                     and (hPosCurrent > bottompaddleCursor) and (hPosCurrent < bottompaddleCursor + paddleWidth)) or
                     ((vPosCurrent = TOT_V - PADDLE_HEIGHT + 11) and (hPosCurrent > bottompaddleCursor + 1) and (hPosCurrent < bottompaddleCursor + paddleWidth - 1));
    ballVisible <= (((vPosCurrent = ballCursorY) or (vPosCurrent = ballCursorY + BALL_SIDE)) and (hPosCurrent > ballCursorX + 3) and (hPosCurrent <= ballCursorX + 7)) or
                   (((vPosCurrent = ballCursorY + 1) or (vPosCurrent = ballCursorY + BALL_SIDE - 1)) and (hPosCurrent > ballCursorX + 1) and (hPosCurrent <= ballCursorX + 9)) or
                   (((vPosCurrent = ballCursorY + 2) or (vPosCurrent = ballCursorY + BALL_SIDE - 2)
                   or (vPosCurrent = ballCursorY + 3) or (vPosCurrent = ballCursorY + BALL_SIDE - 3)) and (hPosCurrent > ballCursorX) and (hPosCurrent <= ballCursorX + 10)) or
                   ((vPosCurrent > ballCursorY + 2) and (vPosCurrent <= ballCursorY + 7) and (hPosCurrent >= ballCursorX) and (hPosCurrent <= ballCursorX + 11));
    upperpaddleVisible <= ((vPosCurrent = FP_V + SP_V + BP_V + 1 + 11) and (hPosCurrent > upperpaddleCursor + 8) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH - 8)) or
                       ((vPosCurrent = FP_V + SP_V + BP_V + 1 + 10) and (hPosCurrent > upperpaddleCursor + 7) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH - 7)) or
                       ((vPosCurrent = FP_V + SP_V + BP_V + 1 + 9) and (hPosCurrent > upperpaddleCursor + 6) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH - 6)) or
                       ((vPosCurrent = FP_V + SP_V + BP_V + 1 + 8) and (hPosCurrent > upperpaddleCursor + 5) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH - 5)) or
                       ((vPosCurrent = FP_V + SP_V + BP_V + 1 + 7) and (hPosCurrent > upperpaddleCursor + 4) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH - 4)) or
                       ((vPosCurrent = FP_V + SP_V + BP_V + 1 + 6) and (hPosCurrent > upperpaddleCursor + 3) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH - 3)) or
                       ((vPosCurrent = FP_V + SP_V + BP_V + 1 + 5) and (hPosCurrent > upperpaddleCursor + 2) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH - 2)) or
                       ((vPosCurrent = FP_V + SP_V + BP_V + 1 + 4) and (hPosCurrent > upperpaddleCursor + 1) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH - 1)) or
                       (((vPosCurrent = FP_V + SP_V + BP_V + 1 + 3) or (vPosCurrent = FP_V + SP_V + BP_V + 1 + 2) or (vPosCurrent = FP_V + SP_V + BP_V + 1 + 1)) 
                       and (hPosCurrent > upperpaddleCursor) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH)) or
                       ((vPosCurrent = FP_V + SP_V + BP_V + 1) and (hPosCurrent > upperpaddleCursor + 1) and (hPosCurrent < upperpaddleCursor + PADDLE_WIDTH - 1));                                          
    borderVisible <= (vPosCurrent = FP_V + SP_V + BP_V + (VIS_V / 2) and newGame = '0');
    --Scanning the Pixels
    hPosNext <= hPosCurrent + 1 when hPosCurrent < TOT_H else 1;
    vPosNext <= vPosCurrent + 1 when hPosCurrent = TOT_H and vPosCurrent < TOT_V else
                1 when hPosCurrent = TOT_H and vPosCurrent = TOT_V else vPosCurrent;
	--Color Selection with a multiplexer
    rgbNext <= "11111111" when bottompaddleVisible else
               "11111111" when ballVisible else                     
               "11111111" when frameVisible or borderVisible else
               "11111111" when upperpaddleVisible else
               "00000000";    
    --Updating the signals that will go to the VGA port
    hSync <= '0' when (hPosCurrent > FP_H) and (hPosCurrent < FP_H + SP_H + 1) else '1';
    vSync <= '0' when (vPosCurrent > FP_V) and (vPosCurrent < FP_V + SP_V + 1) else '1';
    r <= rgbCurrent(7 downto 5);
    g <= rgbCurrent(4 downto 2);
    b <= rgbCurrent(1 downto 0);    
end Behavioral;