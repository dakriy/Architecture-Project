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
-- module name:    segment7 - behavioral 
-- create date:    12:52:16 11/11/2009 
-- description:    a 7 segment led display interface.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity segment7 is
    port ( i_clk        : in  std_logic;

           i_reset        : in  std_logic;
           i_opc        : in  std_logic_vector(15 downto 0);
           i_pc         : in  std_logic_vector(15 downto 0);

           q_7_segment : out std_logic_vector( 6 downto 0));
end segment7;

--      signal      loc alt
---------------------------
--      seg_led(0)  v3  a
--      seg_led(1)  v4  b
--      seg_led(2)  w3  c
--      seg_led(3)  t4  d
--      seg_led(4)  t3  e
--      seg_led(5)  u3  f
--      seg_led(6)  u4  g
--
architecture behavioral of segment7 is

function lmap(val: std_logic_vector( 3 downto 0))
         return std_logic_vector is
begin
    case val is         --      6543210
        when "0000" =>  return "0111111";   -- 0
        when "0001" =>  return "0000110";   -- 1
        when "0010" =>  return "1011011";   -- 2
        when "0011" =>  return "1001111";   -- 3
        when "0100" =>  return "1100110";   -- 4    ----a----       ----0----
        when "0101" =>  return "1101101";   -- 5    |       |       |       |
        when "0110" =>  return "1111101";   -- 6    f       b       5       1
        when "0111" =>  return "0000111";   -- 7    |       |       |       |
        when "1000" =>  return "1111111";   -- 8    +---g---+       +---6---+
        when "1001" =>  return "1101111";   -- 9    |       |       |       |
        when "1010" =>  return "1110111";   -- a    e       c       4       2
        when "1011" =>  return "1111100";   -- b    |       |       |       |
        when "1100" =>  return "0111001";   -- c    ----d----       ----3----
        when "1101" =>  return "1011110";   -- d
        when "1110" =>  return "1111001";   -- e
        when others =>  return "1110001";   -- f
    end case;
end;

signal l_cnt            : std_logic_vector(27 downto 0);
signal l_opc            : std_logic_vector(15 downto 0);
signal l_pc             : std_logic_vector(15 downto 0);
signal l_pos            : std_logic_vector( 3 downto 0);

begin

    process(i_clk)    -- 20 mhz
    begin
        if (rising_edge(i_clk)) then
            if (i_reset = '1') then
                l_pos <= "0000";
                l_cnt <= x"0000000";
                q_7_segment <= "1111111";
            else
                l_cnt <= l_cnt + x"0000001";
                if (l_cnt =  x"0c00000") then
                    q_7_segment <= "1111111";      -- blank
                elsif (l_cnt =  x"1000000") then
                    l_cnt <= x"0000000";
                    l_pos <= l_pos + "0001";
                    case l_pos is
                        when "0000" =>  -- blank
                            q_7_segment <= "1111111";
                        when "0001" =>
                            l_pc <= i_pc;       -- sample pc
                            l_opc <= i_opc;     -- sample opc
                            q_7_segment <= not lmap(l_pc(15 downto 12));
                        when "0010" =>
                            q_7_segment <= not lmap(l_pc(11 downto  8));
                        when "0011" =>
                            q_7_segment <= not lmap(l_pc( 7 downto  4));
                        when "0100" =>
                            q_7_segment <= not lmap(l_pc( 3 downto  0));
                        when "0101" =>  -- minus
                            q_7_segment <= "0111111";
                        when "0110" =>
                            q_7_segment <= not lmap(l_opc(15 downto 12));
                        when "0111" =>
                            q_7_segment <= not lmap(l_opc(11 downto  8));
                        when "1000" =>
                            q_7_segment <= not lmap(l_opc( 7 downto  4));
                        when "1001" =>
                            q_7_segment <= not lmap(l_opc( 3 downto  0));
                            l_pos <= "0000";
                        when others =>
                            l_pos <= "0000";
                    end case;
                end if;
            end if;
        end if;
    end process;
    
end behavioral;

