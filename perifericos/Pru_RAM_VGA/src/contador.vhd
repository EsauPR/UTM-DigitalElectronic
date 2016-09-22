---------------------------------------------------------------------------------------------------
--
-- Title       : contador
-- Design      : Pru_RAM_VGA
-- Author      : FSE
-- Company     : UTM
--
---------------------------------------------------------------------------------------------------
--
-- File        : contador.vhd
-- Generated   : Mon Jan 19 22:25:29 2015
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity contador is
	 port(
		 clk : in STD_LOGIC;
		 hab : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 dir_W : out STD_LOGIC_VECTOR(14 downto 0)
	     );
end contador;

architecture contador of contador is
signal  cnt_int: STD_LOGIC_VECTOR(15 downto 0);
begin

	process(rst, clk)
	begin
		if rst = '1' then
			cnt_int <= (others => '0');
		elsif rising_edge(clk) then
			if hab = '1' then 
				if cnt_int < "1001010111111110" then
					cnt_int <= cnt_int + 1;
				else
					cnt_int <= "0000000000000000";
				end if;
			end if;
		end if;
	end process;

	-- La máquina de Estados invierte 2 ciclos en cada escritura,
	-- El contador se divide por 2 para mostrar la frecuencia correcta
	
	dir_W <= cnt_int(15 downto 1);						

end contador;
