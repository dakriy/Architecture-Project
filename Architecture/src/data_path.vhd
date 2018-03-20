library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_ARITH.all;
use ieee.std_logic_UNSIGNED.all;

use work.common.all;

entity data_path is
  port( i_clk     : in  std_logic;

        i_alu_op  : in  std_logic_vector(  4 downto 0 );
        --i_amod    : in  std_logic_vector(  5 downto 0 );
        --i_bit     : in  std_logic_vector(  3 downto 0 );
        i_ssss    : in  std_logic_vector(  3 downto 0 );
        i_din     : in  std_logic_vector(  7 downto 0 );
        i_imm     : in  std_logic_vector( 11 downto 0 );
        i_jadr    : in  std_logic_vector( 15 downto 0 );
        i_opc     : in  std_logic_vector( 15 downto 0 );
        i_pc      : in  std_logic_vector( 15 downto 0 );
        i_pc_op   : in  std_logic_vector(  2 downto 0 );
        i_pms     : in  std_logic; --program memory select
        i_rd_m    : in  std_logic;
        i_tttt    : in  std_logic_vector(  3 downto 0 );
        i_rsel    : in  std_logic_vector(  1 downto 0 );
        i_we_01   : in  std_logic;
        i_we_d    : in  std_logic_vector(  1 downto 0 );
        --i_we_f    : in  std_logic;
        i_we_m    : in  std_logic_vector(  1 downto 0 );

        q_adr     : out std_logic_vector( 15 downto 0 );
        q_dout    : out std_logic_vector(  7 downto 0 );
        q_int_ena : out std_logic;
        q_load_pc : out std_logic;
        q_new_pc  : out std_logic_vector( 15 downto 0 );
        q_opc     : out std_logic_vector( 15 downto 0 );
        q_pc      : out std_logic_vector( 15 downto 0 );
        q_rd_io   : out std_logic;
        --q_skip    : out std_logic;
        q_we_io   : out std_logic);
end data_path;

architecture behavioral of data_path is

component alu
  port( i_alu_op  : in  std_logic_vector(  4 downto 0 );
        i_bit     : in  std_logic_vector(  3 downto 0 );
        i_d       : in  std_logic_vector( 15 downto 0 );
        i_d0      : in  std_logic;
        i_din     : in  std_logic_vector(  7 downto 0 );
        i_flags   : in  std_logic_vector(  7 downto 0 );
        i_imm     : in  std_logic_vector(  7 downto 0 );
        i_pc      : in  std_logic_vector( 15 downto 0 );
        i_r       : in  std_logic_vector( 15 downto 0 );
        i_r0      : in  std_logic;
        i_rsel    : in  std_logic_vector(  1 downto 0 );

        q_flags   : in  std_logic_vector(  9 downto 0 );
        q_dout    : in  std_logic_vector( 15 downto 0 ));
end component;

signal a_dout  : std_logic_vector(15 downto 0);
signal a_flags : std_logic_vector(15 downto 0);

component register_file
  port( i_clk		: in std_logic;

				--i_amod      : in std_logic_vector( 5 downto 0)
				i_cond      : in std_logic_vector( 3 downto 0);
        i_ssss      : in std_logic_vector( 3 downto 0);
        i_din     : in std_logic_vector( 8 downto 0);
        i_flags   : in std_logic_vector( 7 downto 0);
        i_imm       : in std_logic_vector(15 downto 0);
        i_tttt      : in std_logic_vector( 3 downto 0);
        i_we_01     : in std_logic;
        i_we_d      : in std_logic_vector( 1 downto 0);
        i_we_f    : in std_logic;
        i_we_m      : in std_logic;

        q_adr       : out std_logic_vector(15 downto 0);
        q_cc        : out std_logic;
        q_d         : out std_logic_vector(15 downto 0);
        q_flags     : out std_logic_vector( 7 downto 0));
end component;

signal f_adr   : std_logic_vector(15 downto 0);
signal f_cc    : std_logic;
signal f_d     : std_logic_vector(15 downto 0);
signal f_flags : std_logic_vector(7 downto 0);
signal f_r     : std_logic_vector(15 downto 0);

component data_mem
port( i_clk  : in std_logic;
      i_adr  : in std_logic_vector(10 downto 0);
      i_din  : in std_logic_vector(15 downto 0);
      i_we   : in std_logic_vector( 1 downto 0);
      q_dout : out std_logic_vector(15 downto 0));
end component;

signal m_dout     : std_logic_vector(15 downto 0);
signal l_din      : std_logic_vector(7 downto 0);
signal l_we_sram  : std_logic_vector(1 downto 0);
signal l_flags_98 : std_logic_vector(9 downto 0);

begin
  alui:alui
  port map( i_alu_op  => i_alu_op,
        i_bit     => i_bit,
        i_d       => f_d,
        i_d0      => i_ssss(0),
        i_din     => l_din,
        i_flags   => f_flags
        i_imm     => i_imm,
        i_pc      => i_pc,
        i_r       => f_r,
        i_r0      => i_tttt(0),
        i_rsel    => i_rsel,

        q_flags   => a_flags,
        q_dout    => a_dout);
  regs:register_file
  port map( i_clk		=> i_clk,
					i_cond      => i_opc(3 downto 2),
          i_ssss      => i_ssss,
          i_din       => a_dout,
          i_flags     => a_flags,
          i_imm       => i_imm,
          i_tttt      => i_tttt(4 downto 1),
          i_we_01     => i_we_01,
          i_we_d      => i_we_d,
          --i_we_f    : in std_logic;
          i_we_m      => i_we_m(0),

          q_adr       => f_adr,
          q_cc        => f_cc,
          q_d         => f_d,
          q_flags     => f_flags;
--    sram:data_mem
--  port map( i_clk => i_clk,
  --          i_adr => f_adr(10 downto 0),
    --        i_din => a_dout,
      --      i_we => l_we_sram,
        --    q_dout => m_dout);
  flg98: process(i_clk)
  begin
    if (rising_edge(i_clk)) then
      l_flags_98 <= a_flags(9 downto 8);
    end if;
  end process;
  process(i_pc_op, f_cc)
  begin
    case i_pc_op is
      when pc_bcc => q_load_pc <= f_cc;
      when pc_ld_i => q_load_pc <= '1';
      when pc_ld_z => q_load_pc <= '1';
      when pc_ld_s => q_load_pc <= '1';
      when others => q_load_pc <= '0';
    end case;
  end process;

  q_adr <= f_adr;
  q_dout <= a_dout;
  q_int_ena <= a_flags;
  q_opc <= i_opc;
  q_pc <= i_pc;

  q_rd_io <= '0' when (f_adr <x"20")
    else (i_rd_m and not i_pms) when (f_adr<x"5d")
    else '0';
  q_we_io <= '0' when (f_adr <x"20")
    else i_we_m(0) when (f_adr <x"5d")
    else '0';
  l_we_sram <= "00" when (f_adr <x"0060") else i_we_m;
  l_din <= i_din when (i_pms = '1') < '1')
    else f_s when (f_adr < x"0020")
    else i_din when (f_adr < x"002d")
    else f_s when (f_adr < x"0060")
    else m_dout(7 downto 0);

  q_new_pc <= f_z when i_pc_op = pc_ld_z -- ijmp, icall
  else m_dout when i_pc_op = pc_ld_s -- ret, reti
  else i_jadr; --jmp address
end behavioral;
