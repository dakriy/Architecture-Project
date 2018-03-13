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

entity program_mememory is
    port( i_clk     : in std_logic;

          i_wait    : in std_logic;
          i_pc      : in std_logic_vector( 15 downto 0 ); --16 bit register
          i_pm_addr : in std_logic_vector(  7 downto 0 ); --256 register space

          q_opc     : in std_logic_vector( 15 downto 0 ); --16bit opcode do be decoded
          q_pc      : in std_logic_vector( 15 downto 0 ); --16bit register
          q_pm_dout : in std_logic_vector(  7 downto 0 )); --256 register space
end program_mememory;
