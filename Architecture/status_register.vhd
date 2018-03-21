----------------------------------------------------------------------------------
--
-- Module Name:     status_register
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     the status register of a CPU.
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity status_register is
	port	(	clk	: in std_logic;

				d		: in	std_logic_vector( 15 downto 0 );
				we 	: in	std_logic_vector(  1 downto 0 );

				q		: out	std_logic_vector( 15 downto 0 ));
end status_register;

architecture Behavioral of status_register is
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
