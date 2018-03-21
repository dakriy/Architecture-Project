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
-- module name:     booths_architecture - behavioral 
-- create date:     13:51:24 11/07/2009 
-- description:     top level of a cpu
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity booths_architecture is
    port (  i_clk_100   : in  std_logic;
            i_switch    : in  std_logic_vector(9 downto 0);
            i_rx        : in  std_logic;

            q_7_segment : out std_logic_vector(6 downto 0);
            q_leds      : out std_logic_vector(3 downto 0);
            q_tx        : out std_logic);
end booths_architecture;

architecture behavioral of booths_architecture is

component cpu_core
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
end component;

signal  c_pc            : std_logic_vector(15 downto 0);
signal  c_opc           : std_logic_vector(15 downto 0);
signal  c_adr_io        : std_logic_vector( 7 downto 0);
signal  c_dout          : std_logic_vector( 7 downto 0);
signal  c_rd_io         : std_logic;
signal  c_we_io         : std_logic;

component io
    port (  i_clk       : in  std_logic;
            i_reset       : in  std_logic;
            i_adr_io    : in  std_logic_vector( 7 downto 0);
            i_din       : in  std_logic_vector( 7 downto 0);
            i_rd_io     : in  std_logic;
            i_we_io     : in  std_logic;
            i_switch    : in  std_logic_vector( 7 downto 0);
            i_rx        : in  std_logic;

            q_7_segment : out std_logic_vector( 6 downto 0);
            q_dout      : out std_logic_vector( 7 downto 0);
            q_intvec    : out std_logic_vector(5 downto 0);
            q_leds      : out std_logic_vector( 1 downto 0);
            q_tx        : out std_logic);
end component;

signal n_intvec         : std_logic_vector( 5 downto 0);
signal n_dout           : std_logic_vector( 7 downto 0);
signal n_tx             : std_logic;
signal n_7_segment      : std_logic_vector( 6 downto 0);

component segment7
    port ( i_clk        : in  std_logic;

           i_reset        : in  std_logic;
           i_opc        : in  std_logic_vector(15 downto 0);
           i_pc         : in  std_logic_vector(15 downto 0);

           q_7_segment  : out std_logic_vector( 6 downto 0));
end component;

signal s_7_segment      : std_logic_vector( 6 downto 0);

signal l_clk            : std_logic := '0';
signal l_clk_cnt        : std_logic_vector( 2 downto 0) := "000";
signal l_reset            : std_logic;            -- reset,  active low
signal l_reset_n          : std_logic := '0';     -- reset,  active low
signal l_c1_n           : std_logic := '0';     -- switch debounce, active low
signal l_c2_n           : std_logic := '0';     -- switch debounce, active low

begin

    cpu : cpu_core
    port map(   i_clk       => l_clk,
                i_reset       => l_reset,
                i_din       => n_dout,
                i_intvec    => n_intvec,

                q_adr_io    => c_adr_io,
                q_dout      => c_dout,
                q_opc       => c_opc,
                q_pc        => c_pc,
                q_rd_io     => c_rd_io,
                q_we_io     => c_we_io);

    ino : io
    port map(   i_clk       => l_clk,
                i_reset       => l_reset,
                i_adr_io    => c_adr_io,
                i_din       => c_dout,
                i_rd_io     => c_rd_io,
                i_rx        => i_rx,
                i_switch    => i_switch(7 downto 0),
                i_we_io     => c_we_io,

                q_7_segment => n_7_segment,
                q_dout      => n_dout,
                q_intvec    => n_intvec,
                q_leds      => q_leds(1 downto 0),
                q_tx        => n_tx);

    seg : segment7
    port map(   i_clk       => l_clk,
                i_reset       => l_reset,
                i_opc       => c_opc,
                i_pc        => c_pc,

                q_7_segment => s_7_segment);
    
    -- input clock scaler
    --
    clk_div : process(i_clk_100)
    begin
        if (rising_edge(i_clk_100)) then
            l_clk_cnt <= l_clk_cnt + "001";
            if (l_clk_cnt = "001") then
                l_clk_cnt <= "000";
                l_clk <= not l_clk;
            end if;
        end if;
    end process;
    
    -- reset button debounce process
    --
    deb : process(l_clk)
    begin
        if (rising_edge(l_clk)) then
            -- switch debounce
            if ((i_switch(8) = '0') or (i_switch(9) = '0')) then    -- pushed
                l_reset_n <= '0';
                l_c2_n  <= '0';
                l_c1_n  <= '0';
            else                                                    -- released
                l_reset_n <= l_c2_n;
                l_c2_n  <= l_c1_n;
                l_c1_n  <= '1';
            end if;
        end if;
    end process;

    l_reset <= not l_reset_n;

    q_leds(2) <= i_rx;
    q_leds(3) <= n_tx;
    q_7_segment  <= n_7_segment when (i_switch(7) = '1') else s_7_segment;
    q_tx <= n_tx;

end behavioral;

