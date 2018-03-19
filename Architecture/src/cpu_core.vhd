-------------------------------------------------------------------------------
--
-- Module Name:     cpu_core
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     the instruction set implementation of a CPU.
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity cpu_core is
  port( i_clk       : in  std_logic; --global clock
        i_reset     : in  std_logic;
        i_din       : in  std_logic_vector(  7 downto 0 ); --input data (pmem or i/o)

        q_opc       : out std_logic_vector( 15 downto 0 ); --current opcode
        q_pc        : out std_logic_vector( 15 downto 0 ); --current program counter
        q_dout      : out std_logic_vector(  7 downto 0 ); --output data
        q_adr_io    : out std_logic_vector(  4 downto 0 ); --address of i/o register (16 16-bit registers)
        q_rd_io     : out std_logic; --select register to read
        q_we_io     : out std_logic); --select register to write
end cpu_core;

architecture Behavioral of cpu_core is
component opc_fetch
  port( i_clk       : in std_logic;

        i_reset     : in std_logic_vector( 5 downto 0);
        i_new_pc    : in std_logic_vector(15 downto 0);
        i_load_pc   : in std_logic;
        i_pm_addr   : in std_logic_vector(11 downto 0);
        q_opc       : out std_logic_vector(31 downto 0);
        q_pc        : out std_logic_vector(15 downto 0);
        q_pm_dout   : out std_logic_vector( 7 downto 0);
        q_t0        : out std_logic);
end component;

signal f_pc     : std_logic_vector(15 downto 0);
signal f_opc    : std_logic_vector(31 downto 0);
signal f_t0     : std_logic;

component opc_deco is
    port (  i_clk       : in std_logic;
            i_opc       : in std_logic_vector(31 downto 0);
            i_pc        : in std_logic_vector(15 downto 0);
            i_t0        : in std_logic;
            q_alu_op    : out std_logic_vector( 4 downto 0);
            q_bit       : out std_logic_vector( 3 downto 0);
            q_ssss      : out std_logic_vector( 3 downto 0);
            q_imm       : out std_logic_vector(15 downto 0);
            q_jadr      : out std_logic_vector(15 downto 0);
            q_opc       : out std_logic_vector(15 downto 0);
            q_pc        : out std_logic_vector(15 downto 0);
            q_pc_op     : out std_logic_vector( 2 downto 0);
            q_pms       : out std_logic; -- program memory select
            q_rd_m      : out std_logic;
            q_tttt      : out std_logic_vector( 3 downto 0);
            q_rsel      : out std_logic_vector( 1 downto 0);
            q_we_01     : out std_logic;
            q_we_d      : out std_logic_vector( 1 downto 0);
            q_we_f      : out std_logic;
            q_we_m      : out std_logic_vector( 1 downto 0));
end component;

signal d_alu_op : std_logic_vector( 4 downto 0);
signal d_amod   : std_logic_vector( 5 downto 0);
signal d_bit    : std_logic_vector( 3 downto 0);
signal d_ssss   : std_logic_vector( 3 downto 0);
signal d_imm    : std_logic_vector(15 downto 0);
signal d_jadr   : std_logic_vector(15 downto 0);
signal d_opc    : std_logic_vector(15 downto 0);
signal d_pc     : std_logic_vector(15 downto 0);
signal d_pc_op  : std_logic_vector( 2 downto 0);
signal d_pms    : std_logic;
signal d_rd_m   : std_logic;
signal d_tttt   : std_logic_vector( 3 downto 0);
signal d_rsel   : std_logic_vector( 1 downto 0);
signal d_we_01  : std_logic;
signal d_we_d   : std_logic_vector( 1 downto 0);
signal d_we_f   : std_logic;
signal d_we_m   : std_logic_vector( 1 downto 0);

