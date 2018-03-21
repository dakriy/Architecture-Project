-------------------------------------------------------------------------------
-- 
-- copyright (c) 2009, 2010 dr. juergen sauermann
-- 
--  this code is free software: you can redistribute it and/or modify
--  it under the terms of the gnu general public license as published by
--  the free software foundation, either version 3 of the license, or
--  (at your option) any later version.
--
--  this code is distributed in the hope that it will be useful,
--  but without any warranty; without even the implied warranty of
--  merchantability or fitness for a particular purpose.  see the
--  gnu general public license for more details.
--
--  you should have received a copy of the gnu general public license
--  along with this code (see the file named copying).
--  if not, see http://www.gnu.org/licenses/.
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- module name:    opc_fetch - behavioral 
-- create date:    13:00:44 10/30/2009 
-- description:    the opcode fetch stage of a cpu.
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity opc_fetch is
    port (  i_clk       : in  std_logic;

            i_reset       : in  std_logic;
            i_intvec    : in  std_logic_vector( 5 downto 0);
            i_load_pc   : in  std_logic;
            i_new_pc    : in  std_logic_vector(15 downto 0);
            i_pm_adr    : in  std_logic_vector(11 downto 0);
            i_skip      : in  std_logic;

            q_opc       : out std_logic_vector(15 downto 0);
            q_pc        : out std_logic_vector(15 downto 0);
            q_pm_dout   : out std_logic_vector( 7 downto 0);
            q_t0        : out std_logic);
end opc_fetch;

architecture behavioral of opc_fetch is

component prog_mem
    port (  i_clk       : in  std_logic;

            i_wait      : in  std_logic;
            i_pc        : in  std_logic_vector (15 downto 0);
            i_pm_adr    : in  std_logic_vector (11 downto 0);

            q_opc       : out std_logic_vector (31 downto 0);
            q_pc        : out std_logic_vector (15 downto 0);
            q_pm_dout   : out std_logic_vector ( 7 downto 0));
end component;

signal p_opc            : std_logic_vector(31 downto 0);
signal p_pc             : std_logic_vector(15 downto 0);

signal l_invalidate     : std_logic;
signal l_long_op        : std_logic;
signal l_next_pc        : std_logic_vector(15 downto 0);
signal l_opc_1_0123     : std_logic;
signal l_opc_8a_014589cd: std_logic;
signal l_opc_9_01       : std_logic;
signal l_opc_9_5_01_8   : std_logic;
signal l_opc_9_5_cd_8   : std_logic;
signal l_opc_9_9b       : std_logic;
signal l_opc_f_cdef     : std_logic;
signal l_pc             : std_logic_vector(15 downto 0);
signal l_t0             : std_logic;
signal l_wait           : std_logic;

begin

    pmem : prog_mem
    port map(   i_clk       => i_clk,

                i_wait      => l_wait,
                i_pc        => l_next_pc,
                i_pm_adr    => i_pm_adr,

                q_opc       => p_opc,
                q_pc        => p_pc,
                q_pm_dout   => q_pm_dout);

  lpc: process( i_clk )
  begin
	 if ( rising_edge( i_clk ) ) then
		l_pc  <= l_next_pc;
		l_t0  <= not l_wait;
	 end if;
  end process;

  l_next_pc <= x"0000"  when (i_reset = '1') --reset pc at power on and RST
  else         i_new_pc + x"0001" when (i_load_pc = '1') --load new pc value on conditional jump
  --else         i_new_pc when (l_jmp_uc = '1') --load new pc value on unconditional jump
  else         l_pc + x"0001"; --increment pc

  --l_invalidate  <= i_reset or i_skip; --interupt (nop) if reset or skip are set

  --q_opc <= x"11111111" when (l_invalidate = '1') --
  --else     p_opc       when (i_intvec(5)  = '0')
  --else     (x"111111" & "11" & i_intvec); --interupt opcode
  
  q_pc <= p_pc;
  q_t0 <= l_t0;


end behavioral;

