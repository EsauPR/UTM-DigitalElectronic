---------------------------------------------------------------------------------------------------
--
-- Title       : TOP_C
-- Design      : Cronometro_C
-- Author      : Unknown
-- Company     : Unknown
--
---------------------------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\Cronometro_C\compile\TOP_C.vhd
-- Generated   : Fri Feb  6 01:52:20 2015
-- From        : c:\My_Designs\Cronometro_C\src\TOP_C.bde
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


entity TOP_C is
  port(
       clk50 : in STD_LOGIC;
       pause : in STD_LOGIC;
       rst : in STD_LOGIC;
       start : in STD_LOGIC;
       color : in STD_LOGIC_VECTOR(7 downto 0);
       HS : out STD_LOGIC;
       VS : out STD_LOGIC;
       RGB : out STD_LOGIC_VECTOR(7 downto 0)
  );
end TOP_C;

architecture TOP_C of TOP_C is

---- Component declarations -----

component cnt_0_5
  port (
       cc : in STD_LOGIC;
       clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       carry : out STD_LOGIC;
       data : out STD_LOGIC_VECTOR(3 downto 0)
  );
end component;
component cnt_0_9
  port (
       cc : in STD_LOGIC;
       clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       carry : out STD_LOGIC;
       data : out STD_LOGIC_VECTOR(3 downto 0)
  );
end component;
component DF_VGA
  port (
       CLK : in STD_LOGIC;
       RST : in STD_LOGIC;
       CLK_25MHZ : out STD_LOGIC
  );
end component;
component div_frec
  port (
       clk50 : in STD_LOGIC;
       rst : in STD_LOGIC;
       clk : out STD_LOGIC
  );
end component;
component filtro
  port (
       clk : in STD_LOGIC;
       pause : in STD_LOGIC;
       rst : in STD_LOGIC;
       start : in STD_LOGIC;
       cc : out STD_LOGIC
  );
end component;
component gen_img
  port (
       Pix_Ver : in STD_LOGIC_VECTOR(8 downto 0);
       Pix_hor : in STD_LOGIC_VECTOR(9 downto 0);
       V_Area : in STD_LOGIC;
       color : in STD_LOGIC_VECTOR(7 downto 0);
       data1 : in STD_LOGIC_VECTOR(3 downto 0);
       data2 : in STD_LOGIC_VECTOR(3 downto 0);
       data3 : in STD_LOGIC_VECTOR(3 downto 0);
       data4 : in STD_LOGIC_VECTOR(3 downto 0);
       data5 : in STD_LOGIC_VECTOR(3 downto 0);
       data6 : in STD_LOGIC_VECTOR(3 downto 0);
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

signal NET203 : STD_LOGIC;
signal NET220 : STD_LOGIC;
signal NET223 : STD_LOGIC;
signal NET235 : STD_LOGIC;
signal NET247 : STD_LOGIC;
signal NET259 : STD_LOGIC;
signal NET296 : STD_LOGIC;
signal NET340 : STD_LOGIC;
signal NET614 : STD_LOGIC;
signal BUS494 : STD_LOGIC_VECTOR (3 downto 0);
signal BUS502 : STD_LOGIC_VECTOR (3 downto 0);
signal BUS508 : STD_LOGIC_VECTOR (3 downto 0);
signal BUS522 : STD_LOGIC_VECTOR (3 downto 0);
signal BUS530 : STD_LOGIC_VECTOR (3 downto 0);
signal BUS540 : STD_LOGIC_VECTOR (3 downto 0);
signal BUS639 : STD_LOGIC_VECTOR (7 downto 0);
signal BUS647 : STD_LOGIC_VECTOR (9 downto 0);
signal BUS670 : STD_LOGIC_VECTOR (8 downto 0);

begin

----  Component instantiations  ----

U1 : div_frec
  port map(
       clk => NET296,
       clk50 => clk50,
       rst => rst
  );

U10 : gen_img
  port map(
       Pix_Ver => BUS670,
       Pix_hor => BUS647,
       RGB_sal => BUS639,
       V_Area => NET614,
       color => color,
       data1 => BUS494,
       data2 => BUS502,
       data3 => BUS508,
       data4 => BUS522,
       data5 => BUS530,
       data6 => BUS540
  );

U11 : vga
  port map(
       CLK => NET340,
       HSYNC => HS,
       PIXEL_H => BUS647,
       PIXEL_RGB => BUS639,
       PIXEL_V => BUS670,
       RGB => RGB,
       RST => rst,
       VSYNC => VS,
       V_AREA => NET614
  );

U2 : cnt_0_9
  port map(
       carry => NET203,
       cc => NET220,
       clk => NET296,
       data => BUS494,
       rst => rst
  );

U3 : cnt_0_9
  port map(
       carry => NET223,
       cc => NET220,
       clk => NET203,
       data => BUS502,
       rst => rst
  );

U4 : cnt_0_9
  port map(
       carry => NET235,
       cc => NET220,
       clk => NET223,
       data => BUS508,
       rst => rst
  );

U5 : cnt_0_5
  port map(
       carry => NET247,
       cc => NET220,
       clk => NET235,
       data => BUS522,
       rst => rst
  );

U6 : cnt_0_9
  port map(
       carry => NET259,
       cc => NET220,
       clk => NET247,
       data => BUS530,
       rst => rst
  );

U7 : cnt_0_5
  port map(
       cc => NET220,
       clk => NET259,
       data => BUS540,
       rst => rst
  );

U8 : DF_VGA
  port map(
       CLK => clk50,
       CLK_25MHZ => NET340,
       RST => rst
  );

U9 : filtro
  port map(
       cc => NET220,
       clk => clk50,
       pause => pause,
       rst => rst,
       start => start
  );


end TOP_C;
