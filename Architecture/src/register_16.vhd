----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    18:22:41 02/28/2018
-- Design Name:
-- Module Name:    register_16 - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity register_16 is
	port	(	i_clk	: in std_logic;

		i_d		: in	std_logic_vector( 15 downto 0 );
		i_we 	: in	std_logic_vector(  1 downto 0 );

		q			: out	std_logic_vector( 15 downto 0 ));
end register_16;

architecture Behavioral of register_16 is
	signal l			: in std_logic_vector( 15 downto 0 ) := x"0000";
	begin

		process( i_clk )
		begin
			if (rising_edge(clk)) then
				if (i_we(1) = '1') then
					l( 15 downto 8 )	<= i_d( 15 downto 8 );
				end if;
				if (i_we(0) = '1') then
					l(  7 downto 0 )	<= i_d(  7 downto 0 );
				end if;
			end if;
		end process;

		q	<= l;

end Behavioral;
