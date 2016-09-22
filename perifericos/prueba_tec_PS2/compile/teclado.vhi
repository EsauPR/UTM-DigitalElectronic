component teclado
	port (
		clk: in STD_LOGIC;
		dato_ser: in STD_LOGIC;
		flanco: in STD_LOGIC;
		rst: in STD_LOGIC;
		CR: out STD_LOGIC_VECTOR (7 downto 0);
		cr_listo: out STD_LOGIC);
end component;


instance_name : teclado
( clk => ,
  CR => ,
  cr_listo => ,
  dato_ser => ,
  flanco => ,
  rst => );
