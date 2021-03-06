-------------------------------------------------------------------------------
--
-- Module Name:     opc_fetch
-- Project Name:    Booth's Radix-4 Processor
-- Target Device:   Spartan3E xc3s1200e
-- Description:     the opcode fetch stage of a CPU.
--
-- We credit Dr. Juergen Sauermann for his initial design which we have modified to fit our needs
-- link: https://github.com/freecores/cpu_lecture/tree/master/html
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity opc_fetch is
  port( i_clk : in std_logic;
        i_reset : in std_logic;
        i_load_pc : in std_logic;
        i_new_pc : in std_logic_vector(15 downto 0);
        i_pm_adr : in std_logic_vector(11 downto 0);

        q_opc : out std_logic_vector(15 downto 0);
        q_pc : out std_logic_vector(15 downto 0);
        q_pm_dout : out std_logic_vector(7 downto 0);
        q_t0 : out std_logic);
end opc_fetch;
architecture Behavioral of opc_fetch is
component program_memory
  port( i_clk     : in std_logic;

          i_wait    : in std_logic;
          i_pc      : in std_logic_vector( 15 downto 0 ); --16 bit register
          i_pm_adr : in std_logic_vector( 11 downto 0 ); --256 register space

          q_opc     : out std_logic_vector( 15 downto 0 ); --16bit opcode do be decoded
          q_pc      : out std_logic_vector( 15 downto 0 ); --16bit register
          q_pm_dout : out std_logic_vector(  7 downto 0 )); --256 register space
end component;
signal p_opc : std_logic_vector(15 downto 0);
signal p_pc : std_logic_vector(15 downto 0);

signal l_invalidate : std_logic;
signal l_long_op : std_logic;
signal l_next_pc : std_logic_vector(15 downto 0);
signal l_pc : std_logic_vector(15 downto 0);
signal l_t0 : std_logic;
signal l_wait : std_logic;
signal l_jmp_c : std_logic;
signal l_jmp_uc : std_logic;

begin
  pmem : program_memory
  port map( i_clk => i_clk,
          i_wait => l_wait,
          i_pc => l_next_pc,
          i_pm_adr => i_pm_adr,
          q_opc => p_opc,
          q_pc => p_pc,
          q_pm_dout => q_pm_dout);
  lpc: process( i_clk )
  begin
	 if ( rising_edge( i_clk ) ) then
		l_pc  <= l_next_pc;
		l_t0  <= not l_wait;
	 end if;
  end process;

  l_next_pc <= x"0000"  when (i_reset = '1') --reset pc at power on and RST
  else         i_new_pc + x"0001" when (l_jmp_c = '1') --load new pc value on conditional jump
  else         i_new_pc when (l_jmp_uc = '1') --load new pc value on unconditional jump
  else         l_pc + x"0001"; --increment pc

  --l_invalidate  <= i_reset or i_skip; --interupt (nop) if reset or skip are set

  --q_opc <= x"11111111" when (l_invalidate = '1') --
  --else     p_opc       when (i_intvec(5)  = '0')
  --else     (x"111111" & "11" & i_intvec); --interupt opcode
  
  q_pc <= p_pc;
  q_t0 <= l_t0;
  
end Behavioral;
