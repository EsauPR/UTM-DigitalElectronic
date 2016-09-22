---------------------------------------------------------------------------------------------------
--
-- Title       : sel_Color
-- Design      : Pru_RAM_VGA
-- Author      : FSE
-- Company     : UTM
--
---------------------------------------------------------------------------------------------------
--
-- File        : sel_Color.vhd
-- Generated   : Tue Jan 20 13:29:25 2015
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--
---------------------------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {sel_Color} architecture {sel_Color}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;



entity sel_Color is
	 port(
		 sel : in STD_LOGIC_VECTOR(3 downto 0);
		 Color : out STD_LOGIC_VECTOR(7 downto 0)
	     );
end sel_Color;

--}} End of automatically maintained section

architecture sel_Color of sel_Color is
begin

	with sel select
		Color <= 	"00000000" when  "0000",   -- Negro
					"00000111" when  "0001",   -- Rojo
					"00111000" when  "0010",   -- Verde
					"11000000" when  "0011",   -- Azul
					"11111000" when  "0100",   -- Cyan
					"11011110" when  "0101",   -- Rosado
					"10100100" when  "0110",   -- Gris
					"00111111" when  "0111",   -- Amarillo
					"00010011" when  "1000",   -- Café
					"01000001" when  "1001",   -- Morado
					"10000011" when  "1010",   -- Violeta
					"00100111" when  "1011",   -- Naranja
					"00111110" when  "1100",   -- Verde Limón
					"00001001" when  "1101",   -- Verde militar
					"00000001" when  "1110",   -- Marrón
					"11111111" when  others;   -- Blanco
	

end sel_Color;
