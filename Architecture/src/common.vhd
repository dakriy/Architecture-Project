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
-- module name:    common
-- create date:    13:51:24 11/07/2009 
-- description:    constants shared by different modules.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

package common is

    -----------------------------------------------------------------------

    -- alu operations
    --
    constant alu_add    : std_logic_vector(3 downto 0) := "0000";
    constant alu_and    : std_logic_vector(3 downto 0) := "0001";
    constant alu_or     : std_logic_vector(3 downto 0) := "0010";  
    constant alu_mov    : std_logic_vector(3 downto 0) := "0011";
    
	 constant alu_srl    : std_logic_vector(3 downto 0) := "0100";  
    constant alu_sra    : std_logic_vector(3 downto 0) := "0101";
    constant alu_sl     : std_logic_vector(3 downto 0) := "0110";  
    constant alu_not    : std_logic_vector(3 downto 0) := "0111";
    constant alu_andi   : std_logic_vector(3 downto 0) := "1000";
    constant alu_addi   : std_logic_vector(3 downto 0) := "1001";
    constant alu_ori    : std_logic_vector(3 downto 0) := "1010";
    constant alu_loadi  : std_logic_vector(3 downto 0) := "1011";
	 
	 constant alu_jz     : std_logic_vector(3 downto 0) := "1100";
	 constant alu_j      : std_logic_vector(3 downto 0) := "1101";
	 

    -----------------------------------------------------------------------
    --
    -- pc manipulations
    --
    constant pc_next    : std_logic_vector(2 downto 0) := "000";    -- pc += 1
    constant pc_bcc     : std_logic_vector(2 downto 0) := "001";    -- pc ?= imm
    constant pc_ld_i    : std_logic_vector(2 downto 0) := "010";    -- pc = imm
    constant pc_ld_z    : std_logic_vector(2 downto 0) := "011";    -- pc = z
    constant pc_ld_s    : std_logic_vector(2 downto 0) := "100";    -- pc = (sp)
    constant pc_skip_z  : std_logic_vector(2 downto 0) := "101";    -- skip if z
    constant pc_skip_t  : std_logic_vector(2 downto 0) := "110";    -- skip if t
 
    -----------------------------------------------------------------------
    --
    -- addressing modes. an address mode consists of two sub-fields,
    -- which are the source of the address and an offset from the source.
    -- bit 3 indicates if the address will be modified.

    -- address source
    constant as_sp  : std_logic_vector(2 downto 0) := "000";     -- sp
    constant as_z   : std_logic_vector(2 downto 0) := "001";     -- z
    constant as_y   : std_logic_vector(2 downto 0) := "010";     -- y
    constant as_x   : std_logic_vector(2 downto 0) := "011";     -- x
    constant as_imm : std_logic_vector(2 downto 0) := "100";     -- imm

    -- address offset
    constant ao_0   : std_logic_vector(5 downto 3) := "000";     -- as is
    constant ao_q   : std_logic_vector(5 downto 3) := "010";     -- +q
    constant ao_i   : std_logic_vector(5 downto 3) := "001";     -- +1
    constant ao_ii  : std_logic_vector(5 downto 3) := "011";     -- +2
    constant ao_d   : std_logic_vector(5 downto 3) := "101";     -- -1
    constant ao_dd  : std_logic_vector(5 downto 3) := "111";     -- -2
    --                                                   |
    --                                                +--+
    -- address updated ?                              |
    --                                                v
    constant am_wx : std_logic_vector(3 downto 0) := '1' & as_x;  -- x ++ or --
    constant am_wy : std_logic_vector(3 downto 0) := '1' & as_y;  -- y ++ or --
    constant am_wz : std_logic_vector(3 downto 0) := '1' & as_z;  -- z ++ or --
    constant am_ws : std_logic_vector(3 downto 0) := '1' & as_sp; -- sp ++/--

    -- address modes used
    --
    constant amod_abs : std_logic_vector(5 downto 0) := ao_0  & as_imm; -- imm
    constant amod_x   : std_logic_vector(5 downto 0) := ao_0  & as_x;   -- x
    constant amod_xq  : std_logic_vector(5 downto 0) := ao_q  & as_x;   -- x+q
    constant amod_xi  : std_logic_vector(5 downto 0) := ao_i  & as_x;   -- x+
    constant amod_dx  : std_logic_vector(5 downto 0) := ao_d  & as_x;   -- -x
    constant amod_y   : std_logic_vector(5 downto 0) := ao_0  & as_y;   -- y
    constant amod_yq  : std_logic_vector(5 downto 0) := ao_q  & as_y;   -- y+q
    constant amod_yi  : std_logic_vector(5 downto 0) := ao_i  & as_y;   -- y+
    constant amod_dy  : std_logic_vector(5 downto 0) := ao_d  & as_y;   -- -y
    constant amod_z   : std_logic_vector(5 downto 0) := ao_0  & as_z;   -- z
    constant amod_zq  : std_logic_vector(5 downto 0) := ao_q  & as_z;   -- z+q
    constant amod_zi  : std_logic_vector(5 downto 0) := ao_i  & as_z;   -- z+
    constant amod_dz  : std_logic_vector(5 downto 0) := ao_d  & as_z;   -- -z
    constant amod_isp : std_logic_vector(5 downto 0) := ao_i  & as_sp;  -- +sp
    constant amod_iisp: std_logic_vector(5 downto 0) := ao_ii & as_sp;  -- ++sp
    constant amod_spd : std_logic_vector(5 downto 0) := ao_d  & as_sp;  -- sp-
    constant amod_spdd: std_logic_vector(5 downto 0) := ao_dd & as_sp;  -- sp--
 
    -----------------------------------------------------------------------
    --
    -- alu multiplexers.
    --
    constant rs_reg : std_logic_vector(1 downto 0) := "00";
    constant rs_imm : std_logic_vector(1 downto 0) := "01";
    constant rs_din : std_logic_vector(1 downto 0) := "10";

    -----------------------------------------------------------------------
    --
    -- multiplier variants. f means fmult (as opposed to mult).
    -- s and u means signed vs. unsigned operands.
    --
    constant mult_uu  : std_logic_vector(2 downto 0) := "000";
    constant mult_su  : std_logic_vector(2 downto 0) := "010";
    constant mult_ss  : std_logic_vector(2 downto 0) := "011";
    constant mult_fuu : std_logic_vector(2 downto 0) := "100";
    constant mult_fsu : std_logic_vector(2 downto 0) := "110";
    constant mult_fss : std_logic_vector(2 downto 0) := "111";

    -----------------------------------------------------------------------

end common;

