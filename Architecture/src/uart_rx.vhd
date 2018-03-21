----------------------------------------------------------------------------------
--
-- Module Name:     uart_rx
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     a UART receiver.
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity uart_rx is
  port( i_clk     : in  std_logic; --global clock
        i_reset   : in  std_logic; --reset signal
        i_baud_16 : in  std_logic; --16 times baud rate
        i_rx      : in  std_logic; --serial input line

        q_data    : out std_logic_vector( 7 downto 0 ); --byte to receive
        q_flag    : out std_logic); --toggle on byte receive
end uart_rx;

architecture Behavioral of uart_rx is
signal l_position : std_logic_vector( 7 downto 0 ); --sample position
signal l_buffer   : std_logic_vector( 9 downto 0 ); --sample buffer
signal l_flag     : std_logic; --transfer flag
signal l_serial : std_logic; --double clock the input
signal l_serial_bit : std_logic; --double clock the input

begin
  --double clock input
  -- When receiving, at start bit enabled, we read the input after 52ns
  -- After that, the input is read every 104ns in order to read the middle
  -- of the bit
  process(i_clk, i_reset)
  begin
    if (rising_edge(i_clk)) then
      if (i_reset = '1') then
        l_serial <= '1';
        l_serial_bit <= '1';
      else
        l_serial <= i_rx;
        l_serial_bit <= l_serial;
      end if;
    end if;
  end process;

  process(i_clk, l_position)
    variable start_bit     : boolean;
    variable stop_bit      : boolean;
    variable stop_position : boolean;

  begin
  start_bit := l_position(7 downto 4) = x"0"; --start bit located at the rising edge
  stop_bit := l_position(7 downto 4) = x"9"; --stop bit located just after the falling edge
  stop_position := stop_bit and l_position(3 downto 2) = "11"; -- stop position at end of clock cycle

    if (rising_edge(i_clk)) then
      if (i_reset = '1') then --if reset set at rising edge, initialise everything
        l_flag <= '0';
        l_position <= x"00"; --uart idle
        l_buffer <= "1111111111";
        q_data <= x"FF";
      elsif (i_baud_16 = '1') then --else, if uart communication set, transfer data
        if (l_position = x"00") then --if uart idle and start bit received, set position to 1
          l_buffer <= "1111111111"; --reset transfer buffer
          if (l_serial_bit = '0') then --if start bit received
            l_position <= x"01"; --set position to 1
          end if;
        else --if uart not idle
          l_position <= l_position + x"01"; --increment position
          if (l_position(3 downto 0) = "0111") then --sample data at middle of cycle
            l_buffer <= l_serial_bit & l_buffer(9 downto 1);
            if (start_bit and l_serial_bit = '1') then --check if start bit is noise
              l_position <= x"00";
            end if;
            if (stop_bit = '1') then --if stop bit, then transfer byte
              q_data <= l_buffer(9 downto 2);
            end if;
          elsif (stop_position = '1') then --if transfer done, set transfer flag
            l_flag <= l_flag xor (l_buffer(9) and not l_buffer(0)); --set flag if byte has been read
            l_position <= x"00"; --reset position
          end if;
        end if;
      end if;
    end if;
  end process;

  q_flag <= l_flag;
end Behavioral;
