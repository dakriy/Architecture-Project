library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity io is
  port( i_clk       : in  std_logic;
        i_clr       : in  std_logic_vector( 7 downto 0 );
        i_adr_io    : in  std_logic_vector( 7 downto 0 );
        i_din       : in  std_logic_vector( 7 downto 0 );
        i_switch    : in  std_logic_vector( 7 downto 0 );
        i_rd_io     : in  std_logic;
        i_rx        : in  std_logic;
        i_we_io     : in  std_logic;

        q_7_segment : out std_logic_vector( 7 downto 0 );
        q_dout      : out std_logic_vector( 7 downto 0 );
        q_leds      : out std_logic_vector( 7 downto 0 ));
end io;

architecture Behavioral of io is
component uart
  generic(clk_freq   : std_logic_vector(31 downto 0);
          baud_rate  : std_logic_vector(27 downto 0));
  port(   i_clk      : in  std_logic;
          i_reset    : in  std_logic;
          i_rd       : in  std_logic;
          i_we       : in  std_logic;
          i_rx       : in  std_logic;

          q_rx_data  : out std_logic_vector(7 downto 0);
          q_rx_ready : out std_logic);
end component;

signal u_rx_ready       : std_logic;
signal u_tx_busy        : std_logic;
signal u_rx_data        : std_logic_vector(7 downto 0);

signal l_leds           : std_logic;
signal l_rd_uart        : std_logic;
signal l_rx_int_enabled : std_logic;
signal l_we_uart        : std_logic;

begin
  urt: uart
  generic map(clk_freq  => std_logic_vector(conv_unsigned(25000000, 32)),
              baud_rate => std_logic_vector(conv_unsigned(  115200, 28)))
  port map( i_clk   => i_clk,
            i_reset => i_reset,
            i_rd    => l_rd_uart,
            i_we    => L_WE_UART,
            i_rx    => i_rx,

            q_rx_data => u_rx_data,
            q_rx_ready => u_rx_ready);
  iord:process( i_adr_io, i_switch, u_rx_data, u_rx_ready)
  begin
    case i_adr_io is
      when x"2a" => q_dout <= -- ucsrb:
                        '1' -- rx enabled
                      & '0' -- 8 bits/char
                      & '0'; -- rx bit 8
