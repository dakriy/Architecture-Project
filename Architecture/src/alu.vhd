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
-- module name:    alu - behavioral 
-- create date:    13:51:24 11/07/2009 
-- description:    arithmetic logic unit of a cpu
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.common.all;

entity alu is
    port (  i_alu_op    : in  std_logic_vector( 3 downto 0);
            i_bit       : in  std_logic_vector( 3 downto 0);
            i_d         : in  std_logic_vector(15 downto 0);
            i_d0        : in  std_logic;
            i_din       : in  std_logic_vector( 7 downto 0);
            i_flags     : in  std_logic_vector( 7 downto 0);
            i_imm       : in  std_logic_vector( 7 downto 0);
            i_pc        : in  std_logic_vector(15 downto 0);
            i_r         : in  std_logic_vector(15 downto 0);
            i_rsel      : in  std_logic_vector( 1 downto 0);

            q_flags     : out std_logic_vector( 9 downto 0);
            q_dout      : out std_logic_vector(15 downto 0));
end alu;

architecture behavioral of alu is

function ze(a: std_logic_vector(7 downto 0)) return std_logic is
begin
    return not (a(0) or a(1) or a(2) or a(3) or
                a(4) or a(5) or a(6) or a(7));
end;

function cy_add(rd, rr, r: std_logic) return std_logic is
begin
    return (rd and rr) or (rd and (not r)) or ((not r) and rr);
end;

function ov_add(rd, rr, r: std_logic) return std_logic is
begin
    return (rd and rr and (not r)) or ((not rd) and (not rr) and r);
end;

function si_add(rd, rr, r: std_logic) return std_logic is
begin
    return r xor ov_add(rd, rr, r);
end;

function cy_sub(rd, rr, r: std_logic) return std_logic is
begin
    return ((not rd) and rr) or (rr and r) or (r and (not rd));
end;

function ov_sub(rd, rr, r: std_logic) return std_logic is
begin
    return (rd and (not rr) and (not r)) or ((not rd) and rr and r);
end;

function si_sub(rd, rr, r: std_logic) return std_logic is
begin
    return r xor ov_sub(rd, rr, r);
end;

