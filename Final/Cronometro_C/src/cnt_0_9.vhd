---------------------------------------------------------------------------------------------------
--
-- Title       : cnt_0_9
-- Design      : Cronometro
-- Author      : Esau
-- Company     : WORKGROUP
--
---------------------------------------------------------------------------------------------------
--
-- File        : cnt_0_9.vhd
-- Generated   : Thu Feb  5 14:00:51 2015
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
--{entity {cnt_0_9} architecture {cnt_0_9}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity cnt_0_9 is
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 cc : in STD_LOGIC;
		 carry : out STD_LOGIC;
		 data : out STD_LOGIC_VECTOR(3 downto 0)
	     );
end cnt_0_9;

--}} End of automatically maintained section

architecture cnt_0_9 of cnt_0_9 is
signal cnt: STD_LOGIC_VECTOR(3 downto 0);
begin

	contador: process (clk, rst)
	begin
		if rst = '1' then
			cnt <= ( others =>'0' );
			carry <= '0';
		elsif rising_edge(clk) then
			carry <= '0';
			if cc = '1' then
				if cnt = "1001" then
					cnt <= ( others => '0' );
					carry <= '1';
				else
					cnt <= cnt + 1;
				end if;
			end if;
		end if;	
	end process;
	
	data <= cnt;

end cnt_0_9;
