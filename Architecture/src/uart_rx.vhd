library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity uart_rx is
  port( i_clk       : in  std_logic; --global clock
        i_clr       : in  std_logic; --reset signal
        i_baud_16   : in  std_logic; --16 times baud rate
        i_rx        : in  std_logic; --serial input line

        q_data      : out std_logic_vector( 7 downto 0 ); --byte to receive
        q_flag      : out std_logic); --toggle on byte receive
end uart_rx;

signal l_position   : std_logic_vector( 7 downto 0 ); --sample position
signal l_buffer     : std_logic_vector( 9 downto 0 ); --sample buffer
signal l_flag       : std_logic; --flag
signal l_serial_in  : std_logic; --double clock the input
signal l_serial_in2 : std_logic; --double clock the input

begin
  --double clock input
  -- When receiving, at start bit enabled, we read the input after 52ns
  -- After that, the input is read every 104ns in order to read the middle
  -- of the bit
  process( i_clk, i_clr )
  begin
    if (rising_edge(i_clk)) then
      if (i_clr = '1') then
        l_serial_in  <= '1';
        l_serial_in2 <= '1';
      else
        l_serial_in  <= i_rx;
        l_serial_in2 <= l_serial_in;
      end if;
    end if;
  end process;

  process(i_clk, l_position)
  variable start : boolean;
  begin
    if
