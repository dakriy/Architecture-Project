library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

use work.common.all;

entity opcode_decoder is
	port(	i_clk  : in std_logic;

	        i_opc  : in  std_logic_vector( 15 downto 0 );
                i_pc   : in  std_logic_vector( 15 downto 0 );
                i_t0   : out std_logic;

        q_alu_op  : out std_logic_vector(  1 downto 0 );
        q_ssss    : out std_logic_vector(  3 downto 0 ); --Rs
        q_tttt    : out std_logic_vector(  3 downto 0 ); --Rt
        q_imm     : out std_logic_vector(  7 downto 0 ); --immediate value
        q_jadr    : out std_logic_vector(  7 downto 0 ); --branch/jump address
        q_opc     : out std_logic_vector( 15 downto 0 ); --opcode to be decoded
        q_pc      : out std_logic_vector( 15 downto 0 ); --program counter cor current opcode
        q_pc_op   : out std_logic_vector( 15 downto 0 ); --operation to be performed on pc
        q_rsel    : out std_logic_vector(  7 downto 0 );

        q_we_01   : out std_logic; --set when r00 is to be written (mult/div)
        q_we_d    : out std_logic_vector(  1 downto 0); --set when destination register is to be written
        --q_we_f    : out std_logic; --set when status register is to be written
        q_we_m    : out std_logic_ --set when memory is to be written
  );
end opcode_decoder;

architecture Behavioral of opcode_decoder is
begin
  process( i_clk )
  begin
    if (rising_edge(i_clk)) then
      --set the most common settings
      q_alu_op  <= alu_d_mv_q;
      q_ssss    <= i_opc(11 downto 8); --Rs in bits 11-8
      q_tttt    <= i_opc(7 downto 4); --Rt register in bits 7-4
      q_imm     <= i_opc(7 downto 0); --immediate value in bits 7-0
      q_jadr    <= i_opc(7 downto 0); --jump address in bits 7-0
      q_opc     <= i_opc; --opcode
      q_pc      <= i_pc; --current pc
      q_pc_op   <= pc_next; --next pc
      q_rsel    <= rs_reg;
      q_we_01   <= '0';
      q_we_d    <= "00";
      q_we_m    <= "00";

      case i_opc(15 downto 14) is
        when "00" =>
          --for R-Type commands
          --00xx dddd rrrr xxxx
          --$d will be changed
          q_we_d   <= "11";

          case i_opc(13 downto 12) is
            when "00" =>
              --add two registers
              --00xx dddd rrrr xxxx
              --$d = $d + $r
              q_alu_op <= alu_add;

            when "01" =>
              --and two registers (bitwise)
              --00xx dddd rrrr xxxx
              --$d = $d and $r
              q_alu_op <= alu_and;

            when "10" =>
              --or two registers (bitwise)
              --00xx dddd rrrr xxxx
              --$d = $d or $r
              q_alu_op <= alu_or;

            when "11" =>
              --move destination to temp
              --0011 dddd rrrr xxxx
              --$r = $d, $d = 0
              q_we_m   <= "11";
              q_alu_op <= alu_add;

            when others =>
            --no operation
          end case;

        when "01" =>
          --for I-Type commands
          --00xx dddd iiii iiii
          --$d will be changed
          q_we_d   <= "11";

          case i_opc(13 downto 12) is
            when "00" =>
            --shift destination left by immediate (4bit)
            --0011 dddd xxxx iiii
            --$d = $d << $i
            q_alu_op <= alu_sll;
