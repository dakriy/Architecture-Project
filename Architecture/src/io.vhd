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
-- module name:    io - behavioral 
-- create date:    13:59:36 11/07/2009 
-- description:    the i/o of a cpu (uart and general purpose i/o lines).
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity io is
    port (  i_clk       : in  std_logic;

            i_reset       : in  std_logic;
            i_adr_io    : in  std_logic_vector( 7 downto 0);
            i_din       : in  std_logic_vector( 7 downto 0);
            i_switch    : in  std_logic_vector( 7 downto 0);
            i_rd_io     : in  std_logic;
            i_rx        : in  std_logic;
            i_we_io     : in  std_logic;

            q_7_segment : out std_logic_vector( 6 downto 0);
            q_dout      : out std_logic_vector( 7 downto 0);
            q_intvec    : out std_logic_vector( 5 downto 0);
            q_leds      : out std_logic_vector( 1 downto 0);
            q_tx        : out std_logic);
end io;

architecture behavioral of io is

component uart
    generic(clock_freq  : std_logic_vector(31 downto 0);
            baud_rate   : std_logic_vector(27 downto 0));
    port(   i_clk       : in  std_logic;
            i_reset       : in  std_logic;
            i_rd        : in  std_logic;
            i_we        : in  std_logic;
            i_rx        : in  std_logic;          
            i_tx_data   : in  std_logic_vector(7 downto 0);

            q_rx_data   : out std_logic_vector(7 downto 0);
            q_rx_ready  : out std_logic;
            q_tx        : out std_logic;
            q_tx_busy   : out std_logic);
end component;

signal u_rx_ready       : std_logic;
signal u_tx_busy        : std_logic;
signal u_rx_data        : std_logic_vector( 7 downto 0);

signal l_intvec         : std_logic_vector( 5 downto 0);
signal l_leds           : std_logic;
signal l_rd_uart        : std_logic;
signal l_rx_int_enabled : std_logic;
signal l_tx_int_enabled : std_logic;
signal l_we_uart        : std_logic;

begin
    urt: uart
    generic map(clock_freq  => std_logic_vector(conv_unsigned(25000000, 32)),
                baud_rate   => std_logic_vector(conv_unsigned(   38400, 28)))
    port map(   i_clk      => i_clk,
                i_reset      => i_reset,
                i_rd       => l_rd_uart,
                i_we       => l_we_uart,
                i_tx_data  => i_din(7 downto 0),
                i_rx       => i_rx,

                q_tx       => q_tx,
                q_rx_data  => u_rx_data,
                q_rx_ready => u_rx_ready,
                q_tx_busy  => u_tx_busy);

    -- io read process
    --
    iord: process(i_adr_io, i_switch,
                  u_rx_data, u_rx_ready, l_rx_int_enabled,
                  u_tx_busy, l_tx_int_enabled)
    begin
        -- addresses for mega8 device (use iom8.h or #define __avr_atmega8__).
        --
        case i_adr_io is
            when x"2a"  => q_dout <=             -- ucsrb:
                               l_rx_int_enabled  -- rx complete int enabled.
                             & l_tx_int_enabled  -- tx complete int enabled.
                             & l_tx_int_enabled  -- tx empty int enabled.
                             & '1'               -- rx enabled
                             & '0'               -- tx disabled
                             & '0'               -- 8 bits/char
                             & '0'               -- rx bit 8
                             & '0';              -- tx bit 8
            when x"2b"  => q_dout <=             -- ucsra:
                               u_rx_ready       -- rx complete
                             & not u_tx_busy    -- tx complete
                             & not u_tx_busy    -- tx ready
                             & '0'              -- frame error
                             & '0'              -- data overrun
                             & '0'              -- parity error
                             & '0'              -- double dpeed
                             & '0';             -- multiproc mode
            when x"2c"  => q_dout <= u_rx_data; -- udr
            when x"40"  => q_dout <=            -- ucsrc
                               '1'              -- ursel
                             & '0'              -- asynchronous
                             & "00"             -- no parity
                             & '1'              -- two stop bits
                             & "11"             -- 8 bits/char
                             & '0';             -- rising clock edge

            when x"36"  => q_dout <= i_switch;  -- pinb
            when others => q_dout <= x"aa";
        end case;
    end process;

    -- io write process
    --
    iowr: process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (i_reset = '1') then
                l_rx_int_enabled  <= '0';
                l_tx_int_enabled  <= '0';
            elsif (i_we_io = '1') then
                case i_adr_io is
                    when x"38"  => -- portb
                                   q_7_segment <= i_din(6 downto 0);
                                   l_leds <= not l_leds;
                    when x"2a"  => -- ucsrb
                                   l_rx_int_enabled <= i_din(7);
                                   l_tx_int_enabled <= i_din(6);
                    when x"2b"  => -- ucsra:       handled by uart
                    when x"2c"  => -- udr:         handled by uart
                    when x"40"  => -- ucsrc/ubrrh: (ignored)
                    when others =>
                end case;
            end if;
        end if;
    end process;

    -- interrupt process
    --
    ioint: process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (i_reset = '1') then
                l_intvec <= "000000";
            else
                case l_intvec is
                    when "101011" => -- vector 11 interrupt pending.
                        if (l_rx_int_enabled and u_rx_ready) = '0' then
                            l_intvec <= "000000";
                        end if;

                    when "101100" => -- vector 12 interrupt pending.
                        if (l_tx_int_enabled and not u_tx_busy) = '0' then
                            l_intvec <= "000000";
                        end if;

                    when others   =>
                        -- no interrupt is pending.
                        -- we accept a new interrupt.
                        --
                        if    (l_rx_int_enabled and u_rx_ready) = '1' then
                            l_intvec <= "101011";            -- _vector(11)
                        elsif (l_tx_int_enabled and not u_tx_busy) = '1' then
                            l_intvec <= "101100";            -- _vector(12)
                        else
                            l_intvec <= "000000";            -- no interrupt
                        end if;
                end case;
            end if;
        end if;
    end process;

    l_we_uart <= i_we_io when (i_adr_io = x"2c") else '0'; -- write uart udr
    l_rd_uart <= i_rd_io when (i_adr_io = x"2c") else '0'; -- read  uart udr

    q_leds(1) <= l_leds;
    q_leds(0) <= not l_leds;
    q_intvec  <= l_intvec;

end behavioral;

