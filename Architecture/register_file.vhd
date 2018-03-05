----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    18:22:41 02/28/2018
-- Design Name:
-- Module Name:    register_file - Behavioral
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

entity register_file is
	port	( clk		: in std_logic;

					amod	: in std_logic_vector( 5 downto 0 ));
end register_file;

architecture Behavioral of register_file is

	component register_16
		port	( clk		: in std_logic;

						d			: in	std_logic_vector( 15 downto 0 );
						we		: in	std_logic_vector(  1 downto 0 );

						q			: out	std_logic_vector( 15 downto 0 ));
	end component;


	signal r_r00	: std_logic_vector(15 downto 0);
	signal r_r01	: std_logic_vector(15 downto 0);
	signal r_r02	: std_logic_vector(15 downto 0);
	signal r_r03	: std_logic_vector(15 downto 0);
	signal r_r04	: std_logic_vector(15 downto 0);
	signal r_r05	: std_logic_vector(15 downto 0);
	signal r_r06	: std_logic_vector(15 downto 0);
	signal r_r07	: std_logic_vector(15 downto 0);
	signal r_r08	: std_logic_vector(15 downto 0);
	signal r_r09	: std_logic_vector(15 downto 0);
	signal r_r10	: std_logic_vector(15 downto 0);
	signal r_r11	: std_logic_vector(15 downto 0);
	signal r_r12	: std_logic_vector(15 downto 0);
	signal r_r13	: std_logic_vector(15 downto 0);
	signal r_r14	: std_logic_vector(15 downto 0);
	signal r_r15	: std_logic_vector(15 downto 0);


	component status_register
		port	( clk	: in std_logic;

			d	: in	std_logic_vector( 15 downto 0 );
			we 	: in	std_logic_vector(  1 downto 0 );

			q	: out	std_logic_vector( 15 downto 0 ));
	end component;


	begin
		r00:	register_16 port map(clk => clk, we => L_we(1 downto 0), d => d, q => r_r00);
		r01:	register_16 port map(clk => clk, we => L_we(3 downto 2), d => d, q => r_r01);
		r02:	register_16 port map(clk => clk, we => L_we(5 downto 4), d => d, q => r_r02);
		r03:	register_16 port map(clk => clk, we => L_we(7 downto 6), d => d, q => r_r03);
		r04:	register_16 port map(clk => clk, we => L_we(9 downto 8), d => d, q => r_r04);
		r05:	register_16 port map(clk => clk, we => L_we(11 downto 10), d => d, q => r_r05);
		r06:	register_16 port map(clk => clk, we => L_we(13 downto 12), d => d, q => r_r06);
		r07:	register_16 port map(clk => clk, we => L_we(15 downto 14), d => d, q => r_r07);
		r06:	register_16 port map(clk => clk, we => L_we(17 downto 16), d => d, q => r_r08);
		r08:	register_16 port map(clk => clk, we => L_we(19 downto 18), d => d, q => r_r09);
		r10:	register_16 port map(clk => clk, we => L_we(21 downto 20), d => d, q => r_r10);
		r11:	register_16 port map(clk => clk, we => L_we(23 downto 22), d => d, q => r_r11);
		r12:	register_16 port map(clk => clk, we => L_we(25 downto 24), d => d, q => r_r12);
		r13:	register_16 port map(clk => clk, we => L_we(27 downto 26), d => d, q => r_r13);
		r14:	register_16 port map(clk => clk, we => L_we(29 downto 28), d => d, q => r_r14);
		r15:	register_16 port map(clk => clk, we => L_we(31 downto 30), d => d, q => r_r15);
		--sr:	status_register port map();

	-- The output of the register pair selected by I_DDDDD
	process(r_r00, r_r01, r_r02, r_r03, r_r04, r_r05, r_r06, r_r07, r_r08, r_r09, r_r10, r_r11, r_r12, r_r13, r_r14, r_r15, I_DDDDD(4 downto 1))

	begin
		case I_DDDDD(4 downto 1) is
			when "0000" => q_d	<= r_r00
			when "0001" => q_d	<= r_r01
			when "0010" => q_d	<= r_r02
			when "0011" => q_d	<= r_r03
			when "0100" => q_d	<= r_r04
			when "0101" => q_d	<= r_r05
			when "0110" => q_d	<= r_r06
			when "0111" => q_d	<= r_r07
			when "1000" => q_d	<= r_r08
			when "1001" => q_d	<= r_r09
			when "1010" => q_d	<= r_r10
			when "1011" => q_d	<= r_r11
			when "1100" => q_d	<= r_r12
			when "1101" => q_d	<= r_r13
			when "1110" => q_d	<= r_r14
			when others => q_d	<= r_r15
		end case;
	end process;


	-- The output of the register pair selected by I_RRRR
	process(r_r00, r_r01, r_r02, r_r03, r_r04, r_r05, r_r06, r_r07, r_r08, r_r09, r_r10, r_r11, r_r12, r_r13, r_r14, r_r15, I_RRRR)

	begin
		case I_RRRR is
			when "0000" => q_r	<= r_r00
			when "0001" => q_r	<= r_r01
			when "0010" => q_r	<= r_r02
			when "0011" => q_r	<= r_r03
			when "0100" => q_r	<= r_r04
			when "0101" => q_r	<= r_r05
			when "0110" => q_r	<= r_r06
			when "0111" => q_r	<= r_r07
			when "1000" => q_r	<= r_r08
			when "1001" => q_r	<= r_r09
			when "1010" => q_r	<= r_r10
			when "1011" => q_r	<= r_r11
			when "1100" => q_r	<= r_r12
			when "1101" => q_r	<= r_r13
			when "1110" => q_r	<= r_r14
			when others => q_r	<= r_r15
		end case;
	end process;

end Behavioral
