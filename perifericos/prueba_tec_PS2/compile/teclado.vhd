---------------------------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : prueba_tec_PS2
-- Author      : FSE
-- Company     : UTM
--
---------------------------------------------------------------------------------------------------
--
-- File        : E:\My_Designs\perifericos\prueba_tec_PS2\compile\teclado.vhd
-- Generated   : 01/15/15 13:12:54
-- From        : E:\My_Designs\perifericos\prueba_tec_PS2\src\teclado.asf
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

entity teclado is 
	port (
		clk: in STD_LOGIC;
		dato_ser: in STD_LOGIC;
		flanco: in STD_LOGIC;
		rst: in STD_LOGIC;
		CR: out STD_LOGIC_VECTOR (7 downto 0);
		cr_listo: out STD_LOGIC);
end;

architecture teclado_arch of teclado is

-- diagram signals declarations
signal cnt_bits: INTEGER range 0 to 10;
signal cr_int: STD_LOGIC_VECTOR (7 downto 0);

-- SYMBOLIC ENCODED state machine: Sreg0
type Sreg0_type is (Parity, Sync, Ready, Rec, Start, Stop, Idle);
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
	Sreg0 <= Idle;
	-- Set default values for registered outputs/signals and for variables
	-- ...
	cnt_bits <= 0;
elsif clk'event and clk = '1' then
	-- Set default values for registered outputs/signals and for variables
	-- ...
	case Sreg0 is
		when Parity =>
			if flanco = '1' then	
				Sreg0 <= Stop;
			elsif flanco = '0' then	
				Sreg0 <= Parity;
			end if;
		when Sync =>
			if cnt_bits = 8 then	
				Sreg0 <= Parity;
			elsif cnt_bits < 8 then	
				Sreg0 <= Start;
			end if;
		when Ready =>
			Sreg0 <= Idle;
		when Rec =>
			cr_int <= dato_ser & cr_int(7 downto 1);
			cnt_bits <= cnt_bits + 1;
			Sreg0 <= Sync;
		when Start =>
			cnt_bits <= cnt_bits;
			if flanco = '0' then	
				Sreg0 <= Start;
			elsif flanco = '1' then	
				Sreg0 <= Rec;
			end if;
		when Stop =>
			if flanco = '1' then	
				Sreg0 <= Ready;
			elsif flanco = '0' then	
				Sreg0 <= Stop;
			end if;
		when Idle =>
			cnt_bits <= 0;
			if flanco = '0' then	
				Sreg0 <= Idle;
			elsif flanco = '1' and dato_ser = '0' then	
				Sreg0 <= Start;
			end if;
		when others =>
			null;
	end case;
end if;
end process;

-- signal assignment statements for combinatorial outputs
CR_assignment:
CR <= cr_int when (Sreg0 = Idle) else
      cr_int;

cr_listo_assignment:
cr_listo <= '0' when (Sreg0 = Idle) else
            '1' when (Sreg0 = Ready) else
            '0';

end teclado_arch;
