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
-- module name:    registerfile - behavioral 
-- create date:    12:43:34 10/28/2009 
-- description:    a register file (16 register pairs) of a cpu.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.common.all;

entity register_file is
    port (  i_clk       : in  std_logic;

            i_amod      : in  std_logic_vector( 5 downto 0);
            i_cond      : in  std_logic_vector( 3 downto 0);
            i_ddddd     : in  std_logic_vector( 3 downto 0);
            i_din       : in  std_logic_vector(15 downto 0);
            i_flags     : in  std_logic_vector( 7 downto 0);
            i_imm       : in  std_logic_vector( 7 downto 0);
            i_rrrr      : in  std_logic_vector( 3 downto 0);
            i_we_01     : in  std_logic;
            i_we_d      : in  std_logic_vector( 1 downto 0);
            i_we_f      : in  std_logic;
            i_we_m      : in  std_logic;
            i_we_xyzs   : in  std_logic;

            q_adr       : out std_logic_vector(15 downto 0);
            q_cc        : out std_logic;
            q_d         : out std_logic_vector(15 downto 0);
            q_flags     : out std_logic_vector( 7 downto 0);
            q_r         : out std_logic_vector(15 downto 0);
            q_s         : out std_logic_vector( 7 downto 0);
            q_z         : out std_logic_vector(15 downto 0));
end register_file;

architecture behavioral of register_file is

component reg_16
    port (  i_clk       : in    std_logic;

            i_d         : in    std_logic_vector(15 downto 0);
            i_we        : in    std_logic_vector( 1 downto 0);

            q           : out   std_logic_vector(15 downto 0));
end component;

signal r_r00            : std_logic_vector(15 downto 0);
signal r_r02            : std_logic_vector(15 downto 0);
signal r_r04            : std_logic_vector(15 downto 0);
signal r_r06            : std_logic_vector(15 downto 0);
signal r_r08            : std_logic_vector(15 downto 0);
signal r_r10            : std_logic_vector(15 downto 0);
signal r_r12            : std_logic_vector(15 downto 0);
signal r_r14            : std_logic_vector(15 downto 0);
signal r_r16            : std_logic_vector(15 downto 0);
signal r_r18            : std_logic_vector(15 downto 0);
signal r_r20            : std_logic_vector(15 downto 0);
signal r_r22            : std_logic_vector(15 downto 0);
signal r_r24            : std_logic_vector(15 downto 0);
signal r_r26            : std_logic_vector(15 downto 0);
signal r_r28            : std_logic_vector(15 downto 0);
signal r_r30            : std_logic_vector(15 downto 0);
signal r_sp             : std_logic_vector(15 downto 0);    -- stack pointer

component status_reg is
    port (  i_clk       : in  std_logic;

            i_cond      : in  std_logic_vector ( 3 downto 0);
            i_din       : in  std_logic_vector ( 7 downto 0);
            i_flags     : in  std_logic_vector ( 7 downto 0);
            i_we_f      : in  std_logic;
            i_we_sr     : in  std_logic;

            q           : out std_logic_vector ( 7 downto 0);
            q_cc        : out std_logic);
end component;

signal s_flags          : std_logic_vector( 7 downto 0);

signal l_adr            : std_logic_vector(15 downto 0);
signal l_base           : std_logic_vector(15 downto 0);
signal l_dddd           : std_logic_vector( 3 downto 0);
signal l_dsp            : std_logic_vector(15 downto 0);
signal l_dx             : std_logic_vector(15 downto 0);
signal l_dy             : std_logic_vector(15 downto 0);
signal l_dz             : std_logic_vector(15 downto 0);
signal l_pre            : std_logic_vector(15 downto 0);
signal l_post           : std_logic_vector(15 downto 0);
signal l_s              : std_logic_vector(15 downto 0);
signal l_we_sp_amod     : std_logic;
signal l_we             : std_logic_vector(31 downto 0);
signal l_we_a           : std_logic;
signal l_we_d           : std_logic_vector(31 downto 0);
signal l_we_d2          : std_logic_vector( 1 downto 0);
signal l_we_dd          : std_logic_vector(31 downto 0);
signal l_we_io          : std_logic_vector(31 downto 0);
signal l_we_misc        : std_logic_vector(31 downto 0);
signal l_we_x           : std_logic;
signal l_we_y           : std_logic;
signal l_we_z           : std_logic;
signal l_we_sp          : std_logic_vector( 1 downto 0);
signal l_we_sr          : std_logic;
signal l_xyzs           : std_logic_vector(15 downto 0);

