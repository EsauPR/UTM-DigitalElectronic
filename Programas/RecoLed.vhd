---------------------------------------------------------------------------------------------------
--
-- Title       : RecoLed
-- Design      : Recorrido
-- Author      : Esau
-- Company     : WORKGROUP
--
---------------------------------------------------------------------------------------------------
--
-- File        : RecoLed.vhd
-- Generated   : Mon Dec  1 21:08:38 2014
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
--{entity {RecoLed} architecture {RecoLed}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;



entity RecoLed is
	port(
		clk50: in STD_LOGIC;
		rst: in STD_LOGIC;
		bton: in STD_LOGIC_VECTOR(1 downto 0); 
		Sal : out STD_LOGIC_VECTOR(7 downto 0)
	);
end RecoLed;

--}} End of automatically maintained section

architecture RecoLed of RecoLed is

signal cont_clk: STD_LOGIC_VECTOR(23 downto 0);	
signal clk: STD_LOGIC;
signal bnd: STD_LOGIC;
signal contador: STD_LOGIC_VECTOR(2 downto 0);

begin							  
	
	divisor : process(clk50, rst)
	begin
		if rst = '1' then
			cont_clk <= (others => '0');
		elsif rising_edge(clk50) then
			cont_clk <= cont_clk + 1;
		end if;
		
		case bton is
			when "00" => clk <= cont_clk(23);
			when "01" => clk <= cont_clk(22);
			when "10" => clk <= cont_clk(21);
			when others => clk <= cont_clk(20);
		end case;
					 
	end process;	 
	
	
	
	recorrer: process( clk, rst )
	begin
		if rst = '1' then
			contador <= (others => '0');
			
			
		elsif rising_edge(clk) then
			if bnd = '0' then
				contador <= contador + 1;
				
			elsif bnd = '1' then
				contador <= contador - 1;
				
			end if;
			
			
			
			if contador = 6 then
				bnd <= '1';
			elsif contador = 1 then
				bnd <= '0';
			end if;
		end if;
	end process;
	
	with contador select
	Sal <= "10000000" when "000",
	       "01000000" when "001",
		    "00100000" when "010",
	 	    "00010000" when "011",
	 	    "00001000" when "100",
		    "00000100" when "101",
		    "00000010" when "110",
		    "00000001" when others;
	
end RecoLed;
