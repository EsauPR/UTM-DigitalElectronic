---------------------------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : Pru_RAM_VGA
-- Author      : FSE
-- Company     : UTT
--
---------------------------------------------------------------------------------------------------
--
-- File        : e:\My_Designs\perifericos\Pru_RAM_VGA\compile\man_mem_ext.vhd
-- Generated   : 01/22/15 10:55:43
-- From        : e:\My_Designs\perifericos\Pru_RAM_VGA\src\man_mem_ext.asf
-- By          : FSM2VHDL ver. 4.0.3.8
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity man_mem_ext is 
	port (
		clk: in STD_LOGIC;
		rd: in STD_LOGIC;
		rst: in STD_LOGIC;
		wr: in STD_LOGIC;
		def_IO: out STD_LOGIC;
		ramCE: out STD_LOGIC;
		ramOE: out STD_LOGIC;
		ramWE: out STD_LOGIC);
end;

architecture man_mem_ext_arch of man_mem_ext is

-- SYMBOLIC ENCODED state machine: Sreg0
type Sreg0_type is (Espera, Escribe, Lee);
-- attribute enum_encoding of Sreg0_type: type is ... -- enum_encoding attribute is not supported for symbolic encoding

signal Sreg0: Sreg0_type;


begin
-- concurrent signals assignments
-- diagram ACTION


----------------------------------------------------------------------
-- Machine: Sreg0
----------------------------------------------------------------------
Sreg0_machine: process (clk, rst)
begin
if rst = '1' then	
	Sreg0 <= Espera;
	-- Set default values for registered outputs/signals and for variables
	-- ...
elsif clk'event and clk = '1' then
	-- Set default values for registered outputs/signals and for variables
	-- ...
	case Sreg0 is
		when Espera =>
			if wr = '1' then	
				Sreg0 <= Escribe;
			elsif rd = '1' then	
				Sreg0 <= Lee;
			elsif rd = '0' and wr = '0' then	
				Sreg0 <= Espera;
			end if;
		when Escribe =>
			Sreg0 <= Espera;
		when Lee =>
			if rd = '1' then	
				Sreg0 <= Lee;
			elsif rd = '0' then	
				Sreg0 <= Espera;
			end if;
		when others =>
			null;
	end case;
end if;
end process;

-- signal assignment statements for combinatorial outputs
def_IO_assignment:
def_IO <= '0' when (Sreg0 = Espera) else
          '1' when (Sreg0 = Escribe) else
          '0' when (Sreg0 = Lee) else
          '0';

ramCE_assignment:
ramCE <= '1' when (Sreg0 = Espera) else
         '0' when (Sreg0 = Escribe) else
         '0' when (Sreg0 = Lee) else
         '1';

ramOE_assignment:
ramOE <= '1' when (Sreg0 = Espera) else
         '1' when (Sreg0 = Escribe) else
         '0' when (Sreg0 = Lee) else
         '1';

ramWE_assignment:
ramWE <= '1' when (Sreg0 = Espera) else
         '0' when (Sreg0 = Escribe) else
         '1' when (Sreg0 = Lee) else
         '1';

end man_mem_ext_arch;
