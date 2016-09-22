library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.STD_LOGIC_ARITH.all;  

------------------------

use IEEE.STD_LOGIC_UNSIGNED.all;

Entity vga is
	port(
	    CLK: in STD_LOGIC;
		RST: in STD_LOGIC;  		  
		
		PIXEL_RGB: in STD_LOGIC_VECTOR (7 downto 0);
		
	
		HSYNC: out STD_LOGIC; 
		VSYNC: out STD_LOGIC;  
		RGB: out STD_LOGIC_VECTOR(7 downto 0);
		
		PIXEL_H: out STD_LOGIC_VECTOR(9 downto 0);
		PIXEL_V: out STD_LOGIC_VECTOR(8 downto 0);
		V_AREA : out STD_LOGIC
		);
end Entity;

Architecture vga of	vga is
----------------------------- 
Constant HORIZONTAL: STD_LOGIC_VECTOR (9 downto 0) := "1100100000";	 --800
Constant VERTICAL: STD_LOGIC_VECTOR (9 downto 0) := "1000001001" ;	 --521

----------------------------- 	 	 
Signal HC: STD_LOGIC_VECTOR (9 downto 0);
Signal VC: STD_LOGIC_VECTOR (9 downto 0);	   
Signal BLANK: STD_LOGIC;		   

Signal PIXHOR: STD_LOGIC_VECTOR(9 downto 0);   --Contador de PIXELES HORIZONTALES
Signal PIXVER: STD_LOGIC_VECTOR(8 downto 0);   --Contador de PIXELES VERTICALES
-----------------------------
begin
----------------------------
-- Contador para las señales de sincronia

CONT: process(RST, CLK)
 begin	  
   if (RST = '1') then
	  HC <= "0000000000";
	  VC <= "0000000000";
  elsif (CLK = '1' and CLK'event) then		 

	    if (HC = HORIZONTAL) then
		   HC <= "0000000000"; 
		  
		   if(VC = VERTICAL) then
			 VC <= "0000000000";
		   else
			 VC <= VC + 1;
		   end if;
		  
	   else
		   HC <= HC + 1; 
	   end if;		   
	   	   		   
  end if;	  
end process CONT;			

----------------------------
HSYNC <= '0' when (HC > 0 and HC <= 96 ) else	  -- 0--96 
	     '1'; 
VSYNC <= '0' when (VC > 0 and VC <= 2) else	-- 0--2 
	     '1';		 
BLANK <= '1' when (HC >= 144 and HC < 784 and VC >= 39 and VC < 519) else             
		 '0';
----------------------------	   


RGB<= PIXEL_RGB when (BLANK = '1')  else "00000000"; 		 
PIXEL_H<=PIXHOR;
PIXEL_V<=PIXVER;
	
---Contador de pixeles HORIZONTALES y VERTICALES ---
CONTPIXELES:process(RST, CLK)
begin					
	if (RST = '1') then   
		PIXHOR <= "0000000000";	
	    PIXVER <= (others=>'0');
		
	elsif (CLK = '1' and CLK'event and BLANK = '1')then		
		PIXHOR <= PIXHOR + 1;	  
		
		if (PIXHOR = 639) then
			PIXHOR <= (others=>'0');
			
			PIXVER <= PIXVER + 1;
			if (PIXVER = 479) then
				PIXVER <= (others=>'0');
			end if;
		end if;
	end if;
				
end process CONTPIXELES;

V_AREA <= BLANK;

end vga;
