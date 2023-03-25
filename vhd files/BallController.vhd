----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:25:22 06/29/2021 
-- Design Name: 
-- Module Name:    BallController - Behavioral 
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
use work.Constants.all;

entity BallController is
  Port (start, move: in std_logic;
        paddleWidth: in integer;
        bottompaddlePos, upperpaddlePos: in integer range TOT_H - VIS_H + 1 to TOT_H - PADDLE_WIDTH;
        xPos: out integer range TOT_H - VIS_H + 1 to TOT_H - BALL_SIDE;
        yPos: out integer range TOT_V - VIS_V + 1 to TOT_V;
        newGame, play, player1won, player2won: out std_logic);
end BallController;

architecture Behavioral of BallController is
--Intermediate signals
signal currentX: integer range TOT_H - VIS_H + 1 to TOT_H - BALL_SIDE:= BALL_INITIAL_X;
signal currentY: integer range TOT_V - VIS_V + 1 to TOT_V:= BALL_INITIAL_Y;
signal playingCurrent: std_logic:= '0';
signal resetCurrent: std_logic:= '1';
signal player2wins, player1wins: std_logic:= '0';	
begin
 process(move)
 variable wallHorizontalBounce, bottompaddleSideBounce, bottompaddleSurfaceBounce, upperpaddleSideBounce, upperpaddleSurfaceBounce: boolean := false; --Collision indicating variables
 variable horizontalVelocity: integer:= -1; -- -1: left & up 1: right & down 
 variable verticalVelocity: integer:= -1; -- -1: left & up 1: right & down 
    begin
        if move'event and move = '1' then --The signals inside the process are only updated in the rising edges of the move signal.
            --Win/End conditions
            if currentY <= FP_V + SP_V + BP_V + 1 then
                player2wins <= '1';
            elsif start = '1' then
                player2wins <= '0';
            end if;
            if currentY >= TOT_V then
                player1wins <= '1';
            elsif start = '1' then
                player1wins <= '0';
            end if;
            --Reset Logic
            if player1wins = '1' or player2wins = '1' then
                currentX <= BALL_INITIAL_X;
                currentY <= BALL_INITIAL_Y;
                playingCurrent <= '0';
                resetCurrent <= '1';
            elsif start = '1' then
                playingCurrent <= '1';
                resetCurrent <= '0';
            end if;
            --Collision Detection Statements (searches for the intersections between the ball and the specified objects)
            wallHorizontalBounce := currentX <= FP_H + SP_H + BP_H + 1 or currentX >= TOT_H - BALL_SIDE;
            bottompaddleSurfaceBounce := currentY >= TOT_V - PADDLE_HEIGHT - BALL_SIDE and 
                                   currentX >= bottompaddlePos and 
                                   currentX <= bottompaddlePos + paddleWidth - BALL_SIDE;
            bottompaddleSideBounce := ((currentX = bottompaddlePos - 9 or currentX = bottompaddlePos - 8 or currentX = bottompaddlePos + paddleWidth or currentX = bottompaddlePos + paddleWidth - 1)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 10)) or
                                ((currentX = bottompaddlePos - 8 or currentX = bottompaddlePos - 7 or currentX = bottompaddlePos + paddleWidth - 1 or currentX = bottompaddlePos + paddleWidth - 2)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 9)) or
                                ((currentX = bottompaddlePos - 7 or currentX = bottompaddlePos - 6 or currentX = bottompaddlePos + paddleWidth - 2 or currentX = bottompaddlePos + paddleWidth - 3)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 8)) or
                                ((currentX = bottompaddlePos - 6 or currentX = bottompaddlePos - 5 or currentX = bottompaddlePos + paddleWidth - 3 or currentX = bottompaddlePos + paddleWidth - 4)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 7)) or
                                ((currentX = bottompaddlePos - 5 or currentX = bottompaddlePos - 4 or currentX = bottompaddlePos + paddleWidth - 4 or currentX = bottompaddlePos + paddleWidth - 5)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 6)) or
                                ((currentX = bottompaddlePos - 4 or currentX = bottompaddlePos - 3 or currentX = bottompaddlePos + paddleWidth - 5 or currentX = bottompaddlePos + paddleWidth - 6)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 5)) or
                                ((currentX = bottompaddlePos - 3 or currentX = bottompaddlePos - 2 or currentX = bottompaddlePos + paddleWidth - 6 or currentX = bottompaddlePos + paddleWidth - 7)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 4)) or
                                ((currentX = bottompaddlePos - 2 or currentX = bottompaddlePos - 1 or currentX = bottompaddlePos + paddleWidth - 7 or currentX = bottompaddlePos + paddleWidth - 8)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 3)) or
                                ((currentX = bottompaddlePos - 1 or currentX = bottompaddlePos or currentX = bottompaddlePos + paddleWidth - 8 or currentX = bottompaddlePos + paddleWidth - 9)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 2)) or
                                ((currentX = bottompaddlePos or currentX = bottompaddlePos + 1 or currentX = bottompaddlePos + paddleWidth - 9 or currentX = bottompaddlePos + paddleWidth - 10)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE + 1)) or
                                ((currentX = bottompaddlePos + 1 or currentX = bottompaddlePos + 2 or currentX = bottompaddlePos + paddleWidth - 10 or currentX = bottompaddlePos + paddleWidth - 11)
                                and (currentY = TOT_V - PADDLE_HEIGHT - BALL_SIDE));
            upperpaddleSurfaceBounce := currentY <= FP_V + SP_V + BP_V + PADDLE_HEIGHT and 
                                     currentX >= upperpaddlePos and 
                                     currentX <= upperpaddlePos + PADDLE_WIDTH - BALL_SIDE;
            upperpaddleSideBounce := ((currentX = upperpaddlePos - 9 or currentX = upperpaddlePos - 8 or currentX = upperpaddlePos + PADDLE_WIDTH or currentX = upperpaddlePos + PADDLE_WIDTH - 1)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 10)) or
                                  ((currentX = upperpaddlePos - 8 or currentX = upperpaddlePos - 7 or currentX = upperpaddlePos + PADDLE_WIDTH - 1 or currentX = upperpaddlePos + PADDLE_WIDTH - 2)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 9)) or
                                  ((currentX = upperpaddlePos - 7 or currentX = upperpaddlePos - 6 or currentX = upperpaddlePos + PADDLE_WIDTH - 2 or currentX = upperpaddlePos + PADDLE_WIDTH - 3)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 8)) or
                                  ((currentX = upperpaddlePos - 6 or currentX = upperpaddlePos - 5 or currentX = upperpaddlePos + PADDLE_WIDTH - 3 or currentX = upperpaddlePos + PADDLE_WIDTH - 4)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 7)) or
                                  ((currentX = upperpaddlePos - 5 or currentX = upperpaddlePos - 4 or currentX = upperpaddlePos + PADDLE_WIDTH - 4 or currentX = upperpaddlePos + PADDLE_WIDTH - 5)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 6)) or
                                  ((currentX = upperpaddlePos - 4 or currentX = upperpaddlePos - 3 or currentX = upperpaddlePos + PADDLE_WIDTH - 5 or currentX = upperpaddlePos + PADDLE_WIDTH - 6)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 5)) or
                                  ((currentX = upperpaddlePos - 3 or currentX = upperpaddlePos - 2 or currentX = upperpaddlePos + PADDLE_WIDTH - 6 or currentX = upperpaddlePos + PADDLE_WIDTH - 7)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 4)) or
                                  ((currentX = upperpaddlePos - 2 or currentX = upperpaddlePos - 1 or currentX = upperpaddlePos + PADDLE_WIDTH - 7 or currentX = upperpaddlePos + PADDLE_WIDTH - 8)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 3)) or
                                  ((currentX = upperpaddlePos - 1 or currentX = upperpaddlePos or currentX = upperpaddlePos + PADDLE_WIDTH - 8 or currentX = upperpaddlePos + PADDLE_WIDTH - 9)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 2)) or
                                  ((currentX = upperpaddlePos or currentX = upperpaddlePos + 1 or currentX = upperpaddlePos + PADDLE_WIDTH - 9 or currentX = upperpaddlePos + PADDLE_WIDTH - 10)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT - 1)) or
                                  ((currentX = upperpaddlePos + 1 or currentX = upperpaddlePos + 2 or currentX = upperpaddlePos + PADDLE_WIDTH - 10 or currentX = upperpaddlePos + PADDLE_WIDTH - 11)
                                  and (currentY = FP_V + SP_V + BP_V + PADDLE_HEIGHT));
            --Next state logics for the position and velocity of the ball                      
            if wallHorizontalBounce or bottompaddleSideBounce then
               horizontalVelocity := - horizontalvelocity;
            elsif playingCurrent = '0' then
               horizontalVelocity := -1; 
            end if;
            if bottompaddleSurfaceBounce or bottompaddleSideBounce or upperpaddleSurfaceBounce or upperpaddleSideBounce then
                verticalVelocity :=  - verticalVelocity;
            elsif playingCurrent = '0' then
                verticalVelocity := -1;
            end if;
            if playingCurrent = '1' then
                currentX <= currentX + horizontalVelocity;
                currentY <= currentY + verticalVelocity;
            end if;
        end if;
    end process;
    --Register to update the main signals
    xPos <= currentX;
    yPos <= currentY;
    play <= playingCurrent;
    newGame <= resetCurrent;
    player1won <= player1wins;
    player2won <= player2wins;
end Behavioral;