---------------------------------------------------------------------------------------------------
--
-- Title       : pru_mouse
-- Design      : prueba_rat_PS2
-- Author      : Unknown
-- Company     : Unknown
--
---------------------------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\perifericos\prueba_rat_PS2\compile\pru_mouse.vhd
-- Generated   : Tue Sep 17 19:23:52 2013
-- From        : c:\My_Designs\perifericos\prueba_rat_PS2\src\pru_mouse.bde
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


entity pru_mouse is
  port(
       clk_ext : in STD_LOGIC;
       rst : in STD_LOGIC;
       left : out STD_LOGIC;
       right : out STD_LOGIC;
       DATA : out STD_LOGIC_VECTOR(6 downto 0);
       HABS : out STD_LOGIC_VECTOR(3 downto 0);
       MSB_X : out STD_LOGIC_VECTOR(1 downto 0);
       MSB_Y : out STD_LOGIC_VECTOR(1 downto 0);
       ps2C : inout STD_LOGIC;
       ps2D : inout STD_LOGIC
  );
end pru_mouse;

architecture pru_mouse of pru_mouse is

---- Component declarations -----

component Deco
  port (
       BIN : in STD_LOGIC_VECTOR(3 downto 0);
       SEG7 : out STD_LOGIC_VECTOR(6 downto 0)
  );
end component;
component DIV_FREC
  port (
       CLK_EXT : in STD_LOGIC;
       RST : in STD_LOGIC;
       CLK : out STD_LOGIC;
       CLK_25MHZ : out STD_LOGIC
  );
end component;
component Driver_7seg
  port (
       Dato1 : in STD_LOGIC_VECTOR(6 downto 0);
       Dato2 : in STD_LOGIC_VECTOR(6 downto 0);
       Dato3 : in STD_LOGIC_VECTOR(6 downto 0);
       Dato4 : in STD_LOGIC_VECTOR(6 downto 0);
       clock : in STD_LOGIC;
       DATA : out STD_LOGIC_VECTOR(6 downto 0);
       habs : out STD_LOGIC_VECTOR(3 downto 0)
  );
end component;
component MOUSE
  port (
       CLK : in STD_LOGIC;
       RST : in STD_LOGIC;
       LB : out STD_LOGIC;
       POS_X : out STD_LOGIC_VECTOR(9 downto 0);
       POS_Y : out STD_LOGIC_VECTOR(9 downto 0);
       RB : out STD_LOGIC;
       PS2_CLK : inout STD_LOGIC;
       PS2_DATA : inout STD_LOGIC
  );
end component;

---- Signal declarations used on the diagram ----

signal NET1228 : STD_LOGIC;
signal NET1229 : STD_LOGIC;
signal BUS711 : STD_LOGIC_VECTOR (6 downto 0);
signal BUS715 : STD_LOGIC_VECTOR (6 downto 0);
signal BUS723 : STD_LOGIC_VECTOR (6 downto 0);
signal BUS731 : STD_LOGIC_VECTOR (6 downto 0);
signal Bus_X : STD_LOGIC_VECTOR (9 downto 0);
signal Bus_Y : STD_LOGIC_VECTOR (9 downto 0);

begin

----  Component instantiations  ----

U1 : MOUSE
  port map(
       CLK => NET1229,
       LB => left,
       POS_X => Bus_X,
       POS_Y => Bus_Y,
       PS2_CLK => ps2C,
       PS2_DATA => ps2D,
       RB => right,
       RST => rst
  );

U2 : DIV_FREC
  port map(
       CLK => NET1228,
       CLK_25MHZ => NET1229,
       CLK_EXT => clk_ext,
       RST => rst
  );

U3 : Driver_7seg
  port map(
       DATA => DATA,
       Dato1 => BUS711,
       Dato2 => BUS715,
       Dato3 => BUS723,
       Dato4 => BUS731,
       clock => NET1228,
       habs => HABS
  );

U4 : Deco
  port map(
       BIN(0) => Bus_X(4),
       BIN(1) => Bus_X(5),
       BIN(2) => Bus_X(6),
       BIN(3) => Bus_X(7),
       SEG7 => BUS711
  );

U6 : Deco
  port map(
       BIN(0) => Bus_X(0),
       BIN(1) => Bus_X(1),
       BIN(2) => Bus_X(2),
       BIN(3) => Bus_X(3),
       SEG7 => BUS715
  );

U7 : Deco
  port map(
       BIN(0) => Bus_Y(4),
       BIN(1) => Bus_Y(5),
       BIN(2) => Bus_Y(6),
       BIN(3) => Bus_Y(7),
       SEG7 => BUS723
  );

U9 : Deco
  port map(
       BIN(0) => Bus_Y(0),
       BIN(1) => Bus_Y(1),
       BIN(2) => Bus_Y(2),
       BIN(3) => Bus_Y(3),
       SEG7 => BUS731
  );


---- Terminal assignment ----

    -- Output\buffer terminals
	MSB_X(0) <= Bus_X(8);
	MSB_X(1) <= Bus_X(9);
	MSB_Y(0) <= Bus_Y(8);
	MSB_Y(1) <= Bus_Y(9);


end pru_mouse;
