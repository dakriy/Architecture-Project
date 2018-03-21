-------------------------------------------------------------------------------
--
-- Module Name:     program_mememory
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     the program memory of a CPU.
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

use work.program_memory_content.all;

entity program_memory is
    port( i_clk     : in std_logic;

          i_wait    : in std_logic;
          i_pc      : in std_logic_vector( 15 downto 0 ); --16 bit register
          i_pm_adr : in std_logic_vector( 11 downto 0 ); --256 register space

          q_opc     : out std_logic_vector( 15 downto 0 ); --16bit opcode do be decoded
          q_pc      : out std_logic_vector( 15 downto 0 ); --16bit register
          q_pm_dout : out std_logic_vector(  7 downto 0 )); --256 register space
end program_memory;

architecture behavioral of program_memory is

constant zero_256 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";

component ramb4_s4_s4
	generic( init_00 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_01 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_02 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_03 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_04 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_05 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_06 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_07 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_08 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_09 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_0a : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_0b : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_0c : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_0d : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_0e : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
				init_0f : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000");
	port( addra :in std_logic_vector(9 downto 0);
			addrb :in std_logic_vector(9 downto 0);
			clka :in std_logic;
			clkb :in std_logic;
			dia :in std_logic_vector(3 downto 0);
			dib :in std_logic_vector(3 downto 0);
			ena :in std_logic;
			enb :in std_logic;
			rsta :in std_logic;
			rstb :in std_logic;
			wea :in std_logic;
			web :in std_logic;
			
			doa :out std_logic_vector(3 downto 0);
			dob :out std_logic_vector(3 downto 0));
end component;

signal m_opc_e : std_logic_vector(15 downto 0);
signal m_opc_o : std_logic_vector(15 downto 0);
signal m_pmd_e : std_logic_vector(15 downto 0);
signal m_pmd_o : std_logic_vector(15 downto 0);
signal l_wait_n : std_logic;
signal l_pc_0 : std_logic;
signal l_pc_e : std_logic_vector(10 downto 1);
signal l_pc_o : std_logic_vector(10 downto 1);
signal l_pmd : std_logic_vector(15 downto 0);
signal l_pm_adr_1_0 : std_logic_vector(1 downto 0);

begin
	pe_0 : ramb4_s4_s4 ---------------------------------------------------------
	generic map(init_00 => pe_0_00, init_01 => pe_0_01, init_02 => pe_0_02,
					init_03 => pe_0_03, init_04 => pe_0_04, init_05 => pe_0_05,
					init_06 => pe_0_06, init_07 => pe_0_07, init_08 => pe_0_08,
					init_09 => pe_0_09, init_0a => pe_0_0a, init_0b => pe_0_0b,
					init_0c => pe_0_0c, init_0d => pe_0_0d, init_0e => pe_0_0e,
					init_0f => pe_0_0f)
	port map(addra => l_pc_e,
				addrb => i_pm_adr(11 downto 2),
				clka => i_clk,
				clkb => i_clk,
				dia => "0000",
				dib => "0000",
				ena => l_wait_n,
				enb => '1',
				rsta => '0',
				rstb => '0',
				wea => '0',
				web => '0',
				
				doa => m_opc_e(3 downto 0),
				dob => m_pmd_e(3 downto 0));
	pe_1 : ramb4_s4_s4 ---------------------------------------------------------
	generic map(init_00 => pe_0_00, init_01 => pe_0_01, init_02 => pe_0_02,
					init_03 => pe_0_03, init_04 => pe_0_04, init_05 => pe_0_05,
					init_06 => pe_0_06, init_07 => pe_0_07, init_08 => pe_0_08,
					init_09 => pe_0_09, init_0a => pe_0_0a, init_0b => pe_0_0b,
					init_0c => pe_0_0c, init_0d => pe_0_0d, init_0e => pe_0_0e,
					init_0f => pe_0_0f)
	port map(addra => l_pc_e,	addrb => i_pm_adr(11 downto 2),
				clka => i_clk,		clkb => i_clk,
				dia => "0000",		dib => "0000",
				ena => l_wait_n,			enb => '1',
				rsta => '0',		rstb => '0',
				wea => '0',			web => '0',
				doa => m_opc_e(7 downto 4), dob => m_pmd_e(7 downto 4));
	pe_2 : ramb4_s4_s4 ---------------------------------------------------------
	generic map(init_00 => pe_0_00, init_01 => pe_0_01, init_02 => pe_0_02,
					init_03 => pe_0_03, init_04 => pe_0_04, init_05 => pe_0_05,
					init_06 => pe_0_06, init_07 => pe_0_07, init_08 => pe_0_08,
					init_09 => pe_0_09, init_0a => pe_0_0a, init_0b => pe_0_0b,
					init_0c => pe_0_0c, init_0d => pe_0_0d, init_0e => pe_0_0e,
					init_0f => pe_0_0f)
	port map(addra => l_pc_e,	addrb => i_pm_adr(11 downto 2),
				clka => i_clk,		clkb => i_clk,
				dia => "0000",		dib => "0000",
				ena => l_wait_n,			enb => '1',
				rsta => '0',		rstb => '0',
				wea => '0',			web => '0',
				doa => m_opc_e(11 downto 8), dob => m_pmd_e(11 downto 8));
	pe_3 : ramb4_s4_s4 ---------------------------------------------------------
	generic map(init_00 => pe_0_00, init_01 => pe_0_01, init_02 => pe_0_02,
					init_03 => pe_0_03, init_04 => pe_0_04, init_05 => pe_0_05,
					init_06 => pe_0_06, init_07 => pe_0_07, init_08 => pe_0_08,
					init_09 => pe_0_09, init_0a => pe_0_0a, init_0b => pe_0_0b,
					init_0c => pe_0_0c, init_0d => pe_0_0d, init_0e => pe_0_0e,
					init_0f => pe_0_0f)
	port map(addra => l_pc_e,	addrb => i_pm_adr(11 downto 2),
				clka => i_clk,		clkb => i_clk,
				dia => "0000",		dib => "0000",
				ena => l_wait_n,			enb => '1',
				rsta => '0',		rstb => '0',
				wea => '0',			web => '0',
				doa => m_opc_e(15 downto 12), dob => m_pmd_e(15 downto 12));
	po_0 : ramb4_s4_s4 ---------------------------------------------------------
	generic map(init_00 => pe_0_00, init_01 => pe_0_01, init_02 => pe_0_02,
					init_03 => pe_0_03, init_04 => pe_0_04, init_05 => pe_0_05,
					init_06 => pe_0_06, init_07 => pe_0_07, init_08 => pe_0_08,
					init_09 => pe_0_09, init_0a => pe_0_0a, init_0b => pe_0_0b,
					init_0c => pe_0_0c, init_0d => pe_0_0d, init_0e => pe_0_0e,
					init_0f => pe_0_0f)
	port map(addra => l_pc_e,	addrb => i_pm_adr(11 downto 2),
				clka => i_clk,		clkb => i_clk,
				dia => "0000",		dib => "0000",
				ena => l_wait_n,			enb => '1',
				rsta => '0',		rstb => '0',
				wea => '0',			web => '0',
				doa => m_opc_e(3 downto 0), dob => m_pmd_e(3 downto 0));
	po_1 : ramb4_s4_s4 ---------------------------------------------------------
	generic map(init_00 => pe_0_00, init_01 => pe_0_01, init_02 => pe_0_02,
					init_03 => pe_0_03, init_04 => pe_0_04, init_05 => pe_0_05,
					init_06 => pe_0_06, init_07 => pe_0_07, init_08 => pe_0_08,
					init_09 => pe_0_09, init_0a => pe_0_0a, init_0b => pe_0_0b,
					init_0c => pe_0_0c, init_0d => pe_0_0d, init_0e => pe_0_0e,
					init_0f => pe_0_0f)
	port map(addra => l_pc_e,	addrb => i_pm_adr(11 downto 2),
				clka => i_clk,		clkb => i_clk,
				dia => "0000",		dib => "0000",
				ena => l_wait_n,			enb => '1',
				rsta => '0',		rstb => '0',
				wea => '0',			web => '0',
				doa => m_opc_e(7 downto 4), dob => m_pmd_e(7 downto 4));
	po_2 : ramb4_s4_s4 ---------------------------------------------------------
	generic map(init_00 => pe_0_00, init_01 => pe_0_01, init_02 => pe_0_02,
					init_03 => pe_0_03, init_04 => pe_0_04, init_05 => pe_0_05,
					init_06 => pe_0_06, init_07 => pe_0_07, init_08 => pe_0_08,
					init_09 => pe_0_09, init_0a => pe_0_0a, init_0b => pe_0_0b,
					init_0c => pe_0_0c, init_0d => pe_0_0d, init_0e => pe_0_0e,
					init_0f => pe_0_0f)
	port map(addra => l_pc_e,	addrb => i_pm_adr(11 downto 2),
				clka => i_clk,		clkb => i_clk,
				dia => "0000",		dib => "0000",
				ena => l_wait_n,			enb => '1',
				rsta => '0',		rstb => '0',
				wea => '0',			web => '0',
				doa => m_opc_e(11 downto 8), dob => m_pmd_e(11 downto 8));
	po_3 : ramb4_s4_s4 ---------------------------------------------------------
	generic map(init_00 => pe_0_00, init_01 => pe_0_01, init_02 => pe_0_02,
					init_03 => pe_0_03, init_04 => pe_0_04, init_05 => pe_0_05,
					init_06 => pe_0_06, init_07 => pe_0_07, init_08 => pe_0_08,
					init_09 => pe_0_09, init_0a => pe_0_0a, init_0b => pe_0_0b,
					init_0c => pe_0_0c, init_0d => pe_0_0d, init_0e => pe_0_0e,
					init_0f => pe_0_0f)
	port map(addra => l_pc_e,	addrb => i_pm_adr(11 downto 2),
				clka => i_clk,		clkb => i_clk,
				dia => "0000",		dib => "0000",
				ena => l_wait_n,			enb => '1',
				rsta => '0',		rstb => '0',
				wea => '0',			web => '0',
				doa => m_opc_e(15 downto 12), dob => m_pmd_e(15 downto 12));

	pco_0 : process(i_clk)
	begin
		if (rising_edge(i_clk)) then
			q_pc <= i_pc;
			l_pm_adr_1_0 <= i_pm_adr(1 downto 0);
			if ((i_wait = '0')) then
				l_pc_0 <= i_pc(0);
			end if;
		end if;
	end process;
	
	l_wait_n <= not i_wait;

	l_pc_o <= i_pc(10 downto 1);
	l_pc_e <= i_pc(10 downto 1) + ("000000000" & i_pc(0));
	q_opc(15 downto 0) <= m_opc_e when l_pc_0 = '0' else m_opc_o;
	l_pmd <= m_pmd_e when (l_pm_adr_1_0(1) = '0') else m_pmd_o;
	q_pm_dout <= l_pmd(7 downto 0) when (l_pm_adr_1_0(0) = '0')
		else l_pmd(15 downto 8);
end behavioral;