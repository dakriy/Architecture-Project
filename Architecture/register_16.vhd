----------------------------------------------------------------------------------
--
-- Module Name:     register_16
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     a register pair of a CPU.
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
----------------------------------------------------------------------------------

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
	signal l			: std_logic_vector( 15 downto 0 ) := x"0000";
	begin

		process( i_clk )
		begin
			if (rising_edge(i_clk)) then
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
