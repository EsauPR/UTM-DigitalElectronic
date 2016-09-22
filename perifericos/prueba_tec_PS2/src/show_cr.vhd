library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.STD_LOGIC_UNSIGNED.all;  

entity Driver_7seg is
	 port(
		 clock : in STD_LOGIC;
		 Dato1,Dato2 : in STD_LOGIC_VECTOR(6 downto 0);
		 DATA :	out STD_LOGIC_VECTOR(6 downto 0);
		 HABS : out STD_LOGIC_VECTOR(3 downto 0)
	     );
end Driver_7seg;


architecture Driver of Driver_7seg is
signal control : STD_LOGIC := '0';
begin
	process(clock)
	begin
		if clock = '1' and clock'event then
			control <= control XOR '1';
		end if;
	end process;
	
	DATA <= Dato1 when control = '0' else Dato2; 
	
	HABS <= "1110" when control = '0' else "1101"; 	
	
end Driver;