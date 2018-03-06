entity program_mememory is
    port( i_clk     : in std_logic;

          i_wait    : in std_logic;
          i_pc      : in std_logic_vector( 15 downto 0 ); --16 bit register
          i_pm_addr : in std_logic_vector(  7 downto 0 ); --256 register space

          q_opc     : in std_logic_vector( 15 downto 0 ); --16bit opcode
          q_pc      : in std_logic_vector( 15 downto 0 ); --16bit register
          q_pm_dout : in std_logic_vector(  7 downto 0 )  --256 register space
          );
end program_mememory;
