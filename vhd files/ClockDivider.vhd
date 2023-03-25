----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:57:51 06/28/2021 
-- Design Name: 
-- Module Name:    freqdivider - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ClockDivider is
    Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end ClockDivider;

architecture Behavioral of ClockDivider is

signal my_count: integer range 0 to 10 := 0;
signal temp : std_logic := '0';     

begin

process (clk_in) 
 
begin
if rising_edge(clk_in) then
  if my_count = 1 then
	 my_count <= 0;
	 temp <= not temp;
  else 
	 my_count <= my_count + 1;
  end if;
end if;

clk_out <= temp;

end process;

end Behavioral;

