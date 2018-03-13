----------------------------------------------------------------------------------
--
-- Module Name:     seven_segment
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     a 7 segment LED display interface.
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity seven_segment is
  port( i_clk       : in  std_logic;

        i_reset     : in  std_logic;
        i_opc       : in  std_logic_vector( 15 downto 0 );
        i_pc        : in  std_logic_vector( 15 downto 0 );

        q_7_segment : out std_logic_vector(  6 downto 0 ));
end seven_segment;

--describe how the lights on the 7-segment display are related to hex numbers
function segment_map(val: std_logic_vector(3 downto 0)) return std_logic_vector is
begin
  case val is --relate hex values to which leds are on
    when x"0" => return "0111111"; --0
    when x"0" => return "0000110"; --1
    when x"0" => return "1011011"; --2
    when x"0" => return "1001111"; --3
    when x"0" => return "1100110"; --4
    when x"0" => return "1101101"; --5
    when x"0" => return "1111101"; --6
    when x"0" => return "0000111"; --7
    when x"0" => return "1111111"; --8
    when x"0" => return "1101111"; --9
    when x"0" => return "1110111"; --A
    when x"0" => return "1111100"; --b
    when x"0" => return "1011000"; --c
    when x"0" => return "1011110"; --d
    when x"0" => return "1111001"; --E
    when x"0" => return "1110001"; --F
  end case;
end;

signal l_count : std_logic_vector()
