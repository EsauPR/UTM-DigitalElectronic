library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity DIV_FREC is
	port(	
	     CLK_EXT: in STD_LOGIC;
		 RST: in STD_LOGIC;
		 CLK : out STD_LOGIC;
		 CLK_25MHZ: out STD_LOGIC		 
		 );	  
end DIV_FREC;
----------------------------	

----------------------------

architecture DIV_FREC of DIV_FREC is 	
Signal CLK_DIV: STD_LOGIC_VECTOR(9 DOWNTO 0);

begin
DIVISOR: process(RST, CLK_EXT)
 begin					  
   if (RST = '1') then
	   CLK_DIV <= (others => '0');
	  
   elsif (CLK_EXT='1' and CLK_EXT'event) then		
	   CLK_DIV <= CLK_DIV + 1;
   end if;	   
end process DIVISOR;			 

CLK_25MHZ <= CLK_DIV(0);
CLK <= CLK_DIV(9);

end DIV_FREC;
----------------------------