begin

    r00: reg_16 port map(i_clk => i_clk, i_we => l_we( 1 downto  0), i_d => i_din, q => r_r00);
    r02: reg_16 port map(i_clk => i_clk, i_we => l_we( 3 downto  2), i_d => i_din, q => r_r02);
    r04: reg_16 port map(i_clk => i_clk, i_we => l_we( 5 downto  4), i_d => i_din, q => r_r04);
    r06: reg_16 port map(i_clk => i_clk, i_we => l_we( 7 downto  6), i_d => i_din, q => r_r06);
    r08: reg_16 port map(i_clk => i_clk, i_we => l_we( 9 downto  8), i_d => i_din, q => r_r08);
    r10: reg_16 port map(i_clk => i_clk, i_we => l_we(11 downto 10), i_d => i_din, q => r_r10);
    r12: reg_16 port map(i_clk => i_clk, i_we => l_we(13 downto 12), i_d => i_din, q => r_r12);
    r14: reg_16 port map(i_clk => i_clk, i_we => l_we(15 downto 14), i_d => i_din, q => r_r14);
    r16: reg_16 port map(i_clk => i_clk, i_we => l_we(17 downto 16), i_d => i_din, q => r_r16);
    r18: reg_16 port map(i_clk => i_clk, i_we => l_we(19 downto 18), i_d => i_din, q => r_r18);
    r20: reg_16 port map(i_clk => i_clk, i_we => l_we(21 downto 20), i_d => i_din, q => r_r20);
    r22: reg_16 port map(i_clk => i_clk, i_we => l_we(23 downto 22), i_d => i_din, q => r_r22);
    r24: reg_16 port map(i_clk => i_clk, i_we => l_we(25 downto 24), i_d => i_din, q => r_r24);
    r26: reg_16 port map(i_clk => i_clk, i_we => l_we(27 downto 26), i_d => l_dx,  q => r_r26);
    r28: reg_16 port map(i_clk => i_clk, i_we => l_we(29 downto 28), i_d => l_dy,  q => r_r28);
    r30: reg_16 port map(i_clk => i_clk, i_we => l_we(31 downto 30), i_d => l_dz,  q => r_r30);
    sp:  reg_16 port map(i_clk => i_clk, i_we => l_we_sp,            i_d => l_dsp, q => r_sp);

    sr: status_reg
    port map(   i_clk       => i_clk,
                i_cond      => i_cond,
                i_din       => i_din(7 downto 0),
                i_flags     => i_flags,
                i_we_f      => i_we_f,
                i_we_sr     => l_we_sr,
                q           => s_flags,
                q_cc        => q_cc);

    -- the output of the register selected by l_adr.
    --
    process(r_r00, r_r02, r_r04, r_r06, r_r08, r_r10, r_r12, r_r14,
            r_r16, r_r18, r_r20, r_r22, r_r24, r_r26, r_r28, r_r30,
            r_sp, s_flags, l_adr(6 downto 1))
    begin
        case l_adr(6 downto 1) is
            when "000000" => l_s <= r_r00;
            when "000001" => l_s <= r_r02;
            when "000010" => l_s <= r_r04;
            when "000011" => l_s <= r_r06;
            when "000100" => l_s <= r_r08;
            when "000101" => l_s <= r_r10;
            when "000110" => l_s <= r_r12;
            when "000111" => l_s <= r_r14;
            when "001000" => l_s <= r_r16;
            when "001001" => l_s <= r_r18;
            when "001010" => l_s <= r_r20;
            when "001011" => l_s <= r_r22;
            when "001100" => l_s <= r_r24;
            when "001101" => l_s <= r_r26;
            when "001110" => l_s <= r_r28;
            when "001111" => l_s <= r_r30;
            when "101110" => l_s <= r_sp ( 7 downto 0) & x"00";     -- spl
            when others   => l_s <= s_flags & r_sp (15 downto 8);   -- sr/sph
        end case;
    end process;
    
    -- the output of the register pair selected by i_ddddd.
    --
    process(r_r00, r_r02, r_r04, r_r06, r_r08, r_r10, r_r12, r_r14,
            r_r16, r_r18, r_r20, r_r22, r_r24, r_r26, r_r28, r_r30,
            i_ddddd(3 downto 1))
    begin
        case i_ddddd(3 downto 1) is
            when "000" => q_d <= r_r00;
            when "001" => q_d <= r_r02;
            when "010" => q_d <= r_r04;
            when "011" => q_d <= r_r06;
            when "100" => q_d <= r_r08;
            when "101" => q_d <= r_r10;
            when "110" => q_d <= r_r12;
            when "111" => q_d <= r_r14;
				when others =>
        end case;
    end process;

    -- the output of the register pair selected by i_rrrr.
    --
    process(r_r00, r_r02, r_r04,  r_r06, r_r08, r_r10, r_r12, r_r14,
            r_r16, r_r18, r_r20, r_r22, r_r24, r_r26, r_r28, r_r30, i_rrrr(3 downto 1))
    begin
        case i_rrrr(3 downto 1) is
            when "000" => q_r <= r_r00;
            when "001" => q_r <= r_r02;
            when "010" => q_r <= r_r04;
            when "011" => q_r <= r_r06;
            when "100" => q_r <= r_r08;
            when "101" => q_r <= r_r10;
            when "110" => q_r <= r_r12;
            when "111" => q_r <= r_r14;
				when others =>
        end case;
    end process;

    -- the base value of the x/y/z/sp register as per i_amod.
    --
    process(i_amod(2 downto 0), i_imm, r_sp, r_r26, r_r28, r_r30)
    begin
        case i_amod(2 downto 0) is
            when as_sp  => l_base <= r_sp;
            when as_z   => l_base <= r_r30;
            when as_y   => l_base <= r_r28;
            when as_x   => l_base <= r_r26;
            when as_imm => l_base <= x"00" & i_imm;
            when others => l_base <= x"0000";
        end case;
    end process;

    -- the value of the x/y/z/sp register after a potential pre-inc/decrement
    -- (by 1 or 2) and post-inc/decrement (by 1 or 2).
    --
    process(i_amod, i_imm)
    begin
        case i_amod is
            when amod_xq | amod_yq | amod_zq  =>
                l_pre <= x"00" & i_imm;      l_post <= x"0000";

            when amod_xi | amod_yi | amod_zi  =>
                l_pre <= x"0000";    l_post <= x"0001";

            when amod_dx  | amod_dy  | amod_dz  =>
                l_pre <= x"ffff";    l_post <= x"ffff";

            when amod_isp =>
                l_pre <= x"0001";    l_post <= x"0001";

            when amod_iisp=>
                l_pre <= x"0001";    l_post <= x"0002";

            when amod_spd =>
                l_pre <= x"0000";    l_post <= x"ffff";

            when amod_spdd=>
                l_pre <= x"ffff";    l_post <= x"fffe";

            when others =>
                l_pre <= x"0000";    l_post <= x"0000";
        end case;
    end process;

    l_xyzs <= l_base + l_post;
    l_adr  <= l_base + l_pre;
    
    l_we_a <= i_we_m when (l_adr(15 downto 5) = "00000000000") else '0';
    l_we_sr    <= i_we_m when (l_adr = x"005f") else '0';
    l_we_sp_amod <= i_we_xyzs when (i_amod(2 downto 0) = as_sp) else '0';
    l_we_sp(1) <= i_we_m when (l_adr = x"005e") else l_we_sp_amod;
    l_we_sp(0) <= i_we_m when (l_adr = x"005d") else l_we_sp_amod;

    l_dx  <= l_xyzs when (l_we_misc(26) = '1')        else i_din;
    l_dy  <= l_xyzs when (l_we_misc(28) = '1')        else i_din;
    l_dz  <= l_xyzs when (l_we_misc(30) = '1')        else i_din;
    l_dsp <= l_xyzs when (i_amod(3 downto 0) = am_ws) else i_din;
    
    -- the we signals for the differen registers.
    --
    -- case 1: write to an 8-bit register addressed by ddddd.
    --
    -- i_we_d(0) = '1' and i_ddddd matches,
    --
    l_we_d( 0) <= i_we_d(0) when (i_ddddd = "00000") else '0';
    l_we_d( 1) <= i_we_d(0) when (i_ddddd = "00001") else '0';
    l_we_d( 2) <= i_we_d(0) when (i_ddddd = "00010") else '0';
    l_we_d( 3) <= i_we_d(0) when (i_ddddd = "00011") else '0';
    l_we_d( 4) <= i_we_d(0) when (i_ddddd = "00100") else '0';
    l_we_d( 5) <= i_we_d(0) when (i_ddddd = "00101") else '0';
    l_we_d( 6) <= i_we_d(0) when (i_ddddd = "00110") else '0';
    l_we_d( 7) <= i_we_d(0) when (i_ddddd = "00111") else '0';
    l_we_d( 8) <= i_we_d(0) when (i_ddddd = "01000") else '0';
    l_we_d( 9) <= i_we_d(0) when (i_ddddd = "01001") else '0';
    l_we_d(10) <= i_we_d(0) when (i_ddddd = "01010") else '0';
    l_we_d(11) <= i_we_d(0) when (i_ddddd = "01011") else '0';
    l_we_d(12) <= i_we_d(0) when (i_ddddd = "01100") else '0';
    l_we_d(13) <= i_we_d(0) when (i_ddddd = "01101") else '0';
    l_we_d(14) <= i_we_d(0) when (i_ddddd = "01110") else '0';
    l_we_d(15) <= i_we_d(0) when (i_ddddd = "01111") else '0';
    l_we_d(16) <= i_we_d(0) when (i_ddddd = "10000") else '0';
    l_we_d(17) <= i_we_d(0) when (i_ddddd = "10001") else '0';
    l_we_d(18) <= i_we_d(0) when (i_ddddd = "10010") else '0';
    l_we_d(19) <= i_we_d(0) when (i_ddddd = "10011") else '0';
    l_we_d(20) <= i_we_d(0) when (i_ddddd = "10100") else '0';
    l_we_d(21) <= i_we_d(0) when (i_ddddd = "10101") else '0';
    l_we_d(22) <= i_we_d(0) when (i_ddddd = "10110") else '0';
    l_we_d(23) <= i_we_d(0) when (i_ddddd = "10111") else '0';
    l_we_d(24) <= i_we_d(0) when (i_ddddd = "11000") else '0';
    l_we_d(25) <= i_we_d(0) when (i_ddddd = "11001") else '0';
    l_we_d(26) <= i_we_d(0) when (i_ddddd = "11010") else '0';
    l_we_d(27) <= i_we_d(0) when (i_ddddd = "11011") else '0';
    l_we_d(28) <= i_we_d(0) when (i_ddddd = "11100") else '0';
    l_we_d(29) <= i_we_d(0) when (i_ddddd = "11101") else '0';
    l_we_d(30) <= i_we_d(0) when (i_ddddd = "11110") else '0';
    l_we_d(31) <= i_we_d(0) when (i_ddddd = "11111") else '0';

    --
    -- case 2: write to a 16-bit register pair addressed by dddd.
    --
    -- i_we_dd(1) = '1' and l_dddd matches,
    --
    l_dddd <= i_ddddd(3 downto 0);
    l_we_d2 <= i_we_d(1) & i_we_d(1);
    l_we_dd( 1 downto  0) <= l_we_d2 when (l_dddd = "0000") else "00";
    l_we_dd( 3 downto  2) <= l_we_d2 when (l_dddd = "0001") else "00";
    l_we_dd( 5 downto  4) <= l_we_d2 when (l_dddd = "0010") else "00";
    l_we_dd( 7 downto  6) <= l_we_d2 when (l_dddd = "0011") else "00";
    l_we_dd( 9 downto  8) <= l_we_d2 when (l_dddd = "0100") else "00";
    l_we_dd(11 downto 10) <= l_we_d2 when (l_dddd = "0101") else "00";
    l_we_dd(13 downto 12) <= l_we_d2 when (l_dddd = "0110") else "00";
    l_we_dd(15 downto 14) <= l_we_d2 when (l_dddd = "0111") else "00";
    l_we_dd(17 downto 16) <= l_we_d2 when (l_dddd = "1000") else "00";
    l_we_dd(19 downto 18) <= l_we_d2 when (l_dddd = "1001") else "00";
    l_we_dd(21 downto 20) <= l_we_d2 when (l_dddd = "1010") else "00";
    l_we_dd(23 downto 22) <= l_we_d2 when (l_dddd = "1011") else "00";
    l_we_dd(25 downto 24) <= l_we_d2 when (l_dddd = "1100") else "00";
    l_we_dd(27 downto 26) <= l_we_d2 when (l_dddd = "1101") else "00";
    l_we_dd(29 downto 28) <= l_we_d2 when (l_dddd = "1110") else "00";
    l_we_dd(31 downto 30) <= l_we_d2 when (l_dddd = "1111") else "00";

    --
    -- case 3: write to an 8-bit register pair addressed by an i/o address.
    --
    -- l_we_a = '1' and l_adr(4 downto 0) matches
    --
    l_we_io( 0) <= l_we_a when (l_adr(4 downto 0) = "00000") else '0';
    l_we_io( 1) <= l_we_a when (l_adr(4 downto 0) = "00001") else '0';
    l_we_io( 2) <= l_we_a when (l_adr(4 downto 0) = "00010") else '0';
    l_we_io( 3) <= l_we_a when (l_adr(4 downto 0) = "00011") else '0';
    l_we_io( 4) <= l_we_a when (l_adr(4 downto 0) = "00100") else '0';
    l_we_io( 5) <= l_we_a when (l_adr(4 downto 0) = "00101") else '0';
    l_we_io( 6) <= l_we_a when (l_adr(4 downto 0) = "00110") else '0';
    l_we_io( 7) <= l_we_a when (l_adr(4 downto 0) = "00111") else '0';
    l_we_io( 8) <= l_we_a when (l_adr(4 downto 0) = "01000") else '0';
    l_we_io( 9) <= l_we_a when (l_adr(4 downto 0) = "01001") else '0';
    l_we_io(10) <= l_we_a when (l_adr(4 downto 0) = "01010") else '0';
    l_we_io(11) <= l_we_a when (l_adr(4 downto 0) = "01011") else '0';
    l_we_io(12) <= l_we_a when (l_adr(4 downto 0) = "01100") else '0';
    l_we_io(13) <= l_we_a when (l_adr(4 downto 0) = "01101") else '0';
    l_we_io(14) <= l_we_a when (l_adr(4 downto 0) = "01110") else '0';
    l_we_io(15) <= l_we_a when (l_adr(4 downto 0) = "01111") else '0';
    l_we_io(16) <= l_we_a when (l_adr(4 downto 0) = "10000") else '0';
    l_we_io(17) <= l_we_a when (l_adr(4 downto 0) = "10001") else '0';
    l_we_io(18) <= l_we_a when (l_adr(4 downto 0) = "10010") else '0';
    l_we_io(19) <= l_we_a when (l_adr(4 downto 0) = "10011") else '0';
    l_we_io(20) <= l_we_a when (l_adr(4 downto 0) = "10100") else '0';
    l_we_io(21) <= l_we_a when (l_adr(4 downto 0) = "10101") else '0';
    l_we_io(22) <= l_we_a when (l_adr(4 downto 0) = "10110") else '0';
    l_we_io(23) <= l_we_a when (l_adr(4 downto 0) = "10111") else '0';
    l_we_io(24) <= l_we_a when (l_adr(4 downto 0) = "11000") else '0';
    l_we_io(25) <= l_we_a when (l_adr(4 downto 0) = "11001") else '0';
    l_we_io(26) <= l_we_a when (l_adr(4 downto 0) = "11010") else '0';
    l_we_io(27) <= l_we_a when (l_adr(4 downto 0) = "11011") else '0';
    l_we_io(28) <= l_we_a when (l_adr(4 downto 0) = "11100") else '0';
    l_we_io(29) <= l_we_a when (l_adr(4 downto 0) = "11101") else '0';
    l_we_io(30) <= l_we_a when (l_adr(4 downto 0) = "11110") else '0';
    l_we_io(31) <= l_we_a when (l_adr(4 downto 0) = "11111") else '0';

    -- case 4 special cases.
    -- 4a. we_01 for register pair 0/1 (multiplication opcode).
    -- 4b. i_we_xyzs for x (register pairs 26/27) and i_amod matches
    -- 4c. i_we_xyzs for y (register pairs 28/29) and i_amod matches
    -- 4d. i_we_xyzs for z (register pairs 30/31) and i_amod matches
    --
    l_we_x <= i_we_xyzs when (i_amod(3 downto 0) = am_wx) else '0';
    l_we_y <= i_we_xyzs when (i_amod(3 downto 0) = am_wy) else '0';
    l_we_z <= i_we_xyzs when (i_amod(3 downto 0) = am_wz) else '0';
    l_we_misc <= l_we_z & l_we_z &      -- -z and z+ address modes  r30
                 l_we_y & l_we_y &      -- -y and y+ address modes  r28
                 l_we_x & l_we_x &      -- -x and x+ address modes  r26
                 x"000000" &            -- never                    r24 - r02
                 i_we_01 & i_we_01;     -- multiplication result    r00

    l_we <= l_we_d or l_we_dd or l_we_io or l_we_misc;

    q_s <= l_s( 7 downto 0) when (l_adr(0) = '0') else l_s(15 downto 8);
    q_flags <= s_flags;
    q_z <= r_r30;
    q_adr <= l_adr;

end behavioral;

