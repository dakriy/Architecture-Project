-------------------------------------------------------------------------------
--
-- Copyright (C) 2009, 2010 Dr. Juergen Sauermann
--
-- This code is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this code (see the file named COPYING).
-- If not, see http://www.gnu.org/licenses/.
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
-- Module Name:   cpu_core - Behavioral
-- Create Date:   13:51:24 11/07/2009
-- Description:   the instruction set implementation of a CPU.
--
-------------------------------------------------------------------------------
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cpu_core is
    port(
          i_clk     : in  std_logic; --global clock
          i_clr     : in  std_logic;
          i_intvec  : in  std_logic_vector(  5 downto 0 ); --interupt vector input
          i_din     : in  std_logic_vector(  7 downto 0 ); --input data (pmem or i/o)

          q_opc     : out std_logic_vector( 15 downto 0 );
          q_pc      : out std_logic_vector( 15 downto 0 );
          q_dout    : out std_logic_vector(  7 downto 0 );
          q_adr_io  : out std_logic_vector(  7 downto 0 );
          q_rd_io   : out std_logic;
          q_we_io   : out std_logic
    );
end cpu_core;

architecture Behavioral of cpu_core is
component opc_fetch
    port(
          i_clk     : in std_logic;

          i_clr     : in std_logic_vector(  5 downto 0 );
          i_intvec  : in std_logic_vector( 15 downto 0 );
          i_new_pc  : in std_logic_vector( 15 downto 0 );
          i_load_pc : in std_logic;
          i_pm_addr : in
          );


l_din     <= f_pm_dout when (d_pms = '1') else i_din(7 downto 0); --mux selects between pmem and i/o
l_intvec  <= i_intvec(5) and r_int_ena;
