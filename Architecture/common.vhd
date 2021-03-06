-------------------------------------------------------------------------------
--
-- Module Name:     common
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     constants shared by different modules.
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package common is
  -----------------------------------------------------------------------
  -- ALU operations
  --
  constant alu_add   : std_logic_vector(3 downto 0) := "0000";
  constant alu_and   : std_logic_vector(3 downto 0) := "0001";
  constant alu_or    : std_logic_vector(3 downto 0) := "0010";
  constant alu_mov   : std_logic_vector(3 downto 0) := "0011"; --
  constant alu_srl   : std_logic_vector(3 downto 0) := "0100";
  constant alu_sra   : std_logic_vector(3 downto 0) := "0101";
  constant alu_sl    : std_logic_vector(3 downto 0) := "0110";
  constant alu_not   : std_logic_vector(3 downto 0) := "0111";
  constant alu_andi  : std_logic_vector(3 downto 0) := "1000";
  constant alu_addi  : std_logic_vector(3 downto 0) := "1001";
  constant alu_ori   : std_logic_vector(3 downto 0) := "1010";
  constant alu_loadi : std_logic_vector(3 downto 0) := "1011";
  constant alu_jz    : std_logic_vector(3 downto 0) := "1100";
  constant alu_j     : std_logic_vector(3 downto 0) := "1101";

  --
  --constant alu_nop   : std_logic_vector(3 downto 0) := "1111";

  -----------------------------------------------------------------------
  -- PC manipulations
  --
  constant pc_next   : std_logic_vector(1 downto 0) := "00";
  constant pc_bcc    : std_logic_vector(1 downto 0) := "10";
  constant pc_ld_i   : std_logic_vector(1 downto 0) := "11";

  -----------------------------------------------------------------------
  -- ALU multiplexers
  --
  constant rs_reg    : std_logic_vector(1 downto 0) := "00";
  constant rs_imm    : std_logic_vector(1 downto 0) := "01";
  constant rs_din    : std_logic_vector(1 downto 0) := "10";

  -----------------------------------------------------------------------

end common;