--signal l_adc_dr     : std_logic_vector( 7 downto 0);    -- d + r + carry
signal l_add_dr     : std_logic_vector( 7 downto 0);    -- d + r
signal l_addi_d     : std_logic_vector(15 downto 0);    -- d + imm
signal l_and_dr     : std_logic_vector( 7 downto 0);    -- d and r
signal l_andi_d     : std_logic_vector( 7 downto 0);    -- d and imm
signal l_sra_d      : std_logic_vector( 7 downto 0);    -- (signed d) >> 1
signal l_srl_d      : std_logic_vector( 7 downto 0);    -- (signed d) >> 1
signal l_d8         : std_logic_vector( 7 downto 0);    -- d(7 downto 0)
signal l_dout       : std_logic_vector(15 downto 0);
signal l_sl_d      : std_logic_vector( 7 downto 0);    -- (unsigned) d >> 1
signal l_not_d      : std_logic_vector( 7 downto 0);    -- 0 not d
signal l_or_dr      : std_logic_vector( 7 downto 0);    -- d or r
signal l_r8         : std_logic_vector( 7 downto 0);    -- odd or even r
signal l_ri8        : std_logic_vector( 7 downto 0);    -- r8 or imm
signal l_rbit       : std_logic;
signal l_sign_d     : std_logic;
signal l_sign_r     : std_logic;
signal l_mov_dr     : std_logic_vector(15 downto 0);    -- d moved to r
signal l_loadi		  : std_logic_vector( 7 downto 0);    -- copy imm to d
signal l_pc			  : std_logic_vector(15 downto 0);    -- pc
begin

    process(l_add_dr, l_addi_d, i_alu_op, l_and_dr, l_sra_d,
            i_bit, i_d, l_d8, i_din, i_flags, i_imm,
            l_sl_d, l_not_d, l_or_dr, i_pc, l_andi_d,
            i_r, l_ri8, l_rbit, l_sign_d, l_sign_r, l_mov_dr)
    begin
        --q_flags(9) <= l_rbit xor not i_bit(3);      -- din[bit] = bit[3]
        --q_flags(8) <= ze(l_sub_dr);                 -- d == r for cpse
        q_flags(7 downto 0) <= i_flags;
        l_dout <= x"0000";

        case i_alu_op is
            when alu_add =>
                l_dout <= l_add_dr & l_add_dr;
                q_flags(0) <= cy_add(l_d8(7), l_ri8(7), l_add_dr(7));-- carry
                q_flags(1) <= ze(l_add_dr);                          -- zero
                q_flags(2) <= l_add_dr(7);                           -- negative
                q_flags(3) <= ov_add(l_d8(7), l_ri8(7), l_add_dr(7));-- overflow
                q_flags(4) <= si_add(l_d8(7), l_ri8(7), l_add_dr(7));-- signed
                q_flags(5) <= cy_add(l_d8(3), l_ri8(3), l_add_dr(3));-- halfcarry
					 l_ri8 <= l_r8;
					 
            when alu_addi =>
                l_dout <= l_addi_d;
                q_flags(0) <= l_addi_d(15) and not i_d(15);         -- carry
                q_flags(1) <= ze(l_addi_d(15 downto 8)) and
                              ze(l_addi_d(7 downto 0));             -- zero
                q_flags(2) <= l_addi_d(15);                         -- negative
                q_flags(3) <= i_d(15) and not l_addi_d(15);         -- overflow
                q_flags(4) <= (l_addi_d(15) and not i_d(15))
                          xor (i_d(15) and not l_addi_d(15));       -- signed
                l_ri8 <= i_imm;
					 
            when alu_and =>
                l_dout <= l_and_dr & l_and_dr;
                q_flags(1) <= ze(l_and_dr);                         -- zero
                q_flags(2) <= l_and_dr(7);                          -- negative
                q_flags(3) <= '0';                                  -- overflow
                q_flags(4) <= l_and_dr(7);                          -- signed
					 l_ri8 <= l_r8;
					 
            when alu_andi =>
                l_dout <= l_andi_d & l_andi_d;
                q_flags(1) <= ze(l_andi_d);                         -- zero
                q_flags(2) <= l_andi_d(7);                          -- negative
                q_flags(3) <= '0';                                  -- overflow
                q_flags(4) <= l_andi_d(7);                          -- signed
					 l_ri8 <= i_imm;
					 
            when alu_sra =>
                l_dout <= l_srl_d & l_srl_d;
                q_flags(0) <= l_d8(0);                              -- carry
                q_flags(1) <= ze(l_sra_d);                          -- zero
                q_flags(2) <= l_d8(7);                              -- negative
                q_flags(3) <= l_d8(0) xor l_d8(7);                  -- overflow
                q_flags(4) <= l_d8(0);                              -- signed

				when alu_srl =>
                l_dout <= l_sra_d & l_sra_d;
                q_flags(0) <= l_d8(0);                              -- carry
                q_flags(1) <= ze(l_sra_d);                          -- zero
                q_flags(2) <= l_d8(7);                              -- negative
                q_flags(3) <= l_d8(0) xor l_d8(7);                  -- overflow
                q_flags(4) <= l_d8(0);                              -- signed

            when alu_not =>
                l_dout <= l_not_d & l_not_d;
                q_flags(0) <= '1';                                  -- carry
                q_flags(1) <= ze(not l_d8);                         -- zero
                q_flags(2) <= not l_d8(7);                          -- negative
                q_flags(3) <= '0';                                  -- overflow
                q_flags(4) <= not l_d8(7);                          -- signed

            when alu_sl  =>
                l_dout <= l_sl_d & l_sl_d;
                q_flags(0) <= l_d8(0);                              -- carry
                q_flags(1) <= ze(l_sl_d);                          -- zero
                q_flags(2) <= '0';                                  -- negative
                q_flags(3) <= l_d8(0);                              -- overflow
                q_flags(4) <= l_d8(0);                              -- signed

            when alu_mov =>
                l_dout <= i_d;
                
            when alu_or =>
                l_dout <= l_or_dr & l_or_dr;
                q_flags(1) <= ze(l_or_dr);                          -- zero
                q_flags(2) <= l_or_dr(7);                           -- negative
                q_flags(3) <= '0';                                  -- overflow
                q_flags(4) <= l_or_dr(7);                           -- signed
					 l_ri8 <= l_r8;
				
				when alu_ori =>
                l_dout <= l_or_dr & l_or_dr;
                q_flags(1) <= ze(l_or_dr);                          -- zero
                q_flags(2) <= l_or_dr(7);                           -- negative
                q_flags(3) <= '0';                                  -- overflow
                q_flags(4) <= l_or_dr(7);                           -- signed
					 l_ri8 <= i_imm;
					 
				when alu_loadi =>
					 l_dout <= i_imm & i_imm;
					 
            when others =>
        end case;
    end process;
    
    l_d8 <= i_d(7 downto 0);
    l_r8 <= i_r(7 downto 0);

    l_add_dr  <= l_d8 + l_ri8;
    l_sra_d   <= l_d8(7) & l_d8(7 downto 1);
    l_and_dr  <= l_d8 and l_ri8;
    l_sl_d   <= l_d8(6 downto 0) & '0';
    l_srl_d  <= '0' & l_d8(7 downto 1);
	 l_not_d   <= not l_d8;
    l_or_dr   <= l_d8 or l_ri8;
	 l_mov_dr  <= i_d;

    q_dout <= (i_din & i_din) when (i_rsel = rs_din) else l_dout;

end behavioral;