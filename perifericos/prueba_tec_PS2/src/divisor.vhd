
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity Divisor is
	 port(
		 clk_ext : in STD_LOGIC;
		 clk : out STD_LOGIC
	     );
end Divisor;


architecture Divisor of Divisor is	 
signal contador: STD_LOGIC_VECTOR(7 downto 0) := "00000000";
begin											 
	Process(clk_ext)
	begin
		if clk_ext = '1' and clk_ext'event then
			contador<=contador + 1;
		end if;
	end process;
	
	clk <= contador(7);
	
end Divisor;
