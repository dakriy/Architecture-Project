
-- VHDL Instantiation Created from source file register_file.vhd -- 17:00:50 03/20/2018
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT register_file
	PORT(
		i_clk : IN std_logic;
		i_amod : IN std_logic_vector(5 downto 0);
		i_cond : IN std_logic_vector(3 downto 0);
		i_ssss : IN std_logic_vector(3 downto 0);
		i_din : IN std_logic_vector(15 downto 0);
		i_flags : IN std_logic_vector(7 downto 0);
		i_imm : IN std_logic_vector(11 downto 0);
		i_tttt : IN std_logic_vector(3 downto 0);
		i_we_01 : IN std_logic;
		i_we_d : IN std_logic_vector(1 downto 0);
		i_we_f : IN std_logic;
		i_we_m : IN std_logic;          
		q_adr : OUT std_logic_vector(15 downto 0);
		q_cc : OUT std_logic;
		q_d : OUT std_logic_vector(15 downto 0);
		q_flags : OUT std_logic_vector(7 downto 0);
		q_r : OUT std_logic_vector(15 downto 0);
		q_s : OUT std_logic_vector(7 downto 0);
		q_z : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	Inst_register_file: register_file PORT MAP(
		i_clk => ,
		i_amod => ,
		i_cond => ,
		i_ssss => ,
		i_din => ,
		i_flags => ,
		i_imm => ,
		i_tttt => ,
		i_we_01 => ,
		i_we_d => ,
		i_we_f => ,
		i_we_m => ,
		q_adr => ,
		q_cc => ,
		q_d => ,
		q_flags => ,
		q_r => ,
		q_s => ,
		q_z => 
	);


