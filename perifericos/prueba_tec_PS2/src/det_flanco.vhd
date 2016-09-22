---------------------------------------------------------------------------------------------------
--
-- Title       : det_flanco
-- Design      : prueba_tec_PS2
-- Author      : FSE
-- Company     : UTM
--
---------------------------------------------------------------------------------------------------
--
-- File        : det_flanco.vhd
-- Generated   : Thu Jan 15 12:35:35 2015
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity det_flanco is
	 port(
		 ser_In : in STD_LOGIC;
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;
		 flanco : out STD_LOGIC
	     );
end det_flanco;

architecture det_flanco of det_flanco is
signal  filtro : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin

	process(clk, rst)
	begin
		if rst = '1' then
			filtro <= "0000";
		elsif rising_edge(clk) then
			filtro <=  filtro(2 downto 0) & ser_In;
		end if;
	end process;
	
	flanco <= '1' when filtro = "1100" else '0';
		

end det_flanco;
