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
-- module name:    baudgen - behavioral 
-- create date:    13:51:24 11/07/2009 
-- description:    fixed baud rate generator
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity baudgen is
    generic(clock_freq  : std_logic_vector(31 downto 0);
	        baud_rate   : std_logic_vector(27 downto 0));
    port(   i_clk       : in  std_logic;

            i_reset       : in  std_logic;
            q_ce_1      : out std_logic;    -- baud x  1 clock enable
            q_ce_16     : out std_logic);   -- baud x 16 clock enable
end baudgen;

 
architecture behavioral of baudgen is
 
constant baud_16        : std_logic_vector(31 downto 0) := baud_rate & "0000";
constant limit          : std_logic_vector(31 downto 0) := clock_freq - baud_16;
 
signal l_ce_16          : std_logic;
signal l_cnt_16         : std_logic_vector( 3 downto 0);
signal l_counter        : std_logic_vector(31 downto 0);
 
begin
 
    baud16: process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (i_reset = '1') then
                l_counter <= x"00000000";
            elsif (l_counter >= limit) then
                l_counter <= l_counter - limit;
            else
                l_counter <= l_counter + baud_16;
            end if;
        end if;
    end process;
 
    baud1: process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (i_reset = '1') then
                l_cnt_16 <= "0000";
            elsif (l_ce_16 = '1') then
                l_cnt_16 <= l_cnt_16 + "0001";
            end if;
        end if;
    end process;

    l_ce_16 <= '1' when (l_counter >= limit) else '0';
    q_ce_16 <= l_ce_16;
    q_ce_1 <= l_ce_16 when l_cnt_16 = "1111" else '0';

end behavioral;
 
