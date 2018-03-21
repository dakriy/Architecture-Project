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
-- module name:    uart_baudgen - behavioral 
-- create date:    14:34:27 11/07/2009 
-- description:    a uart and a fixed baud rate generator.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart is
    generic(clock_freq  : std_logic_vector(31 downto 0);
            baud_rate   : std_logic_vector(27 downto 0));
    port(   i_clk     : in  std_logic;
            i_reset     : in  std_logic;
 
            i_rd        : in  std_logic;
            i_we        : in  std_logic;
 
            i_tx_data   : in  std_logic_vector(7 downto 0);
            i_rx        : in  std_logic;

            q_tx        : out std_logic;
            q_rx_data   : out std_logic_vector(7 downto 0);
            q_rx_ready  : out std_logic;
            q_tx_busy   : out std_logic);
end uart;
 
architecture behavioral of uart is
 
component baudgen
    generic(clock_freq  : std_logic_vector(31 downto 0);
            baud_rate   : std_logic_vector(27 downto 0));
    port(   i_clk       : in  std_logic;

            i_reset       : in  std_logic;

            q_ce_1      : out std_logic;
            q_ce_16     : out std_logic);
end component;
 
signal b_ce_1           : std_logic;
signal b_ce_16          : std_logic;

component uart_rx
    port(   i_clk       : in  std_logic;
            i_reset       : in  std_logic;
            i_ce_16     : in  std_logic;
            i_rx        : in  std_logic;

            q_data      : out std_logic_vector(7 downto 0);
            q_flag      : out std_logic);
end component;

signal r_rx_flag        : std_logic;

component uart_tx
    port(   i_clk       : in  std_logic;
            i_reset       : in  std_logic;
            i_ce_1      : in  std_logic;
            i_data      : in  std_logic_vector(7 downto 0);
            i_flag      : in  std_logic;

            q_tx_n      : out std_logic;
            q_busy      : out std_logic);
end component;

signal l_rx_old_flag    : std_logic;
signal l_rx_ready       : std_logic;
signal l_tx_flag        : std_logic;
signal l_tx_data        : std_logic_vector(7 downto 0);
 
begin
 
    q_rx_ready <= l_rx_ready;
 
    baud: baudgen
    generic map(clock_freq  => clock_freq,
                baud_rate   => baud_rate)
    port map(   i_clk       => i_clk,

                i_reset       => i_reset,
                q_ce_1      => b_ce_1,
                q_ce_16     => b_ce_16);
 
    rx: uart_rx
    port map(   i_clk   => i_clk,
                i_reset   => i_reset,
                i_ce_16 => b_ce_16,
                i_rx    => i_rx,

                q_data  => q_rx_data,
                q_flag  => r_rx_flag);

    tx: uart_tx
    port map(   i_clk   => i_clk,
                i_reset   => i_reset,
                i_ce_1  => b_ce_1,
                i_data  => l_tx_data,
                i_flag  => l_tx_flag,

                q_tx_n  => q_tx,
                q_busy  => q_tx_busy);
 
    process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (i_reset = '1') then
                l_rx_old_flag <= r_rx_flag;
                l_rx_ready <= '0';
                l_tx_flag <= '0';
                l_tx_data <= x"33";
            else
                if (i_rd = '1') then          -- read rx data
                    l_rx_ready    <= '0';
                end if;
 
                if (i_we = '1') then          -- write tx data
                    l_tx_flag  <= not l_tx_flag;
                    l_tx_data <= i_tx_data;
                end if;
 
                if (l_rx_old_flag /= r_rx_flag) then
                    l_rx_old_flag <= r_rx_flag;
                    l_rx_ready <= '1';
                end if;
            end if;
        end if;
    end process;
 
end behavioral;

