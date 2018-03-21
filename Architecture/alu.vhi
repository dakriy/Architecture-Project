
-- VHDL Instantiation Created from source file alu.vhd -- 17:00:22 03/20/2018
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT alu
	PORT(
		i_alu_op : IN std_logic_vector(3 downto 0);
		i_bit : IN std_logic_vector(3 downto 0);
		i_d : IN std_logic_vector(15 downto 0);
		i_d0 : IN std_logic;
		i_din : IN std_logic_vector(7 downto 0);
		i_flags : IN std_logic_vector(7 downto 0);
		i_imm : IN std_logic_vector(11 downto 0);
		i_pc : IN std_logic_vector(15 downto 0);
		i_r : IN std_logic_vector(15 downto 0);
		i_r0 : IN std_logic;
		i_rsel : IN std_logic_vector(1 downto 0);          
		q_flags : OUT std_logic_vector(9 downto 0);
		q_dout : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	Inst_alu: alu PORT MAP(
		i_alu_op => ,
		i_bit => ,
		i_d => ,
		i_d0 => ,
		i_din => ,
		i_flags => ,
		i_imm => ,
		i_pc => ,
		i_r => ,
		i_r0 => ,
		i_rsel => ,
		q_flags => ,
		q_dout => 
	);


