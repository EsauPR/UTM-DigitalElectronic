---------------------------------------------------------------------------------------------------
--
-- Title       : div_frec
-- Design      : Cronometro
-- Author      : Esau
-- Company     : WORKGROUP
--
---------------------------------------------------------------------------------------------------
--
-- File        : div_frec.vhd
-- Generated   : Thu Feb  5 13:26:12 2015
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
--{entity {div_frec} architecture {div_frec}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity div_frec is
	 port(
		 clk50 : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 clk : out STD_LOGIC
	     );
end div_frec;

--}} End of automatically maintained section

architecture div_frec of div_frec is
signal cnt: STD_LOGIC_VECTOR( 20 downto 0 );
begin
	
	genPulso: process (clk50, rst)
	begin
		if rst = '1' then
			cnt <= (others => '0');
		elsif rising_edge( clk50 ) then
			if cnt = "11110100001001000000" then
				clk <= '1';
				cnt <= (others => '0');
			else
				clk <= '0';
				cnt <= cnt + 1;
			end if;
		end if;
	end process;

end div_frec;