component data_path
    port(   i_clk       : in std_logic;
            i_alu_op    : in std_logic_vector( 4 downto 0);
            i_amod      : in std_logic_vector( 5 downto 0);
            i_bit       : in std_logic_vector( 3 downto 0);
            i_ssss      : in std_logic_vector( 3 downto 0);
            i_din       : in std_logic_vector( 7 downto 0);
            i_imm       : in std_logic_vector(15 downto 0);
            i_jadr      : in std_logic_vector(15 downto 0);
            i_pc_op     : in std_logic_vector( 2 downto 0);
            i_opc       : in std_logic_vector(15 downto 0);
            i_pc        : in std_logic_vector(15 downto 0);
            i_pms       : in std_logic; -- program memory select
            i_rd_m      : in std_logic;
            i_tttt      : in std_logic_vector( 3 downto 0);
            i_rsel      : in std_logic_vector( 1 downto 0);
            i_we_01     : in std_logic;
            i_we_d      : in std_logic_vector( 1 downto 0);
            i_we_f      : in std_logic;
            i_we_m      : in std_logic_vector( 1 downto 0);
            q_adr       : out std_logic_vector(15 downto 0);
            q_dout      : out std_logic_vector( 7 downto 0);
            q_load_pc   : out std_logic;
            q_new_pc    : out std_logic_vector(15 downto 0);
            q_opc       : out std_logic_vector(15 downto 0);
            q_pc        : out std_logic_vector(15 downto 0);
            q_rd_io     : out std_logic;
            q_we_io     : out std_logic);
end component;

signal r_new_pc : std_logic_vector(15 downto 0);
signal r_load_pc: std_logic;
signal r_adr    : std_logic_vector(15 downto 0);

-- local signals
signal l_din            : std_logic_vector( 7 downto 0);

begin
    opcf : opc_fetch
    port map(   i_clk               => i_clk,
                i_clr               => i_clr,
                i_load_pc           => r_load_pc,
                i_new_pc            => r_new_pc,
                i_pm_adr            => r_adr(11 downto 0),
                q_pc                => f_pc,
                q_opc               => f_opc,
                q_t0                => f_t0,
                q_pm_dout           => f_pm_dout);

    opcf : opc_deco
    port map(   i_clk               => i_clk,
                i_opc       => f_opc,
                i_pc        => f_pc,
                i_t0        => f_t0,
                q_alu_op    => d_alu_op,
                q_bit       => d_bit,
                q_ssss      => d_ssss,
                q_imm       => d_imm,
                q_jadr      => d_jadr,
                q_opc       => d_opc,
                q_pc        => d_pc,
                q_pc_op     => d_pc_op,
                q_pms       => d_pms,
                q_rd_m      => d_rd_m,
                q_tttt      => d_tttt,
                q_rsel      => d_rsel,
                q_we_01     => d_we_01,
                q_we_d      => d_we_d,
                q_we_f      => d_we_f,
                q_we_m      => d_we_m);

    dpath : data_path
    port map(   i_clk       => i_clk,
                i_alu_op    => d_alu_op,
                i_bit       => d_bit,
                i_ssss      => d_ssss,
                i_din       => l_din,
                i_imm       => d_imm,
                i_jadr      => d_jadr,
                i_opc       => d_opc,
                i_pc        => d_pc,
                i_pc_op     => d_pc_op,
                i_pms       => d_pms,
                i_rd_m      => d_rd_m,
                i_tttt      => d_tttt,
                i_rsel      => d_rsel,
                i_we_01     => d_we_01,
                i_we_d      => d_we_d,
                i_we_f      => d_we_f,
                i_we_m      => d_we_m,
                q_adr       => r_adr,
                q_dout      => q_dout,
                q_new_pc    => r_new_pc,
                q_opc       => q_opc,
                q_pc        => q_pc,
                q_load_pc   => r_load_pc,
                q_rd_io     => q_rd_io,
                q_we_io     => q_we_io);


    l_din       <= f_pm_dout when (d_pms = '1') else i_din(7 downto 0); --mux selects between pmem and i/o
    q_adr_io    <= r_adr(7 downto 0);

end Behavioral;