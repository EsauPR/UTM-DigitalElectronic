---------------------------------------------------------------------------------------------------
--
-- Title       : df_c
-- Design      : Cronometro
-- Author      : Esau
-- Company     : WORKGROUP
--
---------------------------------------------------------------------------------------------------
--
-- File        : df_c.vhd
-- Generated   : Thu Feb  5 16:26:28 2015
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
--{entity {df_c} architecture {df_c}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity df_c is
	 port(
		 clk50 : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 clk : out STD_LOGIC
	     );
end df_c;

--}} End of automatically maintained section

architecture df_c of df_c is
signal cnt: STD_LOGIC_VECTOR( 16 downto 0 );
begin

	genPulso: process (clk50, rst)
	begin
		if rst = '1' then
			cnt <= (others => '0');
		elsif rising_edge( clk50 ) then
			if cnt = "1100001101010000" then
				clk <= '1';
				cnt <= (others => '0');
			else
				clk <= '0';
				cnt <= cnt + 1;
			end if;
		end if;
	end process;

end df_c;
