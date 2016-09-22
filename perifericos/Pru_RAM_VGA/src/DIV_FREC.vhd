library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity DIV_FREC is
	port(	
	     CLK_50: in STD_LOGIC;
		 RST: in STD_LOGIC;	
		 CLK_25: out STD_LOGIC
		 );	  
end DIV_FREC;
----------------------------	

----------------------------

architecture DIV_FREC of DIV_FREC is 	
Signal CLK_DIV: STD_LOGIC;

begin
DIVISOR: process(RST, CLK_50)
 begin					  
   if (RST = '1') then
	   CLK_DIV <= '0';
	  
   elsif (CLK_50='1' and CLK_50'event) then		
	   CLK_DIV <= not CLK_DIV;
   end if;	   
end process DIVISOR;			 

CLK_25 <= CLK_DIV;

end DIV_FREC;
----------------------------