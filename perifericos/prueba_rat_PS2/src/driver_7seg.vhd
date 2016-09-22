---------------------------------------------------------------------------------------------------
--
-- Title       : Driver_7seg
-- Design      : Driver_7seg
-- Author      : Labcd
-- Company     : UTM
--
---------------------------------------------------------------------------------------------------
--
-- File        : Driver_7seg.vhd
-- Generated   : Thu Dec  2 19:08:48 2010
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
--{entity {Driver_7seg} architecture {Driver}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.STD_LOGIC_UNSIGNED.all;  



entity Driver_7seg is
	 port(
		 clock : in STD_LOGIC;
		 Dato1,Dato2,Dato3,Dato4 : in STD_LOGIC_VECTOR(6 downto 0);
		 DATA :	out STD_LOGIC_VECTOR(6 downto 0);
		 habs : out STD_LOGIC_VECTOR(3 downto 0)
	     );
end Driver_7seg;

--}} End of automatically maintained section

architecture Driver of Driver_7seg is
signal control : STD_LOGIC_VECTOR (1 downto 0);
begin
	process(clock)
	begin
		if clock = '1' and clock'event then
			control <= control + 1;
		end if;
	end process;
	
	with control select	
	DATA <= 	Dato1 when "00", 
			Dato2 when "01", 
			Dato3 when "10", 
			Dato4 when others; 
	process(control)
	begin
		case control is
			when "00" =>habs <= "1110";
			when "01" =>habs <= "1101";
			when "10" =>habs <= "1011";
			when others =>habs <= "0111";
		end case;
	end process;
	
end Driver;
			