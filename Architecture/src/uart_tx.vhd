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
-- module name:    uart_tx - behavioral 
-- create date:    14:21:59 11/07/2009 
-- description:    a uart receiver.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_tx is 
    port(   i_clk       : in  std_logic;    
            i_reset       : in  std_logic;            -- reset
            i_ce_1      : in  std_logic;            -- baud rate clock enable
            i_data      : in  std_logic_vector(7 downto 0);   -- data to send
            i_flag      : in  std_logic;            -- toggle to send data
            q_tx_n      : out std_logic;            -- serial output, active low
            q_busy      : out std_logic);           -- transmitter busy
end uart_tx;
 
architecture behavioral of uart_tx is
 
signal l_buf            : std_logic_vector(8 downto 0);
signal l_flag           : std_logic;
signal l_todo           : std_logic_vector(3 downto 0);     -- bits to send
 
begin
 
    process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (i_reset = '1') then               -- reset
                q_tx_n <= '1';
                l_buf  <= "111111111";
                l_todo <= "0000";
                l_flag <= i_flag;
            elsif (l_todo = "0000") then        -- idle
                if (l_flag /= i_flag) then      -- new byte
                    l_buf <= i_data & '0';      -- 8 data / 1 start
                    l_todo <= "1100";           -- 11 bits to send
                    l_flag <= i_flag;
                end if;
            else                                -- shifting
                if (i_ce_1 = '1') then 
                    q_tx_n <= l_buf(0);
                    l_buf <= '1' & l_buf(8 downto 1);
                    l_todo <= l_todo - "0001";
                end if;
            end if;
        end if;
    end process; 
 
    q_busy <= '0' when (l_todo = "0000") else '1';
 
end behavioral;  

