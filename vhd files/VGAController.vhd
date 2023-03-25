----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:27:35 06/29/2021 
-- Design Name: 
-- Module Name:    VGAController - Behavioral 
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

entity VGAController is
  Port (clock: in std_logic; 
        centerButton, leftButton1, rightButton1, leftButton2, rightButton2 : inout std_logic;
        hSync, vSync: out std_logic;
        VGARed, VGAGreen: out std_logic_vector(2 downto 0);
		  VGABlue: out std_logic_vector(1 downto 0);
		  EppAstb: in std_logic;                                             
        EppDstb: in std_logic;                                              
        EppWr : in std_logic;                                              
        EppDB : inout std_logic_vector(7 downto 0);
        EppWait: out std_logic);
end VGAController;

architecture Behavioral of VGAController is
--Decleration of the components
component ClockDivider is
    Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end component;

component Sync is
    Port (clock, bottomleft, bottomright, upperleft, upperright, start: in std_logic;     
        hSync, vSync: out std_logic;
        r, g: out std_logic_vector(2 downto 0);
		  b: out std_logic_vector(1 downto 0));    
end component;

component IOExpansion is
  Port (
-- Epp-like bus signals
      EppAstb: in std_logic;        -- Address strobe
      EppDstb: in std_logic;        -- Data strobe
      EppWr  : in std_logic;        -- Port write signal
      EppDB  : inout std_logic_vector(7 downto 0); -- port data bus
      EppWait: out std_logic;        -- Port wait signal
-- user extended signals 
      Led  : in std_logic_vector(7 downto 0);   -- 0x01     8 virtual LEDs on the PC I/O Ex GUI
      LBar : in std_logic_vector(23 downto 0);  -- 0x02..4  24 lights on the PC I/O Ex GUI light bar
      Sw   : out std_logic_vector(15 downto 0);  -- 0x05..6  16 switches, bottom row on the PC I/O Ex GUI
      Btn  : out std_logic_vector(15 downto 0);  -- 0x07..8  16 Buttons, bottom row on the PC I/O Ex GUI
      dwOut: out std_logic_vector(31 downto 0); -- 0x09..b  32 Bits user output
      dwIn : in std_logic_vector(31 downto 0)   -- 0x0d..10 32 Bits user input
         );
end component;

--Intermediate carrier signal   
signal VGAClock: std_logic;   
signal Led1: std_logic_vector(7 downto 0);
signal LBar1: std_logic_vector(23 downto 0);
signal Sw1: std_logic_vector(15 downto 0);
signal Btn1: std_logic_vector(15 downto 0);
signal dwbtwn: std_logic_vector(31 downto 0);

begin

    --port-mappings
    Component1: ClockDivider 
                    port map(clk_in => clock,
                             clk_out => VGAClock);
    Component2: Sync
                    port map(clock => VGAClock,
                             bottomleft => leftButton1,
                             bottomright => rightButton1,
									  upperleft => leftButton2,
                             upperright => rightButton2,
                             start => centerButton,
                             hSync => hSync,
                             vSync => vSync,
                             r => VGARed,
                             g => VGAGreen,
                             b => VGABlue);
									  
		Component3: IOExpansion port map(EppAstb=>EppAstb,         
            EppDstb=>EppDstb, 
            EppWr=>EppWr, 
            EppDB=>EppDB, 
            EppWait=>EppWait, 
            Led=>Led1, 
            LBar=>Lbar1,
            Sw=>Sw1,
            Btn=>Btn1, 
            dwOut=>dwBtwn, 
            dwIn=>dwBtwn);
				
		       leftButton1<=Btn1(1);
				 rightButton1<=Btn1(0);
				 centerButton<=Btn1(15);
				 leftButton2<=Btn1(7);
				 rightButton2<=Btn1(6);
				
		
end Behavioral;