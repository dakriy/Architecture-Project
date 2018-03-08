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
