---------------------------------------------------------------------------------------------------
--
-- Title       : control_Z
-- Design      : com_PC
-- Author      : FSE
-- Company     : UTT
--
---------------------------------------------------------------------------------------------------
--
-- File        : control_Z.vhd
-- Generated   : Wed May  7 09:56:33 2014
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
--{entity {control_Z} architecture {control_Z}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;



entity control_Z is
	 port(
		 g : in STD_LOGIC;
		 DOUT : in STD_LOGIC_VECTOR(7 downto 0);
		 DIN : out STD_LOGIC_VECTOR(7 downto 0);
		 PBID : inout STD_LOGIC_VECTOR(7 downto 0)
	     );
end control_Z;

--}} End of automatically maintained section

architecture control_Z of control_Z is
begin

	PBID <= DOUT when g = '1' else "ZZZZZZZZ";
	DIN <= PBID;

end control_Z;
