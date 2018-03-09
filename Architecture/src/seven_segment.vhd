library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity seven_segment is
  port( i_clk       : in  std_logic;

        i_clr       : in  std_logic;
        i_opc       : in  std_logic_vector( 15 downto 0 );
        i_pc        : in  std_logic_vector( 15 downto 0 );

        q_7_segment : out std_logic_vector(  6 downto 0 ));
end seven_segment;

--describe how the lights on the 7-segment display are related to hex numbers
function segment_map(val: std_logic_vector(3 downto 0)) return std_logic_vector is
begin
  ------0----
  --|       |
  --5       1
  --|       |
  --+---6---+
  --|       |
  --4       2
  --|       |
  ------3----

  case val is --leds to "6543210"
    when x"0" => return "0111111"
