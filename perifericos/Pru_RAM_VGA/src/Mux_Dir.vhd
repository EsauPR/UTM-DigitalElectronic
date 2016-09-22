---------------------------------------------------------------------------------------------------
--
-- Title       : Mux_Dir
-- Design      : Show_Imag_50x50
-- Author      : FSE
-- Company     : UTT
--
---------------------------------------------------------------------------------------------------
--
-- File        : Mux_Dir.vhd
-- Generated   : Sat May 10 12:02:37 2014
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
--{entity {Mux_Dir} architecture {Mux_Dir}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_arith.all;


entity Mux_Dir is
	 port(
		 Sel : in STD_LOGIC;
		 Dir_W_Low  : in STD_LOGIC_VECTOR(14 downto 0);
		 Dir_W_High : in STD_LOGIC_VECTOR(3 downto 0);
		 Dir_R : in STD_LOGIC_VECTOR(18 downto 0);
		 Dir_M : out STD_LOGIC_VECTOR(22 downto 0)
	     );
end Mux_Dir;

--}} End of automatically maintained section

architecture Mux_Dir of Mux_Dir is
begin
	
	process(Sel, Dir_W_Low, Dir_W_High, Dir_R)
	variable  temp: integer;
	begin
		if  Sel = '1'  then
			Dir_M <= "0000"&Dir_R;
		else
			temp := 19200*conv_Integer(Dir_W_High);
			Dir_M <= conv_std_logic_vector(temp, 23) + ("00000000"&Dir_W_Low);
		end if;
	end process;
	
end Mux_Dir;
