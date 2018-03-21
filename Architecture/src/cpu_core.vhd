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
-- module name:    cpu_core - behavioral 
-- create date:    13:51:24 11/07/2009 
-- description:    the instruction set implementation of a cpu.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cpu_core is
    port (  i_clk       : in  std_logic;
            i_reset       : in  std_logic;
            i_intvec    : in  std_logic_vector( 5 downto 0);
            i_din       : in  std_logic_vector( 7 downto 0);

            q_opc       : out std_logic_vector(15 downto 0);
            q_pc        : out std_logic_vector(15 downto 0);
            q_dout      : out std_logic_vector( 7 downto 0);
            q_adr_io    : out std_logic_vector( 7 downto 0);
            q_rd_io     : out std_logic;
            q_we_io     : out std_logic);
end cpu_core;

architecture behavioral of cpu_core is

component opc_fetch
    port(   i_clk       : in  std_logic;

            i_reset       : in  std_logic;
            i_intvec    : in  std_logic_vector( 5 downto 0);
            i_new_pc    : in  std_logic_vector(15 downto 0);
            i_load_pc   : in  std_logic;
            i_pm_adr    : in  std_logic_vector(11 downto 0);
            i_skip      : in  std_logic;

            q_opc       : out std_logic_vector(15 downto 0);
            q_pc        : out std_logic_vector(15 downto 0);
            q_pm_dout   : out std_logic_vector( 7 downto 0);
            q_t0        : out std_logic);
end component;

signal f_pc             : std_logic_vector(15 downto 0);
signal f_opc            : std_logic_vector(15 downto 0);
signal f_pm_dout        : std_logic_vector( 7 downto 0);
signal f_t0             : std_logic;

component opc_deco is
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
end component;

signal d_alu_op         : std_logic_vector( 3 downto 0);
signal d_amod           : std_logic_vector( 5 downto 0);
signal d_bit            : std_logic_vector( 3 downto 0);
signal d_ddddd          : std_logic_vector( 3 downto 0);
signal d_imm            : std_logic_vector( 7 downto 0);
signal d_jadr           : std_logic_vector( 7 downto 0);
signal d_opc            : std_logic_vector(15 downto 0);
signal d_pc             : std_logic_vector(15 downto 0);
signal d_pc_op          : std_logic_vector(2 downto 0);
signal d_pms            : std_logic;
signal d_rd_m           : std_logic;
signal d_rrrrr          : std_logic_vector( 3 downto 0);
signal d_rsel           : std_logic_vector( 1 downto 0);
signal d_we_01          : std_logic;
signal d_we_d           : std_logic_vector( 1 downto 0);
signal d_we_f           : std_logic;
signal d_we_m           : std_logic_vector( 1 downto 0);
signal d_we_xyzs        : std_logic;

component data_path
    port(   i_clk       : in    std_logic;

            i_alu_op    : in  std_logic_vector( 3 downto 0);
            i_amod      : in  std_logic_vector( 5 downto 0);
            i_bit       : in  std_logic_vector( 3 downto 0);
            i_ddddd     : in  std_logic_vector( 3 downto 0);
            i_din       : in  std_logic_vector( 7 downto 0);
            i_imm       : in  std_logic_vector( 7 downto 0);
            i_jadr      : in  std_logic_vector( 7 downto 0);
            i_pc_op     : in  std_logic_vector( 2 downto 0);
            i_opc       : in  std_logic_vector(15 downto 0);
            i_pc        : in  std_logic_vector(15 downto 0);
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
end component;

signal r_int_ena        : std_logic;
signal r_new_pc         : std_logic_vector(15 downto 0);
signal r_load_pc        : std_logic;
signal r_skip           : std_logic;
signal r_adr            : std_logic_vector(15 downto 0);

-- local signals
--
signal l_din            : std_logic_vector( 7 downto 0);
signal l_intvec_5       : std_logic;

begin

    opcf : opc_fetch
    port map(   i_clk       => i_clk,

                i_reset       => i_reset,
                i_intvec(5) => l_intvec_5,
                i_intvec(4 downto 0) => i_intvec(4 downto 0),
                i_load_pc   => r_load_pc,
                i_new_pc    => r_new_pc,
                i_pm_adr    => r_adr(11 downto 0),
                i_skip      => r_skip,

                q_pc        => f_pc,
                q_opc       => f_opc,
                q_t0        => f_t0,
                q_pm_dout   => f_pm_dout);
 
    odec : opc_deco
    port map(   i_clk       => i_clk,

                i_opc       => f_opc,
                i_pc        => f_pc,
                i_t0        => f_t0,

                q_alu_op    => d_alu_op,
                q_amod      => d_amod,
                q_bit       => d_bit,
                q_ddddd     => d_ddddd,
                q_imm       => d_imm,
                q_jadr      => d_jadr,
                q_opc       => d_opc,
                q_pc        => d_pc,
                q_pc_op     => d_pc_op,
                q_pms       => d_pms,
                q_rd_m      => d_rd_m,
                q_rrrrr     => d_rrrrr,
                q_rsel      => d_rsel,
                q_we_01     => d_we_01,
                q_we_d      => d_we_d,
                q_we_f      => d_we_f,
                q_we_m      => d_we_m,
                q_we_xyzs   => d_we_xyzs);

    dpath : data_path
    port map(   i_clk       => i_clk,

                i_alu_op    => d_alu_op,
                i_amod      => d_amod,
                i_bit       => d_bit,
                i_ddddd     => d_ddddd,
                i_din       => l_din,
                i_imm       => d_imm,
                i_jadr      => d_jadr,
                i_opc       => d_opc,
                i_pc        => d_pc,
                i_pc_op     => d_pc_op,
                i_pms       => d_pms,
                i_rd_m      => d_rd_m,
                i_rrrrr     => d_rrrrr,
                i_rsel      => d_rsel,
                i_we_01     => d_we_01,
                i_we_d      => d_we_d,
                i_we_f      => d_we_f,
                i_we_m      => d_we_m,
                i_we_xyzs   => d_we_xyzs,

                q_adr       => r_adr,
                q_dout      => q_dout,
                q_int_ena   => r_int_ena,
                q_new_pc    => r_new_pc,
                q_opc       => q_opc,
                q_pc        => q_pc,
                q_load_pc   => r_load_pc,
                q_rd_io     => q_rd_io,
                q_skip      => r_skip,
                q_we_io     => q_we_io);

    l_din <= f_pm_dout when (d_pms = '1') else i_din(7 downto 0);
    l_intvec_5 <= i_intvec(5) and r_int_ena;
    q_adr_io <= r_adr(7 downto 0);

end behavioral;

