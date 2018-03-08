--Describes how the top level acts.
--It has 2 stitches, 2 buttons 4 leds and a 7 segment display
--also has UART capability

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity booths_architecture is
  port( i_clk_50    : in  std_logic; --50MHz clock
        i_switch    : in  std_logic_vector(  3 downto 0 ); --two switches and two buttons
        i_rx        : in  std_logic; --serial input of UART

        q_7_segment : out std_logic_vector(  6 downto 0 ); --7 segment display for debugging
        q_leds      : out std_logic_vector(  3 downto 0 ); --4 lines for LEDs
        q_tx        : out std_logic --serial output of UART
  );

  --architecture Behavioral of booths_architecture is
