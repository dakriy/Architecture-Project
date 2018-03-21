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
-- create date:    14:22:28 11/07/2009 
-- design name: 
-- module name:    uart_rx - behavioral 
-- description:    a uart receiver.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_rx is
    port(   i_clk       : in  std_logic;
            i_reset       : in  std_logic;
            i_ce_16     : in  std_logic;            -- 16 times baud rate 
            i_rx        : in  std_logic;            -- serial input line
 
            q_data      : out std_logic_vector(7 downto 0);
            q_flag      : out std_logic);       -- toggle on every byte received
end uart_rx;
 
architecture behavioral of uart_rx is
 
signal l_position       : std_logic_vector(7 downto 0);     --  sample position
signal l_buf            : std_logic_vector(9 downto 0); 
signal l_flag           : std_logic; 
signal l_serin          : std_logic;                -- double clock the input
signal l_ser_hot        : std_logic;                -- double clock the input
 
begin
 
    -- double clock the input data...
    --
    process(i_clk)
    begin
        if (rising_edge(i_clk)) then  
            if (i_reset = '1') then
                l_serin <= '1';
                l_ser_hot <= '1';
            else
                l_serin   <= i_rx;
                l_ser_hot <= l_serin;
            end if;
        end if;
    end process;
 
    process(i_clk, l_position)
        variable start_bit : boolean;
        variable stop_bit  : boolean;
        variable stop_pos  : boolean;
 
    begin
    start_bit := l_position(7 downto 4) = x"0";
    stop_bit  := l_position(7 downto 4) = x"9";
    stop_pos  := stop_bit and l_position(3 downto 2) = "11"; -- 3/4 of stop bit
 
        if (rising_edge(i_clk)) then  
            if (i_reset = '1') then
                l_flag <= '0';
                l_position <= x"00";    -- idle
                l_buf      <= "1111111111";
                q_data     <= "00000000";
            elsif (i_ce_16 = '1') then    
                if (l_position = x"00") then            -- uart idle
                    l_buf  <= "1111111111";
                    if (l_ser_hot = '0')  then          -- start bit received
                        l_position <= x"01";
                    end if;
                else
                    l_position <= l_position + x"01";
                    if (l_position(3 downto 0) = "0111") then       -- 1/2 bit
                        l_buf <= l_ser_hot & l_buf(9 downto 1);     -- sample data
                        --
                        -- validate start bit
                        --
                        if (start_bit and l_ser_hot = '1') then     -- 1/2 start bit
                            l_position <= x"00";
                        end if;
 
                        if (stop_bit) then                          -- 1/2 stop bit
                            q_data <= l_buf(9 downto 2);
                        end if;
                    elsif (stop_pos) then                       -- 3/4 stop bit
                        l_flag <= l_flag xor (l_buf(9) and not l_buf(0));
                        l_position <= x"00";
                    end if;
                end if;
            end if;
        end if;
    end process;    
 
    q_flag <= l_flag;
 
end behavioral;
 
