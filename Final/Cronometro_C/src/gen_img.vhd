
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity gen_img is
	 port(
		 V_Area : in STD_LOGIC;
		 color : in STD_LOGIC_VECTOR(7 downto 0);
		 Pix_hor : in STD_LOGIC_VECTOR(9 downto 0);
		 Pix_Ver : in STD_LOGIC_VECTOR(8 downto 0);
		 RGB_sal : out STD_LOGIC_VECTOR(7 downto 0);
		 data1 : in STD_LOGIC_VECTOR( 3 downto 0 );
		 data2 : in STD_LOGIC_VECTOR( 3 downto 0 );
		 data3 : in STD_LOGIC_VECTOR( 3 downto 0 );
		 data4 : in STD_LOGIC_VECTOR( 3 downto 0 );
		 data5 : in STD_LOGIC_VECTOR( 3 downto 0 );
		 data6 : in STD_LOGIC_VECTOR( 3 downto 0 )
	     );
end gen_img;


architecture gen_img of gen_img is
signal XHora1: STD_LOGIC_VECTOR( 9 downto 0 ); 
signal YHora1: STD_LOGIC_VECTOR( 9 downto 0 );
signal POSX: STD_LOGIC_VECTOR( 9 downto 0 );
signal POSX2: STD_LOGIC_VECTOR( 9 downto 0 );
signal data : STD_LOGIC_VECTOR( 3 downto 0 );
begin
	YHora1 <= "0010010110"; --150
	POSX <= "0001110011"; --115
	POSX2 <= "0011101011"; --235
	
	hd1 : process(Pix_hor, Pix_Ver, V_Area)
	begin
	
		if ( Pix_hor > POSX and Pix_hor < POSX + 55 ) then
			XHora1 <= POSX; --115
			data <= data6;
		elsif ( Pix_hor > POSX + 55 and Pix_hor < POSX + 110 ) then
			XHora1 <= POSX + 55;
			data <= data5;
		elsif ( Pix_hor > POSX + 155 and Pix_hor < POSX + 210 ) then
			XHora1 <= POSX + 155;
			data <= data4;
		elsif ( Pix_hor > POSX + 210 and Pix_hor < POSX + 265 ) then
			XHora1 <= POSX + 210;
			data <= data3;
		elsif ( Pix_hor > POSX + 310 and Pix_hor < POSX + 365 ) then
			XHora1 <= POSX + 310;
			data <= data2;
		elsif ( Pix_hor > POSX + 365 and Pix_hor < POSX + 420 ) then
			XHora1 <= POSX + 365;
			data <= data1;
		else
				XHora1 <= "0001110011"; --115
		end if;
	
		if V_area = '1' then
			-- a
			if( Pix_hor > XHora1 + 35 and Pix_hor < XHora1 + 40 and Pix_ver > YHora1 + 5 and Pix_ver < YHora1 + 35 ) then
				if ( data = 9 or data = 8 or data = 7 or data = 4 or data = 3 or data = 2 or data = 1 or data = 0 ) then
					RGB_sal <= color;
				else
					RGB_sal <= NOT color;
				end if;
			-- b
			elsif( Pix_hor > XHora1 + 35 and Pix_hor < XHora1 + 40 and Pix_ver > YHora1 + 40 and Pix_ver < YHora1 + 70 ) then
				if ( data = 9 or data = 8 or data = 7 or data = 6 or data = 5 or data = 4 or data = 3 or data = 1 or data = 0 ) then
					RGB_sal <= color;
				else
					RGB_sal <= NOT color;
				end if;
			-- c
			elsif( Pix_hor > XHora1 + 5 and Pix_hor < XHora1 + 35 and Pix_ver > YHora1 + 70 and Pix_ver < YHora1 + 75 ) then
				if ( data = 8 or data = 6 or data = 5 or data = 3 or data = 2 or data = 0) then
					RGB_sal <= color;
				else
					RGB_sal <= NOT color;
				end if;
			-- d
			elsif( Pix_hor > XHora1 and Pix_hor < XHora1 + 5 and Pix_ver > YHora1 + 40 and Pix_ver < YHora1 + 70 ) then
				if ( data = 8 or data = 6 or data = 2 or data = 0 ) then
					RGB_sal <= color;
				else
					RGB_sal <= NOT color;
				end if;
			-- e
			elsif( Pix_hor > XHora1 and Pix_hor < XHora1 + 5 and Pix_ver > YHora1 + 5 and Pix_ver < YHora1 + 35 ) then
				if ( data = 9 or data = 8 or data = 6 or data = 5 or data = 4 or data = 0 ) then
					RGB_sal <= color;
				else
					RGB_sal <= NOT color;
				end if;
			-- f
			elsif( Pix_hor > XHora1 + 5 and Pix_hor < XHora1 + 35 and Pix_ver > YHora1 and Pix_ver < YHora1 + 5 ) then
				if ( data = 9 or data = 8 or data = 7 or data = 6 or data = 5 or data = 3 or data = 2 or data = 0 ) then
					RGB_sal <= color;
				else
					RGB_sal <= NOT color;
				end if;
			-- g
			elsif( Pix_hor > XHora1 + 5 and Pix_hor < XHora1 + 35 and Pix_ver > YHora1 + 35 and Pix_ver < YHora1 + 40 ) then
				if ( data = 9 or data = 8 or data = 6 or data = 5 or data = 4 or data = 3 or data = 2 ) then
					RGB_sal <= color;
				else
					RGB_sal <= NOT color;
				end if;
			-- PUNTOS
			elsif ( Pix_hor > POSX2 and Pix_hor < POSX2 + 10 and Pix_ver > YHora1 + 20 and Pix_ver < YHora1 + 30 ) then
				RGB_sal <= color;
			elsif ( Pix_hor > POSX2 and Pix_hor < POSX2 + 10 and Pix_ver > YHora1 + 45 and Pix_ver < YHora1 + 55 ) then
				RGB_sal <= color;
			elsif ( Pix_hor > POSX2 + 155 and Pix_hor < POSX2 + 165 and Pix_ver > YHora1 + 20 and Pix_ver < YHora1 + 30 ) then
				RGB_sal <= color;
			elsif ( Pix_hor > POSX2 + 155 and Pix_hor < POSX2 + 165 and Pix_ver > YHora1 + 45 and Pix_ver < YHora1 + 55 ) then
				RGB_sal <= color;
			else
				RGB_sal <= NOT color;
			end if;
		end if;
	end process;
	
end gen_img;
