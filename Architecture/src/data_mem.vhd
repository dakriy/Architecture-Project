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
-- module name:    data_mem - behavioral 
-- create date:    14:09:04 10/30/2009 
-- description:    the data mempry of a cpu.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity data_mem is
    port (  i_clk       : in  std_logic;

            i_adr       : in  std_logic_vector(10 downto 0);
            i_din       : in  std_logic_vector(15 downto 0);
            i_we        : in  std_logic_vector( 1 downto 0);

            q_dout      : out std_logic_vector(15 downto 0));
end data_mem;

architecture behavioral of data_mem is
 
constant zero_256 : bit_vector := x"00000000000000000000000000000000"
                                & x"00000000000000000000000000000000";
constant nine_256 : bit_vector := x"99999999999999999999999999999999"
                                & x"99999999999999999999999999999999";

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

    port(   doa     : out std_logic_vector(3 downto 0);
            dob     : out std_logic_vector(3 downto 0);
            addra   : in  std_logic_vector(9 downto 0);
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
            web     : in  std_ulogic);
end component;

signal l_adr_0      : std_logic;
signal l_adr_e      : std_logic_vector(10 downto 1);
signal l_adr_o      : std_logic_vector(10 downto 1);
signal l_din_e      : std_logic_vector( 7 downto 0);
signal l_din_o      : std_logic_vector( 7 downto 0);
signal l_dout_e     : std_logic_vector( 7 downto 0);
signal l_dout_o     : std_logic_vector( 7 downto 0);
signal l_we_e       : std_logic;
signal l_we_o       : std_logic;
 
begin

    sr_0 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => nine_256, init_01 => nine_256, init_02 => nine_256,
                init_03 => nine_256, init_04 => nine_256, init_05 => nine_256,
                init_06 => nine_256, init_07 => nine_256, init_08 => nine_256,
                init_09 => nine_256, init_0a => nine_256, init_0b => nine_256,
                init_0c => nine_256, init_0d => nine_256, init_0e => nine_256,
                init_0f => nine_256)

    port map(   addra => l_adr_e,               addrb => "0000000000",
                clka  => i_clk,                 clkb  => i_clk,
                dia   => l_din_e(3 downto 0),   dib   => "0000",
                ena   => '1',                   enb   => '0',
                rsta  => '0',                   rstb  => '0',
                wea   => l_we_e,                web   => '0',
                doa   => l_dout_e(3 downto 0),  dob   => open);
 
    sr_1 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => nine_256, init_01 => nine_256, init_02 => nine_256,
                init_03 => nine_256, init_04 => nine_256, init_05 => nine_256,
                init_06 => nine_256, init_07 => nine_256, init_08 => nine_256,
                init_09 => nine_256, init_0a => nine_256, init_0b => nine_256,
                init_0c => nine_256, init_0d => nine_256, init_0e => nine_256,
                init_0f => nine_256)

    port map(   addra => l_adr_e,               addrb => "0000000000",
                clka  => i_clk,                 clkb  => i_clk,
                dia   => l_din_e(7 downto 4),   dib   => "0000",
                ena   => '1',                   enb   => '0',
                rsta  => '0',                   rstb  => '0',
                wea   => l_we_e,                web   => '0',
                doa   => l_dout_e(7 downto 4),  dob   => open);
 
    sr_2 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => nine_256, init_01 => nine_256, init_02 => nine_256,
                init_03 => nine_256, init_04 => nine_256, init_05 => nine_256,
                init_06 => nine_256, init_07 => nine_256, init_08 => nine_256,
                init_09 => nine_256, init_0a => nine_256, init_0b => nine_256,
                init_0c => nine_256, init_0d => nine_256, init_0e => nine_256,
                init_0f => nine_256)

    port map(   addra => l_adr_o,               addrb => "0000000000",
                clka  => i_clk,                 clkb  => i_clk,
                dia   => l_din_o(3 downto 0),   dib   => "0000",
                ena   => '1',                   enb   => '0',
                rsta  => '0',                   rstb  => '0',
                wea   => l_we_o,                web   => '0',
                doa   => l_dout_o(3 downto 0),  dob   => open);
 
    sr_3 : ramb4_s4_s4 ---------------------------------------------------------
    generic map(init_00 => nine_256, init_01 => nine_256, init_02 => nine_256,
                init_03 => nine_256, init_04 => nine_256, init_05 => nine_256,
                init_06 => nine_256, init_07 => nine_256, init_08 => nine_256,
                init_09 => nine_256, init_0a => nine_256, init_0b => nine_256,
                init_0c => nine_256, init_0d => nine_256, init_0e => nine_256,
                init_0f => nine_256)

    port map(   addra => l_adr_o,               addrb => "0000000000",
                clka  => i_clk,                 clkb  => i_clk,
                dia   => l_din_o(7 downto  4),  dib   => "0000",
                ena   => '1',                   enb   => '0',
                rsta  => '0',                   rstb  => '0',
                wea   => l_we_o,                web   => '0',
                doa   => l_dout_o(7 downto  4), dob   => open);
 

    -- remember adr(0)
    --
    adr0: process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            l_adr_0 <= i_adr(0);
        end if;
    end process;

    -- we use two memory blocks _e and _o (even and odd).
    -- this gives us a memory with adr and adr + 1 at th same time.
    -- the second port is currently unused, but may be used later,
    -- e.g. for dma.
    --

    l_adr_o <= i_adr(10 downto 1);
    l_adr_e <= i_adr(10 downto 1) + ("000000000" & i_adr(0));

    l_din_e <= i_din( 7 downto 0) when (i_adr(0) = '0') else i_din(15 downto 8);
    l_din_o <= i_din( 7 downto 0) when (i_adr(0) = '1') else i_din(15 downto 8);

    l_we_e <= i_we(1) or (i_we(0) and not i_adr(0));
    l_we_o <= i_we(1) or (i_we(0) and     i_adr(0));

    q_dout( 7 downto 0) <= l_dout_e when (l_adr_0 = '0') else l_dout_o;
    q_dout(15 downto 8) <= l_dout_e when (l_adr_0 = '1') else l_dout_o;
 
end behavioral;

