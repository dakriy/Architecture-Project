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
  --relate hex values to which leds are on
  --remember that
  case val is --relate hex values to which leds are on
    when x"0" => return "1000000"; --0
    when x"1" => return "1111001"; --1
    when x"2" => return "0100100"; --2
    when x"3" => return "0110000"; --3
    when x"4" => return "1100110"; --4
    when x"5" => return "0010010"; --5
    when x"6" => return "0000010"; --6
    when x"7" => return "1111000"; --7
    when x"8" => return "0000000"; --8
    when x"9" => return "0010000"; --9
    when x"A" => return "0001000"; --A
    when x"B" => return "0000011"; --b
    when x"C" => return "0100111"; --c
    when x"D" => return "0100001"; --d
    when x"E" => return "0000110"; --E
    when x"F" => return "0001110"; --F
  end case;
end;

signal l_count    : std_logic_vector(27 downto 0); --a counter used to divide 100MHz clock
signal l_opc      : std_logic_vector(15 downto 0); --opcode_decoder
signal l_pc       : std_logic_vector(15 downto 0); --program refresh_counter
signal l_position : std_logic_vector( 3 downto 0); --

begin

  process(i_clk, i_reset)
  begin
    if (rising_edge(i_clk)) then
      if (i_reset = '1') then --if the reset is on, reset the counter and make leds blank
        l_position <= "0000";
        l_count <= x"0000000";
        q_7_segment <= "1111111";
      else --if reset is off, set values to be shown every second for .75s
        l_count <= l_count + X"0000001";
        if (l_count = X"0C00000") then
          q_7_segment <= "1111111"; -- blank
        elsif (l_count = X"1000000") then
          l_count <= X"0000000";
          l_position <= l_position + "0001";

          --show debug message (the program counter and opcode) one nibble at a time
          --ie pc3 pc2 pc1 pc0 - opc3 opc2 opc1 opc0
          case l_position is
            when "0000" => -- blank
              q_7_segment <= "1111111";

            when "0001" =>
              l_pc <= i_pc; -- sample PC
              l_opc <= i_opc; -- sample OPC
              q_7_segment <= segment_map(l_pc(15 downto 12));

            when "0010" =>
              q_7_segment <= segment_map(l_pc(11 downto 8));

            when "0011" =>
              q_7_segment <= segment_map(l_pc( 7 downto 4));

            when "0100" =>
              q_7_segment <= segment_map(l_pc( 3 downto 0));

            when "0101" => -- minus
              q_7_segment <= "0111111";

            when "0110" =>
              q_7_segment <= segment_map(l_opc(15 downto 12));

            when "0111" =>
              q_7_segment <= segment_map(l_opc(11 downto 8));

            when "1000" =>
              q_7_segment <= segment_map(l_opc( 7 downto 4));

            when "1001" =>
              q_7_segment <= segment_map(l_opc( 3 downto 0));
              l_position <= "0000";

            when others =>
              l_position <= "0000";

          end case;
        end if;
      end if;
    end if;
  end process;  
end Behavioral;
