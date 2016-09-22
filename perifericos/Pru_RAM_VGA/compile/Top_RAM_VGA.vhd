---------------------------------------------------------------------------------------------------
--
-- Title       : No Title
-- Design      : Pru_RAM_VGA
-- Author      : FSE
-- Company     : UTT
--
---------------------------------------------------------------------------------------------------
--
-- File        : e:\My_Designs\perifericos\Pru_RAM_VGA\compile\Top_RAM_VGA.vhd
-- Generated   : Thu Jan 22 10:55:47 2015
-- From        : e:\My_Designs\perifericos\Pru_RAM_VGA\src\Top_RAM_VGA.bde
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


entity Top_Img_Mem_Ext is
  port(
       clk_ext : in STD_LOGIC;
       rst : in STD_LOGIC;
       Col : in STD_LOGIC_VECTOR(3 downto 0);
       Pag : in STD_LOGIC_VECTOR(3 downto 0);
       FlashCs : out STD_LOGIC;
       HSYNC : out STD_LOGIC;
       VSYNC : out STD_LOGIC;
       ramCE : out STD_LOGIC;
       ramLB : out STD_LOGIC;
       ramOE : out STD_LOGIC;
       ramUB : out STD_LOGIC;
       ramWE : out STD_LOGIC;
       MemADR : out STD_LOGIC_VECTOR(22 downto 0);
       RGB : out STD_LOGIC_VECTOR(7 downto 0);
       MemDB : inout STD_LOGIC_VECTOR(7 downto 0)
  );
end Top_Img_Mem_Ext;

architecture Top_Img_Mem_Ext of Top_Img_Mem_Ext is

---- Component declarations -----

component contador
  port (
       clk : in STD_LOGIC;
       hab : in STD_LOGIC;
       rst : in STD_LOGIC;
       dir_W : out STD_LOGIC_VECTOR(14 downto 0)
  );
end component;
component control_Z
  port (
       DOUT : in STD_LOGIC_VECTOR(7 downto 0);
       g : in STD_LOGIC;
       DIN : out STD_LOGIC_VECTOR(7 downto 0);
       PBID : inout STD_LOGIC_VECTOR(7 downto 0)
  );
end component;
component div_frec
  port (
       CLK_50 : in STD_LOGIC;
       RST : in STD_LOGIC;
       CLK_25 : out STD_LOGIC
  );
end component;
component man_mem_ext
  port (
       clk : in STD_LOGIC;
       rd : in STD_LOGIC;
       rst : in STD_LOGIC;
       wr : in STD_LOGIC;
       def_IO : out STD_LOGIC;
       ramCE : out STD_LOGIC;
       ramOE : out STD_LOGIC;
       ramWE : out STD_LOGIC
  );
end component;
component Mux_Dir
  port (
       Dir_R : in STD_LOGIC_VECTOR(18 downto 0);
       Dir_W_High : in STD_LOGIC_VECTOR(3 downto 0);
       Dir_W_Low : in STD_LOGIC_VECTOR(14 downto 0);
       Sel : in STD_LOGIC;
       Dir_M : out STD_LOGIC_VECTOR(22 downto 0)
  );
end component;
component sel_Color
  port (
       sel : in STD_LOGIC_VECTOR(3 downto 0);
       Color : out STD_LOGIC_VECTOR(7 downto 0)
  );
end component;
component vga
  port (
       CLK : in STD_LOGIC;
       PIXEL_RGB : in STD_LOGIC_VECTOR(7 downto 0);
       RST : in STD_LOGIC;
       HSYNC : out STD_LOGIC;
       RGB : out STD_LOGIC_VECTOR(7 downto 0);
       VSYNC : out STD_LOGIC;
       V_AREA : out STD_LOGIC;
       dir_mem : out STD_LOGIC_VECTOR(18 downto 0)
  );
end component;

----     Constants     -----
constant VCC_CONSTANT   : STD_LOGIC := '1';
constant GND_CONSTANT   : STD_LOGIC := '0';

---- Signal declarations used on the diagram ----

signal clk : STD_LOGIC;
signal GND : STD_LOGIC;
signal NET10807 : STD_LOGIC;
signal NET10823 : STD_LOGIC;
signal NET11024 : STD_LOGIC;
signal NET13653 : STD_LOGIC;
signal NET194 : STD_LOGIC;
signal VCC : STD_LOGIC;
signal BUS11832 : STD_LOGIC_VECTOR (7 downto 0);
signal BUS13305 : STD_LOGIC_VECTOR (7 downto 0);
signal BUS13496 : STD_LOGIC_VECTOR (18 downto 0);
signal BUS13781 : STD_LOGIC_VECTOR (14 downto 0);

begin

----  Component instantiations  ----

U1 : div_frec
  port map(
       CLK_25 => clk,
       CLK_50 => clk_ext,
       RST => rst
  );

U12 : man_mem_ext
  port map(
       clk => clk,
       def_IO => NET11024,
       ramCE => ramCE,
       ramOE => ramOE,
       ramWE => ramWE,
       rd => NET13653,
       rst => rst,
       wr => NET194
  );

NET194 <= not(NET13653);

U3 : control_Z
  port map(
       DIN => BUS11832,
       DOUT => BUS13305,
       PBID => MemDB,
       g => NET11024
  );

U4 : contador
  port map(
       clk => clk,
       dir_W => BUS13781,
       hab => NET194,
       rst => rst
  );

U5 : vga
  port map(
       CLK => clk,
       HSYNC => HSYNC,
       PIXEL_RGB => BUS11832,
       RGB => RGB,
       RST => rst,
       VSYNC => VSYNC,
       V_AREA => NET13653,
       dir_mem => BUS13496
  );

U6 : sel_Color
  port map(
       Color => BUS13305,
       sel => Col
  );

U7 : Mux_Dir
  port map(
       Dir_M => MemADR,
       Dir_R => BUS13496,
       Dir_W_High => Pag,
       Dir_W_Low => BUS13781,
       Sel => NET13653
  );


---- Power , ground assignment ----

VCC <= VCC_CONSTANT;
GND <= GND_CONSTANT;
NET10807 <= VCC;
NET10823 <= GND;

---- Terminal assignment ----

    -- Output\buffer terminals
	FlashCs <= NET10807;
	ramLB <= NET10823;
	ramUB <= NET10807;


end Top_Img_Mem_Ext;
