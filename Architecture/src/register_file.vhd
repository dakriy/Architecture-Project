----------------------------------------------------------------------------------
--
-- Module Name:     register_file
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     a register file (16 register pairs) of a CPU.
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_file is
	port	( i_clk		: in std_logic;

					i_amod      : in std_logic_vector( 5 downto 0)
					i_cond      : in std_logic_vector( 3 downto 0);
          i_ssss      : in std_logic_vector( 3 downto 0);
          --i_din     : in std_logic_vector( 8 downto 0);
          --i_flags   : in std_logic_vector( 7 downto 0);
          i_imm       : in std_logic_vector(15 downto 0);
          i_tttt      : in std_logic_vector( 3 downto 0);
          i_we_01     : in std_logic;
          i_we_d      : in std_logic_vector( 1 downto 0);
          --i_we_f    : in std_logic;
          i_we_m      : in std_logic;

          q_adr       : out std_logic_vector(15 downto 0);
          q_cc        : out std_logic;
          q_d         : out std_logic_vector(15 downto 0);
          q_flags     : out std_logic_vector( 7 downto 0);
          q_r         : out std_logic_vector(15 downto 0);
          q_s         : out std_logic_vector( 7 downto 0);
          q_z         : out std_logic_vector(15 downto 0));
end register_file;

architecture Behavioral of register_file is

	component register_16
		port	( i_clk		: in std_logic;

						i_d		: in std_logic_vector(15 downto 0);
						i_we	: in std_logic_vector( 1 downto 0);

						q		: out std_logic_vector(15 downto 0));
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


