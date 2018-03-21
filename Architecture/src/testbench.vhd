library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testbench is
end testbench;

architecture Behavioral of testbench is
component avr_fpga
  port( I_CLK_100   : in std_logic;
        I_SWITCH    : in std_logic_vector(9 downto 0);
        I_RX        : in std_logic;

        Q_7_SEGMENT : out std_logic_vector(6 downto 0);
        Q_LEDS      : out std_logic_vector(3 downto 0);
        Q_TX        : out std_logic);
end component;

signal L_CLK_100    : std_logic;
signal L_LEDS       : std_logic_vector(3 downto 0);
signal L_7_SEGMENT  : std_logic_vector(6 downto 0);
signal L_RX         : std_logic;
signal L_SWITCH     : std_logic_vector(7 downto 0);
signal L_TX         : std_logic;
signal L_CLK_COUNT  : integer := 0;

begin
  booths: booths_architecture
  port map( I_CLK_100 => L_CLK_100,
            I_SWITCH => L_SWITCH,
            I_RX => L_RX,
            Q_LEDS => L_LEDS,
            Q_7_SEGMENT => L_7_SEGMENT,
            Q_TX => L_TX);
  process
  begin
    clock_loop : loop
      L_CLK_100 <= transport '0';
      wait for 5 ns;
      L_CLK_100 <= transport '1';
      wait for 5 ns;
    end loop clock_loop;
  end process;

  process(L_CLK_100)
  begin
    if (rising_edge(L_CLK_100)) then
      case L_CLK_COUNT is
        when 0 =>
          L_SWITCH <= "0011100000";
          L_RX <= '0';
        when 2 =>
          L_SWITCH(9 downto 8) <= "11";
        when others =>
      end case;
      L_CLK_COUNT <= L_CLK_COUNT + 1;
    end if;
  end process;
end Behavioral;
