
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity gen_img is
	 port(
		 V_Area : in STD_LOGIC;
		 color : in STD_LOGIC_VECTOR(7 downto 0);
		 Pix_hor : in STD_LOGIC_VECTOR(9 downto 0);
		 Pix_Ver : in STD_LOGIC_VECTOR(8 downto 0);
		 RGB_sal : out STD_LOGIC_VECTOR(7 downto 0)
	     );
end gen_img;


architecture gen_img of gen_img is
begin

	process(Pix_hor, Pix_Ver, V_Area)
	begin
		if V_Area = '1' then
			if Pix_hor > 160 and Pix_hor < 480 and Pix_ver > 120 and Pix_ver < 360  then
				RGB_sal <= color;
			else
				RGB_sal <= NOT color;
			end if;		
		end if;
	end process;

end gen_img;
