library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_memory is
  port( I_CLK  : in std_logic;
        I_ADR  : in std_logic_vector(10 downto 0);
        I_DIN  : in std_logic_vector(15 downto 0);
        I_WE   : in std_logic_vector(1 downto 0);
        Q_DOUT : in std_logic_vector(15 downto 0));
end data_memory;

architecture Behavioral of data_mem is

constant zero_256 : bit_vector := X"00000000000000000000000000000000" & X"00000000000000000000000000000000";
constant nine_256 : bit_vector := X"99999999999999999999999999999999" & X"99999999999999999999999999999999";

component RAMB4_S4_S4
  generic(init_00 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_01 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_02 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_03 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_04 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_05 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_06 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_07 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_08 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_09 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_0a : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_0b : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_0c : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_0d : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_0e : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
          init_0f : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000");

  port( addra :in std_logic_vector(9 downto 0);
        addrb :in std_logic_vector(9 downto 0);
        clka :in std_logic;
        clkb :in std_logic;
        dia :in std_logic_vector(3 downto 0);
        dib :in std_logic_vector(3 downto 0);
        ena :in std_logic;
        enb :in std_logic;
        rsta :in std_logic;
        rstb :in std_logic;
        wea :in std_logic;
        web :in std_logic;

        doa :out std_logic_vector(3 downto 0);
        dob :out std_logic_vector(3 downto 0));
end component;

begin
