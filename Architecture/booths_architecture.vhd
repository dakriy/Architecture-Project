-------------------------------------------------------------------------------
--
-- Module Name:     booths_architecture
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     describes how the top level acts.
-- Details:         it has 2 switches, 2 buttons, 4 leds, and a 7 segment display
--                  also has UART capability
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity booths_architecture is
  port( i_clk_100    : in  std_logic; --50MHz clock
        i_switch    : in  std_logic_vector(  7 downto 0 ); --two switches and two buttons
        i_rx        : in  std_logic; --serial input of UART

        q_7_segment : out std_logic_vector(  6 downto 0 ); --7 segment display for debugging
        q_leds      : out std_logic_vector(  3 downto 0 )); --8 lines for LEDs
end booths_architecture;

architecture Behavioral of booths_architecture is
component cpu_core
  port( i_clk   : in  std_logic;
        i_reset : in  std_logic;
        i_din   : in  std_logic_vector(  7 downto 0 );

        q_opc    : out std_logic_vector( 15 downto 0 );
        q_pc     : out std_logic_vector( 15 downto 0 );
        q_dout   : out std_logic_vector(  7 downto 0 );
        q_adr_io : out std_logic_vector(  7 downto 0 );
        q_rd_io  : out std_logic;
        q_we_io  : out std_logic);
end component;

signal c_pc     : std_logic_vector(15 downto 0);
signal c_opc    : std_logic_vector(15 downto 0);
signal c_adr_io : std_logic_vector(7 downto 0);
signal c_dout   : std_logic_vector(7 downto 0);
signal c_rd_io  : std_logic;
signal c_we_io  : std_logic;

component io
  port( i_clk       : in  std_logic;
        i_reset     : in  std_logic;
        i_adr_io    : in  std_logic_vector(7 downto 0);
        i_din       : in  std_logic_vector(7 downto 0);
        i_rd_io     : in  std_logic;
        i_we_io     : in  std_logic;
        i_switch    : in  std_logic_vector(7 downto 0);
        i_rx        : in  std_logic;

        q_7_segment : out std_logic_vector(6 downto 0);
        q_dout      : out std_logic_vector(7 downto 0);
        q_leds      : out std_logic_vector(3 downto 0));
end component;

signal n_dout      : std_logic_vector(7 downto 0);
signal n_7_segment : std_logic_vector(6 downto 0);

component seven_segment
  port( i_clk       : in std_logic;
        i_reset     : in std_logic;
        i_opc       : in std_logic_vector(15 downto 0);
        i_pc        : in std_logic_vector(15 downto 0);

        q_7_segment : out std_logic_vector(6 downto 0));
end component;

signal s_7_segment : std_logic_vector(6 downto 0);
signal l_clk       : std_logic;
signal l_clk_cnt   : std_logic_vector(2 downto 0);
signal l_reset     : std_logic;
signal l_reset_n   : std_logic := '0';
signal L_C1_N      : std_logic := '0';
signal L_C2_N      : std_logic := '0';

begin
  cpu:cpu_core
  port map( i_clk     => l_clk,
            i_reset   => l_reset,
            i_din     => n_dout,

            q_opc     => c_opc,
            q_pc      => c_pc,
            q_dout    => c_dout,
            q_adr_io  => c_adr_io,
            q_rd_io   => c_rd_io,
            q_we_io   => c_we_io);
  ino:io
  port map( i_clk       => l_clk,
            i_reset     => l_reset,
            i_adr_io    => c_adr_io,
            i_din       => c_dout,
            i_switch    => i_switch(7 downto 0),
            i_rd_io     => c_rd_io,
            i_rx        => i_rx,
            i_we_io     => c_we_io,

            q_7_segment => n_7_segment,
            q_dout      => n_dout,
            q_leds      => q_leds);
  seg:seven_segment
  port map( i_clk       => l_clk,
            i_reset     => l_reset,
            i_opc       => c_opc,
            i_pc        => c_pc,
            q_7_segment => s_7_segment);

  --clock divider
  clk_div:process(i_clk_100)
  begin
    if (rising_edge(i_clk_100)) then
      l_clk_cnt <= l_clk_cnt + "001";
      if (l_clk_cnt = "001") then
        l_clk_cnt <= "000";
        l_clk <= not l_clk;
      end if;
    end if;
  end process;

  --debounce i_reset
  deb:process(l_clk)
  begin
    if (rising_edge(l_clk)) then
      -- switch debounce
      if ((i_switch(6) = '0') or (i_switch(7) = '0')) then
        l_reset_n <= '0';
        l_c2_n <= '0';
        l_c1_n <= '0';
      else
        l_reset_n <= l_c2_n;
        l_c2_n <= l_c1_n;
        l_c1_n <= '1';
      end if;
    end if;
  end process;

  l_reset <= not l_reset_n;

  q_leds(2) <= i_rx;
  q_7_segment <= n_7_segment when (i_switch(7) = '1') else s_7_segment;
end Behavioral;
