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
-- module name:    prog_mem - behavioral 
-- create date:    14:09:04 10/30/2009 
-- description:    the program memory of a cpu.
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- the content of the program memory.
--
use work.prog_mem_content.all;

entity prog_mem is
    port (  i_clk       : in  std_logic;

            i_wait      : in  std_logic;
            i_pc        : in  std_logic_vector(15 downto 0); -- word address
            i_pm_adr    : in  std_logic_vector(11 downto 0); -- byte address

            q_opc       : out std_logic_vector(31 downto 0);
            q_pc        : out std_logic_vector(15 downto 0);
            q_pm_dout   : out std_logic_vector( 7 downto 0));
end prog_mem;

architecture behavioral of prog_mem is

constant zero_256 : bit_vector := x"00000000000000000000000000000000"
                                & x"00000000000000000000000000000000";

component ramb4_s4_s4
    generic(init_00 : bit_vector := zero_256;
            init_01 : bit_vector := zero_256;
            init_02 : bit_vector := zero_256;
            init_03 : bit_vector := zero_256;
            init_04 : bit_vector := zero_256;
            init_05 : bit_vector := zero_256;
            init_06 : bit_vector := zero_256;
            init_07 : bit_vector := zero_256;
            init_08 : bit_vector := zero_256;
            init_09 : bit_vector := zero_256;
            init_0a : bit_vector := zero_256;
            init_0b : bit_vector := zero_256;
            init_0c : bit_vector := zero_256;
            init_0d : bit_vector := zero_256;
            init_0e : bit_vector := zero_256;
            init_0f : bit_vector := zero_256);

    port(   addra   : in  std_logic_vector(9 downto 0);
            addrb   : in  std_logic_vector(9 downto 0);
            clka    : in  std_ulogic;
            clkb    : in  std_ulogic;
            dia     : in  std_logic_vector(3 downto 0);
            dib     : in  std_logic_vector(3 downto 0);
            ena     : in  std_ulogic;
            enb     : in  std_ulogic;
            rsta    : in  std_ulogic;
            rstb    : in  std_ulogic;
            wea     : in  std_ulogic;
            web     : in  std_ulogic;

            doa     : out std_logic_vector(3 downto 0);
            dob     : out std_logic_vector(3 downto 0));
end component;

signal m_opc_e      : std_logic_vector(15 downto 0);
signal m_opc_o      : std_logic_vector(15 downto 0);
signal m_pmd_e      : std_logic_vector(15 downto 0);
signal m_pmd_o      : std_logic_vector(15 downto 0);

signal l_wait_n     : std_logic;
signal l_pc_0       : std_logic;
signal l_pc_e       : std_logic_vector(10 downto 1);
signal l_pc_o       : std_logic_vector(10 downto 1);
signal l_pmd        : std_logic_vector(15 downto 0);
signal l_pm_adr_1_0 : std_logic_vector( 1 downto 0);

