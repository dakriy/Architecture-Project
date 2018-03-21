----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    18:40:34 03/20/2018
-- Design Name:
-- Module Name:    ramb4_s4_s4 - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with unsigned or Ununsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ramb4_s4_s4 is
	generic( init_00 : bit_vector := x"00000000000000000000000000000000" & x"00000000000000000000000000000000";
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
end ramb4_s4_s4;

architecture Behavioral of ramb4_s4_s4 is
function cv(A : bit) return std_logic is
begin
	if (A = '1') then return '1';
	else return '0';
	end if;
end;

function cv1(A : std_logic) return bit is
begin
	if (A = '1') then return '1';
	else return '0';
	end if;
end;

signal data : bit_vector(4095 downto 0) :=
	init_0f & init_0e & init_0d & init_0c & init_0b & init_0a & init_09 & init_08 &
	init_07 & init_06 & init_05 & init_04 & init_03 & init_02 & init_01 & init_00;

begin
	process(clka, clkb)
	begin
		if (rising_edge(clka)) then
			if (ena = '1') then
				doa(3) <= cv(data(to_integer(unsigned(addra & "11"))));
				doa(2) <= cv(data(to_integer(unsigned(addra & "10"))));
				doa(1) <= cv(data(to_integer(unsigned(addra & "01"))));
				doa(0) <= cv(data(to_integer(unsigned(addra & "00"))));
				if (wea = '1') then
					data(to_integer(unsigned(addra & "11"))) <= cv1(dia(3));
					data(to_integer(unsigned(addra & "10"))) <= cv1(dia(2));
					data(to_integer(unsigned(addra & "01"))) <= cv1(dia(1));
					data(to_integer(unsigned(addra & "00"))) <= cv1(dia(0));
				end if;
			end if;
		end if;
		if (rising_edge(clkb)) then
			if (enb = '1') then
				dob(3) <= cv(data(to_integer(unsigned(addrb & "11"))));
				dob(2) <= cv(data(to_integer(unsigned(addrb & "10"))));
				dob(1) <= cv(data(to_integer(unsigned(addrb & "01"))));
				dob(0) <= cv(data(to_integer(unsigned(addrb & "00"))));
				if (web = '1') then
					data(to_integer(unsigned(addrb & "11"))) <= cv1(dib(3));
					data(to_integer(unsigned(addrb & "10"))) <= cv1(dib(3));
					data(to_integer(unsigned(addrb & "01"))) <= cv1(dib(3));
					data(to_integer(unsigned(addrb & "00"))) <= cv1(dib(3));
				end if;
			end if;
		end if;
	end process;

end Behavioral;
