---------------------------------------------------------------------------------------------------
--
-- Title       : DF_VGA
-- Design      : Cronometro
-- Author      : Esau
-- Company     : WORKGROUP
--
---------------------------------------------------------------------------------------------------
--
-- File        : DF_VGA.vhd
-- Generated   : Fri Feb  6 01:12:30 2015
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
--{entity {DF_VGA} architecture {DF_VGA}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity DF_VGA is
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC;
		 CLK_25MHZ : out STD_LOGIC
	     );
end DF_VGA;

--}} End of automatically maintained section

architecture DF_VGA of DF_VGA is
Signal CLK_DIV: STD_LOGIC;
begin
	 DIVISOR: process(RST, CLK)
	 begin					  
	 	if (RST = '1') then
		   	CLK_DIV <= '0';
		  
	   	elsif (CLK='1' and CLK'event) then		
		   	CLK_DIV <= not CLK_DIV;
	   	end if;	   
	end process DIVISOR;			 
	
	CLK_25MHZ <= CLK_DIV;

end DF_VGA;
