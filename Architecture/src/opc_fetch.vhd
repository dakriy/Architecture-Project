library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

signal l_pc : std_logic_vector( 15 downto 0 );

lpc: process( i_clk )
begin
    if ( rising_edge( i_clk ) ) then
        l_pc  <= l_next_pc;
        l_to  <= not l_wait;
    end if;
end process;

l_next_pc <= x"0000"  when (i_clr     = '1') --reset pc at power on and RST
else         l_pc     when (l_wait    = '1') --stall pc on multi-cycle instructions
else         l_new_pc when (l_load_pc = '1') --load new pc value on jump
--else  l_pc + x"0002"  when (l_long_op = '1') --increment pc by 2 on
else         l_pc + x"0001"; --increment pc

l_invalidate  <= i_clr or i_skip; --interupt (nop) if clr or skip are set

q_opc <= x"11111111" when (l_invalidate = '1') --
else     p_opc       when (i_intvec(5)  = '0')
else     (x"111111" & "11" & i_intvec); --interupt opcode
