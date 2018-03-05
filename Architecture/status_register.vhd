----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:22:41 02/28/2018 
-- Design Name: 
-- Module Name:    register - Behavioral 
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

entity statusRegister is
	port	(	clk	: in std_logic;
	
				d		: in	std_logic_vector( 15 downto 0 );
				we 	: in	std_logic_vector(  1 downto 0 );
				
				q		: out	std_logic_vector( 15 downto 0 ));
end statusRegister;

architecture Behavioral of statusRegister is
	signal L			: in std_logic_vector( 15 downto 0 ) := X"7777";
	begin

		process( clk )
		begin
			if (rising_edge(clk)) then
				if (we(1) = '1') then
					L( 15 downto 8 )	<= d( 15 downto 8 );
				end if;
				if (we(0) = '1') then
					L(  7 downto 0 )	<= d(  7 downto 0 );
				end if;
			end if;
		end process;
		
		q	<= L;
		
end Behavioral;
