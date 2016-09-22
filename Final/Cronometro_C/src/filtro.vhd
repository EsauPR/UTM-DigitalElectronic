---------------------------------------------------------------------------------------------------
--
-- Title       : filtro
-- Design      : Cronometro
-- Author      : Esau
-- Company     : WORKGROUP
--
---------------------------------------------------------------------------------------------------
--
-- File        : filtro.vhd
-- Generated   : Thu Feb  5 13:53:14 2015
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
--{entity {filtro} architecture {filtro}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;



entity filtro is
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 start : in STD_LOGIC;
		 pause : in STD_LOGIC;
		 cc : out STD_LOGIC
	     );
end filtro;

--}} End of automatically maintained section

architecture filtro of filtro is
signal cc_ant: STD_LOGIC;
begin
	
	process(clk, rst)
	begin 
		if rst = '1' then
			cc_ant <= '0';
		elsif rising_edge(clk) then 
			if start = '1' then
				cc_ant <= '1';
			end if;
			if pause = '1' then
				cc_ant <= '0';
			end if;
		end if;
	end process;
	
	cc <= cc_ant;

end filtro;
