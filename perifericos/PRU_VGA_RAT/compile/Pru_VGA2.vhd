---------------------------------------------------------------------------------------------------
--
-- Title       : Pru_VGA2
-- Design      : PRU_VGA_RAT
-- Author      : Unknown
-- Company     : Unknown
--
---------------------------------------------------------------------------------------------------
--
-- File        : d:\my_designs\sem_2011_A\PRU_VGA_RAT\compile\Pru_VGA2.vhd
-- Generated   : Thu Jan 27 20:39:30 2011
-- From        : d:\my_designs\sem_2011_A\PRU_VGA_RAT\src\Pru_VGA2.bde
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


entity Pru_VGA2 is
  port(
       clk_ext : in STD_LOGIC;
       rst : in STD_LOGIC;
       color : in STD_LOGIC_VECTOR(7 downto 0);
       HS : out STD_LOGIC;
       VS : out STD_LOGIC;
       lbot : out STD_LOGIC;
       rbot : out STD_LOGIC;
       RGB_SAL : out STD_LOGIC_VECTOR(7 downto 0);
       ps2C : inout STD_LOGIC;
       ps2D : inout STD_LOGIC
  );
end Pru_VGA2;

architecture Pru_VGA2 of Pru_VGA2 is

---- Component declarations -----

component DIV_FREC
  port (
       CLK : in STD_LOGIC;
       RST : in STD_LOGIC;
       CLK_25MHZ : out STD_LOGIC
  );
end component;
component gen_img
  port (
       POS_X : in STD_LOGIC_VECTOR(9 downto 0);
       POS_Y : in STD_LOGIC_VECTOR(9 downto 0);
       Pix_Ver : in STD_LOGIC_VECTOR(8 downto 0);
       Pix_hor : in STD_LOGIC_VECTOR(9 downto 0);
       V_Area : in STD_LOGIC;
       color : in STD_LOGIC_VECTOR(7 downto 0);
       RGB_sal : out STD_LOGIC_VECTOR(7 downto 0)
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
component vga
  port (
       CLK : in STD_LOGIC;
       PIXEL_RGB : in STD_LOGIC_VECTOR(7 downto 0);
       RST : in STD_LOGIC;
       HSYNC : out STD_LOGIC;
       PIXEL_H : out STD_LOGIC_VECTOR(9 downto 0);
       PIXEL_V : out STD_LOGIC_VECTOR(8 downto 0);
       RGB : out STD_LOGIC_VECTOR(7 downto 0);
       VSYNC : out STD_LOGIC;
       V_AREA : out STD_LOGIC
  );
end component;

---- Signal declarations used on the diagram ----

signal NET1206 : STD_LOGIC;
signal NET925 : STD_LOGIC;
signal BUS765 : STD_LOGIC_VECTOR (9 downto 0);
signal BUS769 : STD_LOGIC_VECTOR (9 downto 0);
signal BUS795 : STD_LOGIC_VECTOR (7 downto 0);
signal BUS829 : STD_LOGIC_VECTOR (9 downto 0);
signal BUS852 : STD_LOGIC_VECTOR (8 downto 0);

begin

----  Component instantiations  ----

U1 : DIV_FREC
  port map(
       CLK => clk_ext,
       CLK_25MHZ => NET1206,
       RST => rst
  );

U2 : gen_img
  port map(
       POS_X => BUS765,
       POS_Y => BUS769,
       Pix_Ver => BUS852,
       Pix_hor => BUS829,
       RGB_sal => BUS795,
       V_Area => NET925,
       color => color
  );

U3 : MOUSE
  port map(
       CLK => NET1206,
       LB => lbot,
       POS_X => BUS765,
       POS_Y => BUS769,
       PS2_CLK => ps2C,
       PS2_DATA => ps2D,
       RB => rbot,
       RST => rst
  );

U4 : vga
  port map(
       CLK => NET1206,
       HSYNC => HS,
       PIXEL_H => BUS829,
       PIXEL_RGB => BUS795,
       PIXEL_V => BUS852,
       RGB => RGB_SAL,
       RST => rst,
       VSYNC => VS,
       V_AREA => NET925
  );


end Pru_VGA2;
