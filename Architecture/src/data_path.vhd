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
-- module name:    data_path - behavioral 
-- create date:    13:24:10 10/29/2009 
-- description:    the data path of a cpu.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.common.all;

entity data_path is
    port(   i_clk         : in  std_logic;

            i_alu_op    : in  std_logic_vector( 3 downto 0);
            i_amod      : in  std_logic_vector( 5 downto 0);
            i_bit       : in  std_logic_vector( 3 downto 0);
            i_ddddd     : in  std_logic_vector( 3 downto 0);
            i_din       : in  std_logic_vector( 7 downto 0);
            i_imm       : in  std_logic_vector( 7 downto 0);
            i_jadr      : in  std_logic_vector( 7 downto 0);
            i_opc       : in  std_logic_vector(15 downto 0);
            i_pc        : in  std_logic_vector(15 downto 0);
            i_pc_op     : in  std_logic_vector( 2 downto 0);
            i_pms       : in  std_logic;  -- program memory select
            i_rd_m      : in  std_logic;
            i_rrrrr     : in  std_logic_vector( 3 downto 0);
            i_rsel      : in  std_logic_vector( 1 downto 0);
            i_we_01     : in  std_logic;
            i_we_d      : in  std_logic_vector( 1 downto 0);
            i_we_f      : in  std_logic;
            i_we_m      : in  std_logic_vector( 1 downto 0);
            i_we_xyzs   : in  std_logic;
 
            q_adr       : out std_logic_vector(15 downto 0);
            q_dout      : out std_logic_vector( 7 downto 0);
            q_int_ena   : out std_logic;
            q_load_pc   : out std_logic;
            q_new_pc    : out std_logic_vector(15 downto 0);
            q_opc       : out std_logic_vector(15 downto 0);
            q_pc        : out std_logic_vector(15 downto 0);
            q_rd_io     : out std_logic;
            q_skip      : out std_logic;
            q_we_io     : out std_logic);
end data_path;

architecture behavioral of data_path is

component alu
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
end component;

signal a_dout           : std_logic_vector(15 downto 0);
signal a_flags          : std_logic_vector( 9 downto 0);

component register_file
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
end component;

signal f_adr            : std_logic_vector(15 downto 0);
signal f_cc             : std_logic;
signal f_d              : std_logic_vector(15 downto 0);
signal f_flags          : std_logic_vector( 7 downto 0);
signal f_r              : std_logic_vector(15 downto 0);
signal f_s              : std_logic_vector( 7 downto 0);
signal f_z              : std_logic_vector(15 downto 0);

component data_mem
    port (  i_clk       : in  std_logic;

            i_adr       : in  std_logic_vector(10 downto 0);
            i_din       : in  std_logic_vector(15 downto 0);
            i_we        : in  std_logic_vector( 1 downto 0);

            q_dout      : out std_logic_vector(15 downto 0));
end component;

signal m_dout           : std_logic_vector(15 downto 0);

signal l_din            : std_logic_vector( 7 downto 0);
signal l_we_sram        : std_logic_vector( 1 downto 0);
signal l_flags_98       : std_logic_vector( 9 downto 8);

begin

    alui : alu
    port map(   i_alu_op    => i_alu_op,
                i_bit       => i_bit,
                i_d         => f_d,
                i_d0        => i_ddddd(0),
                i_din       => l_din,
                i_flags     => f_flags,
                i_imm       => i_imm(7 downto 0),
                i_pc        => i_pc,
                i_r         => f_r,
                i_rsel      => i_rsel,

                q_flags     => a_flags,
                q_dout      => a_dout);

    regs : register_file
    port map(   i_clk       => i_clk,

                i_amod      => i_amod,
                i_cond(3)   => i_opc(10),
                i_cond(2 downto 0)=> i_opc(2 downto 0),
                i_ddddd     => i_ddddd,
                i_din       => a_dout,
                i_flags     => a_flags(7 downto 0),
                i_imm       => i_imm,
                i_rrrr      => i_rrrrr,
                i_we_01     => i_we_01,
                i_we_d      => i_we_d,
                i_we_f      => i_we_f,
                i_we_m      => i_we_m(0),
                i_we_xyzs   => i_we_xyzs,

                q_adr       => f_adr,
                q_cc        => f_cc,
                q_d         => f_d,
                q_flags     => f_flags,
                q_r         => f_r,
                q_s         => f_s,   -- q_rxx(f_adr)
                q_z         => f_z);

    sram : data_mem
    port map(   i_clk   => i_clk,

                i_adr   => f_adr(10 downto 0),
                i_din   => a_dout,
                i_we    => l_we_sram,

                q_dout  => m_dout);

    -- remember a_flags(9 downto 8) (within the current instruction).
    --
    flg98: process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            l_flags_98 <= a_flags(9 downto 8);
        end if;
    end process;

    -- whether pc shall be loaded with new_pc or not.
    -- i.e. if a branch shall be taken or not.
    --
    process(i_pc_op, f_cc)
    begin
        case i_pc_op is
            when pc_bcc  => q_load_pc <= f_cc;      -- maybe (pc on i_jadr)
            when pc_ld_i => q_load_pc <= '1';       -- yes: new pc on i_jadr
            when pc_ld_z => q_load_pc <= '1';       -- yes: new pc in z
            when pc_ld_s => q_load_pc <= '1';       -- yes: new pc on stack
            when others  => q_load_pc <= '0';       -- no.
        end case;
    end process;

    -- whether the next instruction shall be skipped or not.
    --
    process(i_pc_op, l_flags_98, f_cc)
    begin
        case i_pc_op is
            when pc_bcc    => q_skip <= f_cc;           -- if cond met
            when pc_ld_i   => q_skip <= '1';            -- yes
            when pc_ld_z   => q_skip <= '1';            -- yes
            when pc_ld_s   => q_skip <= '1';            -- yes
            when pc_skip_z => q_skip <= l_flags_98(8);  -- if z set
            when pc_skip_t => q_skip <= l_flags_98(9);  -- if t set
            when others    => q_skip <= '0';            -- no.
        end case;
    end process;

    q_adr     <= f_adr;
    q_dout    <= a_dout(7 downto 0);
    q_int_ena <= a_flags(7);
    q_opc     <= i_opc;
    q_pc      <= i_pc;

    q_rd_io   <= '0'                    when (f_adr < x"20")
            else (i_rd_m and not i_pms) when (f_adr < x"5d")
            else '0';
    q_we_io   <= '0'                    when (f_adr < x"20")
            else i_we_m(0)              when (f_adr < x"5d")
            else '0';
    l_we_sram <= "00"   when  (f_adr < x"0060") else i_we_m;
    l_din     <= i_din  when (i_pms = '1')
            else f_s    when  (f_adr < x"0020")
            else i_din  when  (f_adr < x"005d")
            else f_s    when  (f_adr < x"0060")
            else m_dout(7 downto 0);

    -- compute potential new pc value from z, (sp), or imm.
    --
    q_new_pc <= f_z    when i_pc_op = pc_ld_z       -- ijmp, icall
           else m_dout when i_pc_op = pc_ld_s       -- ret, reti
           else x"00" & i_jadr;                             -- jmp adr

end behavioral;

