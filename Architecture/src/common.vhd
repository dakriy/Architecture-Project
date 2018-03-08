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
  constant alu_sll   : std_logic_vector(3 downto 0) := "0100";
  constant alu_sla   : std_logic_vector(3 downto 0) := "0101";
  constant alu_sr    : std_logic_vector(3 downto 0) := "0110";
  constant alu_flip  : std_logic_vector(3 downto 0) := "0111";
  constant alu_andi  : std_logic_vector(3 downto 0) := "1000";
  constant alu_addi  : std_logic_vector(3 downto 0) := "1001";
  constant alu_ori   : std_logic_vector(3 downto 0) := "1010";
  constant alu_loadi : std_logic_vector(3 downto 0) := "1011";
  constant alu_j     : std_logic_vector(3 downto 0) := "1100";
  constant alu_jz    : std_logic_vector(3 downto 0) := "1101";

  --
  --constant alu_nop   : std_logic_vector(3 downto 0) := "1111";

  -----------------------------------------------------------------------
  -- PC manipulations
  --
  constant pc_next   : std_logic := '0';
  constant pc_bcc    : std_logic := '1';

  -----------------------------------------------------------------------
  -- ALU multiplexers
  --
  constant rs_reg    : std_logic_vector(1 downto 0) := "00";
  constant rs_imm    : std_logic_vector(1 downto 0) := "01";
  constant rs_din    : std_logic_vector(1 downto 0) := "10";

  -----------------------------------------------------------------------

end common;
