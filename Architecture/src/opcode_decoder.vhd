library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

use work.common.all;

entity opcode_decoder is
	port(	i_clk  : in std_logic;

	        i_opc  : in  std_logic_vector( 15 downto 0 );
                i_pc   : in  std_logic_vector( 15 downto 0 );
                --i_t0   : out std_logic;

        q_alu_op  : out std_logic_vector(  1 downto 0 );
        q_ssss    : out std_logic_vector(  3 downto 0 ); --Rs
        q_tttt    : out std_logic_vector(  3 downto 0 ); --Rt
        q_imm     : out std_logic_vector(  7 downto 0 ); --immediate value (offset from PC for jumps)
        q_jadr    : out std_logic_vector( 11 downto 0 ); --branch/jump address (byte addressed) 
        q_opc     : out std_logic_vector( 15 downto 0 ); --opcode to be decoded
        q_pc      : out std_logic_vector( 15 downto 0 ); --program counter for current opcode
        q_pc_op   : out std_logic_vector( 15 downto 0 ); --operation to be performed on pc
        q_rsel    : out std_logic_vector(  7 downto 0 ); --register select

        q_we_d    : out std_logic_vector(  1 downto 0); --set when Rs is to be written
        q_we_m    : out std_logic_vector(  1 downto 0); --set when memory is to be written
  );
end opcode_decoder;

architecture Behavioral of opcode_decoder is
begin
  process( i_clk )
  begin
    if (rising_edge(i_clk)) then
      --set the most common settings
      q_alu_op  <= alu_d_mv_q;
      q_ssss    <= i_opc( 11 downto 8); --Rs in bits 11-8
      q_tttt    <= i_opc(  7 downto 4); --Rt register in bits 7-4
      q_imm     <= i_opc(  7 downto 0); --immediate value in bits 7-0
      q_jadr    <= i_opc( 11 downto 0); --jump address in bits 11-0
      q_opc     <= i_opc; --opcode
      q_pc      <= i_pc; --current pc
      q_pc_op   <= pc_next; --next pc
      q_rsel    <= rs_reg; -- Choose what type of data to send to the ALU
      q_we_d    <= "00";	-- For writing to register
      q_we_m    <= "00";	-- For writing to memory 

      case i_opc(15 downto 14) is
			when "00" =>		--R-type commands
				--00xx ssss tttt xxxx
				--$d will be changed
				q_we_d   <= "11";

				case i_opc(13 downto 12) is
					when "00" =>		--ADD
						--add two registers
						--0000 ssss tttt xxxx
						--$d = $d + $r
						q_alu_op <= alu_add;

					when "01" =>		--AND
						--and two registers (bitwise)
						--0001 ssss tttt xxxx
						--$s = $s and $t
						q_alu_op <= alu_and;

					when "10" =>		--OR
						--or two registers (bitwise)
						--0010 ssss tttt xxxx
						--$s = $s or $t
						q_alu_op <= alu_or;

					when "11" =>		--MOV
						--move Rt to Rs
						--0011 ssss tttt xxxx
						--$s = $t, $t = 0
						q_we_m   <= "11";
						q_alu_op <= alu_mov;

					when others =>		--NOOP
				end case;

			when "01" =>		--first half of I-type commands
				--01xx ssss iiii iiii
				--$d will be changed
				q_we_d   <= "11";

				case i_opc(13 downto 12) is
					when "00" =>		--SLL
						--shift destination left by immediate (4bit)
						--0100 ssss xxxx iiii
						--$d = $d << $i
						q_alu_op <= alu_sll;

					-- SLL and SLA are the same thing. Why do we have both?
					--				when "01" =>		--SLA
					--            --shift destination left by immediate (4bit)
					--            --0101 ssss xxxx iiii
					--            --$d = $d << $i
					--            q_alu_op <= alu_sla;

					when "10" =>		--SR
						--shift destination right by immediate shifting in sign bit (4bit)
						--0110 ssss xxxx iiii
						--$d = $d >> $i
						q_alu_op <= alu_sr;

					when "11" =>		--FLIP
						--flip all bits
						--0111 ssss xxxx xxxx
						q_alu_op <= alu_flip;

					when others =>		--NOOP
				end case;
			
			when "10" =>		--second half of I-type commands
				--10xx ssss iiii iiii
				--$s will be changed
				q_we_d   <= "11";
				
				case i_opc(13 downto 12) is
					when "00" =>		--ANDI
						--and a register with an immediate
						--1000 ssss iiii iiii
						--$s = $s and i
						q_alu_op <= alu_andi;
						
					when "01" =>		--ADDI
						--add a register with an immediate
						--1001 ssss iiii iiii
						--$s = $s + i
						q_alu_op <= alu_addi;
						
					when "10" =>		--ORI
						--or a register with an immediate
						--1010 ssss iiii iiii
						--$s = $s or i
						q_alu_op <= alu_ori;						
			
					when "11" =>		--LOADI
						--load an immediate into a register
						--1011 ssss iiii iiii
						--$s = i
						q_alu_op <= alu_loadi;
						
					when others =>		--NOOP
				end case;
				
			when "11" =>		--J-type instructions
				--11xx ssss iiii iiii
				
				case