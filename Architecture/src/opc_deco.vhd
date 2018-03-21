-------------------------------------------------------------------------------
-- 
-- copyright (c) 2009, 2010 dr. juergen sauermann
-- 
--  this code is free software: you can redistribute it and/or modify
--  it under the terms of the gnu general public license as published by
--  the free software foundation, either version 3 of the license, or
--  (at your option) any later version.
--
--  this code is distributed in the hope that it will be useful,
--  but without any warranty; without even the implied warranty of
--  merchantability or fitness for a particular purpose.  see the
--  gnu general public license for more details.
--
--  you should have received a copy of the gnu general public license
--  along with this code (see the file named copying).
--  if not, see http://www.gnu.org/licenses/.
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- module name:    opc_deco - behavioral 
-- create date:    16:05:16 10/29/2009 
-- description:    the opcode decoder of a cpu.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.common.all;

entity opc_deco is
    port (  i_clk       : in  std_logic;

            i_opc       : in  std_logic_vector(15 downto 0);
            i_pc        : in  std_logic_vector(15 downto 0);
            i_t0        : in  std_logic;

            q_alu_op    : out std_logic_vector( 3 downto 0);
            q_amod      : out std_logic_vector( 5 downto 0);
            q_bit       : out std_logic_vector( 3 downto 0);
            q_ddddd     : out std_logic_vector( 3 downto 0);
            q_imm       : out std_logic_vector( 7 downto 0);
            q_jadr      : out std_logic_vector( 7 downto 0);
            q_opc       : out std_logic_vector(15 downto 0);
            q_pc        : out std_logic_vector(15 downto 0);
            q_pc_op     : out std_logic_vector( 2 downto 0);
            q_pms       : out std_logic;  -- program memory select
            q_rd_m      : out std_logic;
            q_rrrrr     : out std_logic_vector( 3 downto 0);
            q_rsel      : out std_logic_vector( 1 downto 0);
            q_we_01     : out std_logic;
            q_we_d      : out std_logic_vector( 1 downto 0);
            q_we_f      : out std_logic;
            q_we_m      : out std_logic_vector( 1 downto 0);
            q_we_xyzs   : out std_logic);
end opc_deco;

architecture behavioral of opc_deco is

begin

    process(i_clk)
    begin
    if (rising_edge(i_clk)) then
        --
        -- set the most common settings as default.
        --
        q_alu_op  <= alu_mov;
        q_amod    <= amod_abs;
--        q_bit     <= i_opc(10) & i_opc(2 downto 0);
        q_ddddd   <= i_opc(11 downto 8);
        q_imm     <= i_opc(7 downto 0);
        q_jadr    <= i_opc(7 downto 0);
        q_opc     <= i_opc(15 downto  0);
        q_pc      <= i_pc;
        q_pc_op   <= pc_next;
        q_pms     <= '0';
        q_rd_m    <= '0';
        q_rrrrr   <= i_opc(7 downto 4);
        q_rsel    <= rs_reg;
        q_we_d    <= "00";
        q_we_01   <= '0';
        q_we_f    <= '0';
        q_we_m    <= "00";
        q_we_xyzs <= '0';

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
						if (i_opc(3 downto 2) = "01") then
							q_we_m <= "11";
							q_we_d <= "00";
						else
							q_we_d <= "11";
							q_we_m <= "00";
						end if;	
					when others =>		--NOP
				end case;

			when ("01" or "10") =>		--I-type commands
				--(01xx) or (10xx) ssss iiii iiii
				--$d will be changed
				q_we_d   <= "11";

				case i_opc(14 downto 12) is
				    --First half of I-type commands starting with "01"
					when "100" =>		--SRL
						--shift destination right by immediate and shift in zeros (4bit)
						--0100 ssss xxxx iiii
						--$d = $d >> $i
						q_alu_op <= alu_srl;

				  when "101" =>		--SRA
						--shift destination right by immediate and shift in sign bit (4bit)
						--0100 ssss xxxx iiii
						--$d = $d >> $i
						q_alu_op <= alu_sra;

					when "110" =>		--SL
						--shift destination left by immediate (4bit)
						--0110 ssss xxxx iiii
						--$d = $d << $i
						q_alu_op <= alu_sl;

					when "111" =>		--NOT
						--not all bits
						--0111 ssss xxxx xxxx
						q_alu_op <= alu_not;

                    --Second half of I-type commands starting with "10"
                    when "000" =>		--ANDI
                        --and a register with an immediate
                        --1000 ssss iiii iiii
                        --$s = $s and i
                        q_alu_op <= alu_andi;

                    when "001" =>		--ADDI
                        --add a register with an immediate
                        --1001 ssss iiii iiii
                        --$s = $s + i
                        q_alu_op <= alu_addi;

                    when "010" =>		--ORI
						--or a register with an immediate
						--1010 ssss iiii iiii
						--$s = $s or i
						q_alu_op <= alu_ori;

                    when "011" =>		--LOADI
                        --load an immediate into a register
                        --1011 ssss iiii iiii
                        --$s = i
                        q_alu_op <= alu_loadi;

					when others =>		--NOP
				end case;

			 when "11" =>		--J-type instructions and others
				--11xx ssss iiii iiii
				q_we_d <= "00";

				case i_opc(13 downto 12) is
             when "00" =>		--JZ
						--jump when given register equals zero
						--1100 ssss iiii iiii
						q_alu_op <= alu_jz;
						

             when "01" =>		--J
                        --jump unconditionally
                        --1101 iiii iiii iiii
                        q_alu_op <= alu_j;

             when others =>      --NOP
				 
           end case;
			  when others =>
			  
			end case;
		end if;
    end process;

end behavioral;