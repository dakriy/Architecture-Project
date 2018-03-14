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
  port( i_clk     : in  std_logic; --global clock
        i_reset   : in  std_logic;
        --i_intvec  : in  std_logic_vector(  5 downto 0 ); --interrupt vector input
        i_din     : in  std_logic_vector(  7 downto 0 ); --input data (pmem or i/o)

        q_opc     : out std_logic_vector( 15 downto 0 ); --current opcode
        q_pc      : out std_logic_vector( 15 downto 0 ); --current program counter
        q_dout    : out std_logic_vector(  7 downto 0 ); --output data
        q_adr_io  : out std_logic_vector(  5 downto 0 ); --address of i/o register (32 8-bit registers)
        q_rd_io   : out std_logic; --select register to read
        q_we_io   : out std_logic); --select register to write
end cpu_core;

architecture Behavioral of cpu_core is
component opc_fetch
  port(
        i_clk     : in std_logic;

        i_reset   : in std_logic_vector(  5 downto 0 );
        i_intvec  : in std_logic_vector( 15 downto 0 );
        i_new_pc  : in std_logic_vector( 15 downto 0 );
        i_load_pc : in std_logic;
        i_pm_addr : in
  );


l_din     <= f_pm_dout when (d_pms = '1') else i_din(7 downto 0); --mux selects between pmem and i/o
l_intvec  <= i_intvec(5) and r_int_ena;
