---------------------------------------------------------------------------------------------------
--
-- Title       : Dec7Seg
-- Design      : BCD7seg
-- Author      : Esau
-- Company     : WORKGROUP
--
---------------------------------------------------------------------------------------------------
--
-- File        : Dec7Seg.vhd
-- Generated   : Mon Dec  1 20:06:40 2014
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
--{entity {Dec7Seg} architecture {Dec7Seg}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;



entity Dec7Seg is
	 port(
	 	 BCD : in STD_LOGIC_VECTOR(3 downto 0);
	 	 Display : out STD_LOGIC_VECTOR(3 downto 0);
		 Sal : out STD_LOGIC_VECTOR(7 downto 0)
	     );
end Dec7Seg;

--}} End of automatically maintained section

architecture Dec7Seg of Dec7Seg is	
begin

	-- enter your statements here --
	
	process(BCD)	 
	begin
		Display <= "0111";
			case
				BCD is
					when "0000" => sal <="10000001";
					when "0001" => sal <="11001111";
					when "0010" => sal <="10010010";
					when "0011" => sal <="10000110"; 
					when "0100" => sal <="11001100";
					when "0101" => sal <="10100100";
					when "0110" => sal <="10100000";
					when "0111" => sal <="10001111";
					when "1000" => sal <="10000000";	 
					when others => sal <="10001100";
			end case;
		end process;
		
end Dec7Seg;
