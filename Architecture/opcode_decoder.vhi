
-- VHDL Instantiation Created from source file opcode_decoder.vhd -- 17:07:41 03/20/2018
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT opcode_decoder
	PORT(
		i_clk : IN std_logic;
		i_opc : IN std_logic_vector(15 downto 0);
		i_pc : IN std_logic_vector(15 downto 0);          
		q_alu_op : OUT std_logic_vector(1 downto 0);
		q_ssss : OUT std_logic_vector(3 downto 0);
		q_tttt : OUT std_logic_vector(3 downto 0);
		q_imm : OUT std_logic_vector(7 downto 0);
		q_jadr : OUT std_logic_vector(11 downto 0);
		q_opc : OUT std_logic_vector(15 downto 0);
		q_pc : OUT std_logic_vector(15 downto 0);
		q_pc_op : OUT std_logic_vector(15 downto 0);
		q_rsel : OUT std_logic_vector(7 downto 0);
		q_we_d : OUT std_logic_vector(1 downto 0);
		q_we_m : OUT std_logic_vector(1 downto 0)
		);
	END COMPONENT;

	Inst_opcode_decoder: opcode_decoder PORT MAP(
		i_clk => ,
		i_opc => ,
		i_pc => ,
		q_alu_op => ,
		q_ssss => ,
		q_tttt => ,
		q_imm => ,
		q_jadr => ,
		q_opc => ,
		q_pc => ,
		q_pc_op => ,
		q_rsel => ,
		q_we_d => ,
		q_we_m => 
	);