begin

    pe_0 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => p0_00, init_01 => p0_01, init_02 => p0_02, 
                init_03 => p0_03, init_04 => p0_04, init_05 => p0_05,
                init_06 => p0_06, init_07 => p0_07, init_08 => p0_08,
                init_09 => p0_09, init_0a => p0_0a, init_0b => p0_0b, 
                init_0c => p0_0c, init_0d => p0_0d, init_0e => p0_0e,
                init_0f => p0_0f)
    port map(addra => l_pc_e,                   addrb => i_pm_adr(11 downto 2),
             clka  => i_clk,                    clkb  => i_clk,
             dia   => "0000",                   dib   => "0000",
             ena   => l_wait_n,                 enb   => '1',
             rsta  => '0',                      rstb  => '0',
             wea   => '0',                      web   => '0',
             doa   => m_opc_e(3 downto 0),      dob   => m_pmd_e(3 downto 0));
 
    pe_1 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => p1_00, init_01 => p1_01, init_02 => p1_02,
                init_03 => p1_03, init_04 => p1_04, init_05 => p1_05,
                init_06 => p1_06, init_07 => p1_07, init_08 => p1_08,
                init_09 => p1_09, init_0a => p1_0a, init_0b => p1_0b,
                init_0c => p1_0c, init_0d => p1_0d, init_0e => p1_0e,
                init_0f => p1_0f)
    port map(addra => l_pc_e,                   addrb => i_pm_adr(11 downto 2),
             clka  => i_clk,                    clkb  => i_clk,
             dia   => "0000",                   dib   => "0000",
             ena   => l_wait_n,                 enb   => '1',
             rsta  => '0',                      rstb  => '0',
             wea   => '0',                      web   => '0',
             doa   => m_opc_e(7 downto 4),      dob   => m_pmd_e(7 downto 4));
 
    pe_2 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => p2_00, init_01 => p2_01, init_02 => p2_02,
                init_03 => p2_03, init_04 => p2_04, init_05 => p2_05,
                init_06 => p2_06, init_07 => p2_07, init_08 => p2_08,
                init_09 => p2_09, init_0a => p2_0a, init_0b => p2_0b,
                init_0c => p2_0c, init_0d => p2_0d, init_0e => p2_0e,
                init_0f => p2_0f)
    port map(addra => l_pc_e,                   addrb => i_pm_adr(11 downto 2),
             clka  => i_clk,                    clkb  => i_clk,
             dia   => "0000",                   dib   => "0000",
             ena   => l_wait_n,                 enb   => '1',
             rsta  => '0',                      rstb  => '0',
             wea   => '0',                      web   => '0',
             doa   => m_opc_e(11 downto 8),     dob   => m_pmd_e(11 downto 8));
 
    pe_3 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => p3_00, init_01 => p3_01, init_02 => p3_02,
                init_03 => p3_03, init_04 => p3_04, init_05 => p3_05,
                init_06 => p3_06, init_07 => p3_07, init_08 => p3_08,
                init_09 => p3_09, init_0a => p3_0a, init_0b => p3_0b,
                init_0c => p3_0c, init_0d => p3_0d, init_0e => p3_0e,
                init_0f => p3_0f)
    port map(addra => l_pc_e,                   addrb => i_pm_adr(11 downto 2),
             clka  => i_clk,                    clkb  => i_clk,
             dia   => "0000",                   dib   => "0000",
             ena   => l_wait_n,                 enb   => '1',
             rsta  => '0',                      rstb  => '0',
             wea   => '0',                      web   => '0',
             doa   => m_opc_e(15 downto 12),    dob   => m_pmd_e(15 downto 12));
 
    po_0 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => p4_00, init_01 => p4_01, init_02 => p4_02,
                init_03 => p4_03, init_04 => p4_04, init_05 => p4_05,
                init_06 => p4_06, init_07 => p4_07, init_08 => p4_08,
                init_09 => p4_09, init_0a => p4_0a, init_0b => p4_0b, 
                init_0c => p4_0c, init_0d => p4_0d, init_0e => p4_0e,
                init_0f => p4_0f)
    port map(addra => l_pc_o,                   addrb => i_pm_adr(11 downto 2),
             clka  => i_clk,                    clkb  => i_clk,
             dia   => "0000",                   dib   => "0000",
             ena   => l_wait_n,                 enb   => '1',
             rsta  => '0',                      rstb  => '0',
             wea   => '0',                      web   => '0',
             doa   => m_opc_o(3 downto 0),      dob   => m_pmd_o(3 downto 0));
 
    po_1 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => p5_00, init_01 => p5_01, init_02 => p5_02,
                init_03 => p5_03, init_04 => p5_04, init_05 => p5_05,
                init_06 => p5_06, init_07 => p5_07, init_08 => p5_08,
                init_09 => p5_09, init_0a => p5_0a, init_0b => p5_0b, 
                init_0c => p5_0c, init_0d => p5_0d, init_0e => p5_0e,
                init_0f => p5_0f)
    port map(addra => l_pc_o,                   addrb => i_pm_adr(11 downto 2),
             clka  => i_clk,                    clkb  => i_clk,
             dia   => "0000",                   dib   => "0000",
             ena   => l_wait_n,                 enb   => '1',
             rsta  => '0',                      rstb  => '0',
             wea   => '0',                      web   => '0',
             doa   => m_opc_o(7 downto 4),      dob   => m_pmd_o(7 downto 4));
 
    po_2 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => p6_00, init_01 => p6_01, init_02 => p6_02,
                init_03 => p6_03, init_04 => p6_04, init_05 => p6_05,
                init_06 => p6_06, init_07 => p6_07, init_08 => p6_08,
                init_09 => p6_09, init_0a => p6_0a, init_0b => p6_0b,
                init_0c => p6_0c, init_0d => p6_0d, init_0e => p6_0e,
                init_0f => p6_0f)
    port map(addra => l_pc_o,                   addrb => i_pm_adr(11 downto 2),
             clka  => i_clk,                    clkb  => i_clk,
             dia   => "0000",                   dib   => "0000",
             ena   => l_wait_n,                 enb   => '1',
             rsta  => '0',                      rstb  => '0',
             wea   => '0',                      web   => '0',
             doa   => m_opc_o(11 downto 8),     dob   => m_pmd_o(11 downto 8));
 
    po_3 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => p7_00, init_01 => p7_01, init_02 => p7_02,
                init_03 => p7_03, init_04 => p7_04, init_05 => p7_05,
                init_06 => p7_06, init_07 => p7_07, init_08 => p7_08,
                init_09 => p7_09, init_0a => p7_0a, init_0b => p7_0b, 
                init_0c => p7_0c, init_0d => p7_0d, init_0e => p7_0e,
                init_0f => p7_0f)
    port map(addra => l_pc_o,                   addrb => i_pm_adr(11 downto 2),
             clka  => i_clk,                    clkb  => i_clk,
             dia   => "0000",                   dib   => "0000",
             ena   => l_wait_n,                 enb   => '1',
             rsta  => '0',                      rstb  => '0',
             wea   => '0',                      web   => '0',
             doa   => m_opc_o(15 downto 12),    dob   => m_pmd_o(15 downto 12));

    -- remember i_pc0 and i_pm_adr for the output mux.
    --
    pc0: process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            q_pc <= i_pc;
            l_pm_adr_1_0 <= i_pm_adr(1 downto 0);
            if ((i_wait = '0')) then
                l_pc_0 <= i_pc(0);
            end if;
        end if;
    end process;

    l_wait_n <= not i_wait;

    -- we use two memory blocks _e and _o (even and odd).
    -- this gives us a quad-port memory so that we can access
    -- i_pc, i_pc + 1, and pm simultaneously.
    --
    -- i_pc and i_pc + 1 are handled by port a of the memory while pm
    -- is handled by port b.
    --
    -- q_opc(15 ... 0) shall contain the word addressed by i_pc, while
    -- q_opc(31 ... 16) shall contain the word addressed by i_pc + 1.
    --
    -- there are two cases:
    --
    -- case a: i_pc     is even, thus i_pc + 1 is odd
    -- case b: i_pc + 1 is odd , thus i_pc is even
    --
    l_pc_o <= i_pc(10 downto 1);
    l_pc_e <= i_pc(10 downto 1) + ("000000000" & i_pc(0));
    q_opc(15 downto  0) <= m_opc_e when l_pc_0 = '0' else m_opc_o;
    q_opc(31 downto 16) <= m_opc_e when l_pc_0 = '1' else m_opc_o;

    l_pmd <= m_pmd_e               when (l_pm_adr_1_0(1) = '0') else m_pmd_o;
    q_pm_dout <= l_pmd(7 downto 0) when (l_pm_adr_1_0(0) = '0')
            else l_pmd(15 downto 8);
    
end behavioral;

