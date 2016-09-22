---------------------------------------------------------------------------------------------------
--
-- Title       : conta4bits
-- Design      : contafiltro
-- Author      : Esau
-- Company     : WORKGROUP
--
---------------------------------------------------------------------------------------------------
--
-- File        : CONT4B.vhd
-- Generated   : Tue Dec  2 22:35:03 2014
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
--{entity {conta4bits} architecture {conta4bits}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.STD_LOGIC_UNSIGNED.all;




entity CONT4B is
	 port(
				rst : in STD_LOGIC;
				clk : in STD_LOGIC;
				boton : in STD_LOGIC;
				up_down : in STD_LOGIC;
				s : out STD_LOGIC_VECTOR(7 downto 0);
				habs : out STD_LOGIC_VECTOR(3 downto 0);
				leds : out STD_LOGIC_VECTOR(3 downto 0)
	     );
end CONT4B;

--}} End of automatically maintained section

architecture CONT4B of CONT4B is 
	signal cnt_clk: STD_LOGIC_VECTOR(15 downto 0);
	signal clk_int: STD_LOGIC;
	signal band, clk_i: STD_LOGIC;
	signal s_in : STD_LOGIC_VECTOR(3 downto 0);
begin
	
	divisor: process ( clk )
	begin
		if rst = '1' then
			cnt_clk <= (others => '0');
		else
			if rising_edge( clk ) then
				cnt_clk <= cnt_clk + 1;
			end if;
		end if;
	end process;

	clk_i <= cnt_clk( 15 );
	
	filtro: process( clk_i )	
	begin		
		if rising_edge(clk_i) then
			band <= boton;
		end if;
		
	end process;
	
	clk_int <= '1' when band = '0' and boton = '1' else '0';
	
	contador: process ( clk_i )	
	begin
		if rst = '1' then 
				s_in <= (others => '0');	
		elsif rising_edge( clk_i ) then
				if clk_int = '1' then
						if up_down = '1' then
							if s_in = "1001" then
								s_in <= "0000";
							else
								s_in <= s_in + 1;
							end if;
						else
							if s_in = "0000" then
								s_in <= "1001";
							else
								s_in <= s_in - 1;
							end if;
						end if;
				end if;
		end if;
	end process;
	 
	bcd:process(s_in)	 
	begin
		habs <= "0111";
			case
				s_in is
					when "0000" => s <="10000001";
					when "0001" => s <="11001111";
					when "0010" => s <="10010010";
					when "0011" => s <="10000110"; 
					when "0100" => s <="11001100";
					when "0101" => s <="10100100";
					when "0110" => s <="10100000";
					when "0111" => s <="10001111";
					when "1000" => s <="10000000";	 
					when others => s <="10001100";
			end case;
			
		leds <= s_in;
			
		end process;
		
end CONT4B;