--	component status_register
--		port	( i_clk	: in std_logic;
--
--			d	: in	std_logic_vector( 15 downto 0 );
--			i_we 	: in	std_logic_vector(  1 downto 0 );
--
--			q	: out	std_logic_vector( 15 downto 0 ));
--	end component;


    signal s_flags      : std_logic_vector( 7 downto 0);
    signal l_adr        : std_logic_vector(15 downto 0);
    signal l_base       : std_logic_vector(15 downto 0);
    signal l_ssss       : std_logic_vector( 3 downto 0);
    signal l_dsp        : std_logic_vector(15 downto 0);
    signal l_pre        : std_logic_vector(15 downto 0);
    signal l_post       : std_logic_vector(15 downto 0);
    signal l_s          : std_logic_vector(15 downto 0);
    signal l_we_sp_amod : std_logic;
    signal l_we         : std_logic_vector(31 downto 0);
    signal l_we_a       : std_logic;
    signal l_we_d       : std_logic_vector(31 downto 0);
    signal l_we_d2      : std_logic_vector( 1 downto 0);
    signal l_we_dd      : std_logic_vector(31 downto 0);
    signal l_we_io      : std_logic_vector(31 downto 0);
    signal l_we_misc    : std_logic_vector(31 downto 0);

	begin
		r00:	register_16 port map(i_clk => i_clk, i_we => l_i_we(1 downto 0), i_d => i_din, q => r_r00);
		r01:	register_16 port map(i_clk => i_clk, i_we => l_i_we(3 downto 2), i_d => i_din, q => r_r01);
		r02:	register_16 port map(i_clk => i_clk, i_we => l_i_we(5 downto 4), i_d => i_din, q => r_r02);
		r03:	register_16 port map(i_clk => i_clk, i_we => l_i_we(7 downto 6), i_d => i_din, q => r_r03);
		r04:	register_16 port map(i_clk => i_clk, i_we => l_i_we(9 downto 8), i_d => i_din, q => r_r04);
		r05:	register_16 port map(i_clk => i_clk, i_we => l_i_we(11 downto 10), i_d => i_din, q => r_r05);
		r06:	register_16 port map(i_clk => i_clk, i_we => l_i_we(13 downto 12), i_d => i_din, q => r_r06);
		r07:	register_16 port map(i_clk => i_clk, i_we => l_i_we(15 downto 14), i_d => i_din, q => r_r07);
		r06:	register_16 port map(i_clk => i_clk, i_we => l_i_we(17 downto 16), i_d => i_din, q => r_r08);
		r08:	register_16 port map(i_clk => i_clk, i_we => l_i_we(19 downto 18), i_d => i_din, q => r_r09);
		r10:	register_16 port map(i_clk => i_clk, i_we => l_i_we(21 downto 20), i_d => i_din, q => r_r10);
		r11:	register_16 port map(i_clk => i_clk, i_we => l_i_we(23 downto 22), i_d => i_din, q => r_r11);
		r12:	register_16 port map(i_clk => i_clk, i_we => l_i_we(25 downto 24), i_d => i_din, q => r_r12);
		r13:	register_16 port map(i_clk => i_clk, i_we => l_i_we(27 downto 26), i_d => i_din, q => r_r13);
		r14:	register_16 port map(i_clk => i_clk, i_we => l_i_we(29 downto 28), i_d => i_din, q => r_r14);
		r15:	register_16 port map(i_clk => i_clk, i_we => l_i_we(31 downto 30), i_d => i_din, q => r_r15);
		--sr:	status_register port map();

	-- The output of the register pair selected by l_adr
	process(r_r00, r_r01, r_r02, r_r03, r_r04, r_r05, r_r06, r_r07, r_r08, r_r09, r_r10, r_r11, r_r12, r_r13, r_r14, r_r15, s_flags, l_adr(6 downto 1))

    begin
		case l_adr(6 downto 1) is
			when "0000" => l_s	<= r_r00
			when "0001" => l_s	<= r_r01
			when "0010" => l_s	<= r_r02
			when "0011" => l_s	<= r_r03
			when "0100" => l_s	<= r_r04
			when "0101" => l_s	<= r_r05
			when "0110" => l_s	<= r_r06
			when "0111" => l_s	<= r_r07
			when "1000" => l_s	<= r_r08
			when "1001" => l_s	<= r_r09
			when "1010" => l_s	<= r_r10
			when "1011" => l_s	<= r_r11
			when "1100" => l_s	<= r_r12
			when "1101" => l_s	<= r_r13
			when "1110" => l_s	<= r_r14
			when others => l_s	<= r_r15
		end case;
	end process;

    -- The output of the register pair selected by i_ssss.
    process(r_r00, r_r01, r_r02, r_r03, r_r04, r_r05, r_r06, r_r07, r_r08, r_r09, r_r10, r_r11, r_r12, r_r13, r_r14, r_r15, s_flags, i_ssss(11 downto 8))

	begin
		case i_ssss(11 downto 8) is
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


	-- The output of the register pair selected by i_tttt
	process(r_r00, r_r01, r_r02, r_r03, r_r04, r_r05, r_r06, r_r07, r_r08, r_r09, r_r10, r_r11, r_r12, r_r13, r_r14, r_r15, i_tttt)

	begin
		case i_tttt is
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

    l_adr       <= l_base + l_pre;
    l_we_a      <= i_we_m when (l_adr(15 downto 5) = "00000000000") else '0';
    l_we_sr     <= i_we_m when (l_adr = x"005f") else '0';

    -- the we signals for the differen registers.
    -- case 1: write to an 8-bit register addressed by ddddd.
    -- i_we_d(0) = '1' and i_ssss matches,
    l_we_d( 0)  <= i_we_d(0) when (i_ssss = "0000") else '0';
    l_we_d( 1)  <= i_we_d(0) when (i_ssss = "0001") else '0';
    l_we_d( 2)  <= i_we_d(0) when (i_ssss = "0010") else '0';
    l_we_d( 3)  <= i_we_d(0) when (i_ssss = "0011") else '0';
    l_we_d( 4)  <= i_we_d(0) when (i_ssss = "0100") else '0';
    l_we_d( 5)  <= i_we_d(0) when (i_ssss = "0101") else '0';
    l_we_d( 6)  <= i_we_d(0) when (i_ssss = "0110") else '0';
    l_we_d( 7)  <= i_we_d(0) when (i_ssss = "0111") else '0';
    l_we_d( 8)  <= i_we_d(0) when (i_ssss = "1000") else '0';
    l_we_d( 9)  <= i_we_d(0) when (i_ssss = "1001") else '0';
    l_we_d(10)  <= i_we_d(0) when (i_ssss = "1010") else '0';
    l_we_d(11)  <= i_we_d(0) when (i_ssss = "1011") else '0';
    l_we_d(12)  <= i_we_d(0) when (i_ssss = "1100") else '0';
    l_we_d(13)  <= i_we_d(0) when (i_ssss = "1101") else '0';
    l_we_d(14)  <= i_we_d(0) when (i_ssss = "1110") else '0';
    l_we_d(15)  <= i_we_d(0) when (i_ssss = "1111") else '0';

    -- case 2: write to a 16-bit register pair addressed by ssss.
    -- i_we_dd(1) = '1' and l_ssss matches,
    l_ssss                  <= i_ssss(3 downto 0);
    l_we_d2                 <= i_we_d(1) & i_we_d(1);
    l_we_dd( 1 downto 0)    <= l_we_d2 when (l_ssss = "0000") else "00";
    l_we_dd( 3 downto 2)    <= l_we_d2 when (l_ssss = "0001") else "00";
    l_we_dd( 5 downto 4)    <= l_we_d2 when (l_ssss = "0010") else "00";
    l_we_dd( 7 downto 6)    <= l_we_d2 when (l_ssss = "0011") else "00";
    l_we_dd( 9 downto 8)    <= l_we_d2 when (l_ssss = "0100") else "00";
    l_we_dd(11 downto 10)   <= l_we_d2 when (l_ssss = "0101") else "00";
    l_we_dd(13 downto 12)   <= l_we_d2 when (l_ssss = "0110") else "00";
    l_we_dd(15 downto 14)   <= l_we_d2 when (l_ssss = "0111") else "00";
    l_we_dd(17 downto 16)   <= l_we_d2 when (l_ssss = "1000") else "00";
    l_we_dd(19 downto 18)   <= l_we_d2 when (l_ssss = "1001") else "00";
    l_we_dd(21 downto 20)   <= l_we_d2 when (l_ssss = "1010") else "00";
    l_we_dd(23 downto 22)   <= l_we_d2 when (l_ssss = "1011") else "00";
    l_we_dd(25 downto 24)   <= l_we_d2 when (l_ssss = "1100") else "00";
    l_we_dd(27 downto 26)   <= l_we_d2 when (l_ssss = "1101") else "00";
    l_we_dd(29 downto 28)   <= l_we_d2 when (l_ssss = "1110") else "00";
    l_we_dd(31 downto 30)   <= l_we_d2 when (l_ssss = "1111") else "00";

    -- case 3: write to an 8-bit register pair addressed by an i/o address.
    -- l_we_a = '1' and l_adr(3 downto 0) matches
    l_we_io( 0) <= l_we_a when (l_adr(3 downto 0) = "0000") else '0';
    l_we_io( 1) <= l_we_a when (l_adr(3 downto 0) = "0001") else '0';
    l_we_io( 2) <= l_we_a when (l_adr(3 downto 0) = "0010") else '0';
    l_we_io( 3) <= l_we_a when (l_adr(3 downto 0) = "0011") else '0';
    l_we_io( 4) <= l_we_a when (l_adr(3 downto 0) = "0100") else '0';
    l_we_io( 5) <= l_we_a when (l_adr(3 downto 0) = "0101") else '0';
    l_we_io( 6) <= l_we_a when (l_adr(3 downto 0) = "0110") else '0';
    l_we_io( 7) <= l_we_a when (l_adr(3 downto 0) = "0111") else '0';
    l_we_io( 8) <= l_we_a when (l_adr(3 downto 0) = "1000") else '0';
    l_we_io( 9) <= l_we_a when (l_adr(3 downto 0) = "1001") else '0';
    l_we_io(10) <= l_we_a when (l_adr(3 downto 0) = "1010") else '0';
    l_we_io(11) <= l_we_a when (l_adr(3 downto 0) = "1011") else '0';
    l_we_io(12) <= l_we_a when (l_adr(3 downto 0) = "1100") else '0';
    l_we_io(13) <= l_we_a when (l_adr(3 downto 0) = "1101") else '0';
    l_we_io(14) <= l_we_a when (l_adr(3 downto 0) = "1110") else '0';
    l_we_io(15) <= l_we_a when (l_adr(3 downto 0) = "1111") else '0';

    q_s <= l_s(7 downto 0) when (l_adr(0) = '0') else l_s(15 downto 8);
    q_flags <= s_flags;
    q_z <= r_r15;
    q_adr <= l_adr;

end Behavioral
