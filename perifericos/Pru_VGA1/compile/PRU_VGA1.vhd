---------------------------------------------------------------------------------------------------
--
-- Title       : PRU_VGA1
-- Design      : Pru_VGA1
-- Author      : Unknown
-- Company     : Unknown
--
---------------------------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\perifericos\Pru_VGA1\compile\PRU_VGA1.vhd
-- Generated   : Tue Sep 17 19:25:34 2013
-- From        : c:\My_Designs\perifericos\Pru_VGA1\src\PRU_VGA1.bde
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


entity PRU_VGA1 is
  port(
       clk_ext : in STD_LOGIC;
       rst : in STD_LOGIC;
       color : in STD_LOGIC_VECTOR(7 downto 0);
       HS : out STD_LOGIC;
       VS : out STD_LOGIC;
       RGB : out STD_LOGIC_VECTOR(7 downto 0)
  );
end PRU_VGA1;

architecture PRU_VGA1 of PRU_VGA1 is

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
       Pix_Ver : in STD_LOGIC_VECTOR(8 downto 0);
       Pix_hor : in STD_LOGIC_VECTOR(9 downto 0);
       V_Area : in STD_LOGIC;
       color : in STD_LOGIC_VECTOR(7 downto 0);
       RGB_sal : out STD_LOGIC_VECTOR(7 downto 0)
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

signal NET376 : STD_LOGIC;
signal NET396 : STD_LOGIC;
signal BUS105 : STD_LOGIC_VECTOR (8 downto 0);
signal BUS388 : STD_LOGIC_VECTOR (7 downto 0);
signal BUS93 : STD_LOGIC_VECTOR (9 downto 0);

begin

----  Component instantiations  ----

U1 : DIV_FREC
  port map(
       CLK => clk_ext,
       CLK_25MHZ => NET396,
       RST => rst
  );

U2 : vga
  port map(
       CLK => NET396,
       HSYNC => HS,
       PIXEL_H => BUS93,
       PIXEL_RGB => BUS388,
       PIXEL_V => BUS105,
       RGB => RGB,
       RST => rst,
       VSYNC => VS,
       V_AREA => NET376
  );

U3 : gen_img
  port map(
       Pix_Ver => BUS105,
       Pix_hor => BUS93,
       RGB_sal => BUS388,
       V_Area => NET376,
       color => color
  );


end PRU_VGA1;
