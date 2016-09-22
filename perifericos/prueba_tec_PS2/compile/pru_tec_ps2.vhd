---------------------------------------------------------------------------------------------------
--
-- Title       : pru_tec_PS2
-- Design      : prueba_tec_PS2
-- Author      : Unknown
-- Company     : Unknown
--
---------------------------------------------------------------------------------------------------
--
-- File        : E:\My_Designs\perifericos\prueba_tec_PS2\compile\pru_tec_ps2.vhd
-- Generated   : Thu Jan 15 12:46:43 2015
-- From        : E:\My_Designs\perifericos\prueba_tec_PS2\src\pru_tec_ps2.bde
-- By          : Bde2Vhdl ver. 2.6
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--
---------------------------------------------------------------------------------------------------
-- Design unit header --
library IEEE;
use IEEE.std_logic_1164.all;


entity pru_tec_PS2 is
  port(
       clk_ext : in STD_LOGIC;
       clk_ps : in STD_LOGIC;
       dato_ps : in STD_LOGIC;
       rst : in STD_LOGIC;
       cr_listo : out STD_LOGIC;
       DATA : out STD_LOGIC_VECTOR(6 downto 0);
       HABS : out STD_LOGIC_VECTOR(3 downto 0)
  );
end pru_tec_PS2;

architecture pru_tec_PS2 of pru_tec_PS2 is

---- Component declarations -----

component Deco
  port (
       BIN : in STD_LOGIC_VECTOR(3 downto 0);
       SEG7 : out STD_LOGIC_VECTOR(6 downto 0)
  );
end component;
component det_flanco
  port (
       clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       ser_In : in STD_LOGIC;
       flanco : out STD_LOGIC
  );
end component;
component Divisor
  port (
       clk_ext : in STD_LOGIC;
       clk : out STD_LOGIC
  );
end component;
component Driver_7seg
  port (
       Dato1 : in STD_LOGIC_VECTOR(6 downto 0);
       Dato2 : in STD_LOGIC_VECTOR(6 downto 0);
       clock : in STD_LOGIC;
       DATA : out STD_LOGIC_VECTOR(6 downto 0);
       HABS : out STD_LOGIC_VECTOR(3 downto 0)
  );
end component;
component Teclado
  port (
       clk : in STD_LOGIC;
       dato_ser : in STD_LOGIC;
       flanco : in STD_LOGIC;
       rst : in STD_LOGIC;
       CR : out STD_LOGIC_VECTOR(7 downto 0);
       cr_listo : out STD_LOGIC
  );
end component;

---- Signal declarations used on the diagram ----

signal NET1720 : STD_LOGIC;
signal NET1745 : STD_LOGIC;
signal BUS167 : STD_LOGIC_VECTOR (6 downto 0);
signal BUS171 : STD_LOGIC_VECTOR (6 downto 0);
signal CR_BUS : STD_LOGIC_VECTOR (7 downto 0);

begin

----  Component instantiations  ----

U1 : Teclado
  port map(
       CR => CR_BUS,
       clk => NET1745,
       cr_listo => cr_listo,
       dato_ser => dato_ps,
       flanco => NET1720,
       rst => rst
  );

U2 : Deco
  port map(
       BIN(0) => CR_BUS(0),
       BIN(1) => CR_BUS(1),
       BIN(2) => CR_BUS(2),
       BIN(3) => CR_BUS(3),
       SEG7 => BUS167
  );

U3 : Deco
  port map(
       BIN(0) => CR_BUS(4),
       BIN(1) => CR_BUS(5),
       BIN(2) => CR_BUS(6),
       BIN(3) => CR_BUS(7),
       SEG7 => BUS171
  );

U4 : Driver_7seg
  port map(
       DATA => DATA,
       Dato1 => BUS167,
       Dato2 => BUS171,
       HABS => HABS,
       clock => NET1745
  );

U5 : Divisor
  port map(
       clk => NET1745,
       clk_ext => clk_ext
  );

U6 : det_flanco
  port map(
       clk => NET1745,
       flanco => NET1720,
       rst => rst,
       ser_In => clk_ps
  );


end pru_tec_PS2;
