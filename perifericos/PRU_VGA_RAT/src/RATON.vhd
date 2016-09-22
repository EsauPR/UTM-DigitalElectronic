LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

Entity MOUSE IS


   port( CLK             				: in STD_LOGIC;
         RST  			                : in STD_LOGIC;
         PS2_DATA				        : inout STD_LOGIC;
         PS2_CLK 				        : inout STD_LOGIC;
         LB                             : out STD_LOGIC;
		 RB                             : out STD_LOGIC;
		 POS_Y 		                    : out std_logic_vector(9 DOWNTO 0); 
		 POS_X		                    : out std_logic_vector(9 DOWNTO 0));       		
end MOUSE;

Architecture behavior of MOUSE is

type STATE_TYPE is (INHIBIT_TRANS, LOAD_COMMAND,LOAD_COMMAND2, WAIT_OUTPUT_READY,
					WAIT_CMD_ACK, INPUT_PACKETS);

---------------------------------------Señales-------------------------------------
signal mouse_state, mouse_state2							: state_type;
signal wait_counter					: std_logic_vector(10 DOWNTO 0);
signal CHARIN, CHAROUT						: std_logic_vector(7 DOWNTO 0);
signal new_cursor_row, new_cursor_column 	: std_logic_vector(9 DOWNTO 0);
signal cursor_row, cursor_column 			: std_logic_vector(9 DOWNTO 0);
signal INCNT, contador_envia, mSB_OUT 				: std_logic_vector(3 DOWNTO 0);
signal PACKET_COUNT 						: std_logic_vector(1 DOWNTO 0);
signal SHIFTIN 								: std_logic_vector(8 DOWNTO 0);
signal PACKET_CHAR1, PACKET_CHAR2, 
		PACKET_CHAR3 						: std_logic_vector(7 DOWNTO 0); 
signal MOUSE_CLK_BUF, DATA_READY, READ_CHAR	: std_logic;
signal i									: integer;
signal cursor, iready_set, break, toggle_next, 
		FIN_ENVIA,HAB_ENVIA 	            : std_logic;
signal DATO_DIR, MOUSE_DATA_OUT, DATO_SALIDA, 
		MOUSE_CLK_DIR 						: std_logic;
signal MOUSE_CLK_FILTER 					: std_logic;

signal FIN_CONTADOR: STD_LOGIC;


-------------------------------------Constantes-------------------------------------

Constant MAX_X: STD_LOGIC_VECTOR (9 downto 0) := CONV_STD_LOGIC_VECTOR(640,10);	 --Maxima posicion en X
Constant MAX_Y: STD_LOGIC_VECTOR (9 downto 0) := CONV_STD_LOGIC_VECTOR(480,10);	 --Maxima posicion en Y	  

-----------------------------------------------
BEGIN

POS_Y <= cursor_row;
POS_X <= cursor_column;

----------------------Control logico de las señales triestado PS2  ----------------------
			
PS2_DATA <= 'Z' WHEN DATO_DIR = '0' ELSE DATO_SALIDA;
PS2_CLK <=  'Z' WHEN MOUSE_CLK_DIR = '0' ELSE MOUSE_CLK_BUF;
-----------------------------------------------

-----------------------------Filtro de la señal de reloj PS2 ----------------------	 

--Evita que existan falsos positivos en los flancos

FILTER:process(CLK, RST)

variable fill_filter: STD_LOGIC_VECTOR (7 downto 0);	

begin
	if (RST = '1') then
		
	   fill_filter := (others=>'1');
	   
	   MOUSE_CLK_FILTER <= '1';
	   
	elsif (CLK'event and CLK = '1') then   				  
		
	   fill_filter(7 downto 0) := fill_filter (6 downto 0) & PS2_CLK;
	  
	   if (fill_filter = "11111111") then 
		  MOUSE_CLK_FILTER <= '1';	  				
	   elsif(fill_filter = "00000000") then
		  MOUSE_CLK_FILTER <= '0';  	
	   end if;				 
	   
	end if;
end process FILTER;
-----------------------------------

----Conteo de espera de al menos 60uS ----------
HINDER: process(CLK, RST)
begin		
 if RST = '1' THEN	  
	wait_counter <= (others=>'0');
	FIN_CONTADOR <= '0';
 elsif CLK'EVENT AND CLK = '1' THEN
	wait_counter <= wait_counter + 1;
	IF wait_counter(10 DOWNTO 9) = "11" THEN
		FIN_CONTADOR <='1';
	end if;
 end if;
end process HINDER;
--------------------------------------------------

-----------------------Inhibe la transmision e inicializa el "Streaming mode" -----------

--Al alimentar el dispositivo este envía los codigos de reconocimientos
--0xAA y 0x00 
--La linea de de reloj del dipositivo PS2 es forzada a un estado logico bajo al menos 60uS 
-- para inhibir cualquier transmision

--Se envia el comando para inicializar el rato en modo Streaming mediante el comando F4
--  esto es que el raton enviará la informacion referente al movimiento
--  y estado de los botones en paquetes de 3 bytes

SECUENCIAL: process (mouse_state2, wait_counter, FIN_ENVIA, IREADY_SET)			 
begin
	CASE mouse_state2 IS				
		
                WHEN INHIBIT_TRANS =>  
				HAB_ENVIA <= '0';	
				
				IF FIN_CONTADOR = '1' THEN
					 mouse_state <= LOAD_COMMAND;
				else
					mouse_state <= INHIBIT_TRANS;
				END IF;
					-- Enable Streaming Mode Command, F4
						charout <= "11110100";
					-- Pull data low to signal data available to mouse
				WHEN LOAD_COMMAND =>
						HAB_ENVIA <= '1';
						mouse_state <= LOAD_COMMAND2;
				WHEN LOAD_COMMAND2 =>
						HAB_ENVIA <= '1';
						mouse_state <= WAIT_OUTPUT_READY;
		-- Wait for Mouse to Clock out all bits in command.
		-- Command sent is F4, Enable Streaming Mode
		-- This tells the mouse to start sending 3-byte packets with movement data
				WHEN WAIT_OUTPUT_READY =>
					HAB_ENVIA <= '0';
			-- Output Ready signals that all data is clocked out of shift register
					IF FIN_ENVIA='1' THEN
						mouse_state <= WAIT_CMD_ACK;
					ELSE
						mouse_state <= WAIT_OUTPUT_READY;
					END IF;
		-- Wait for Mouse to send back Command Acknowledge, FA
				WHEN WAIT_CMD_ACK =>
					HAB_ENVIA <= '0';
					IF IREADY_SET='1' THEN
						mouse_state <= INPUT_PACKETS;
					END IF;
		-- Release clock_25Mhz and data lines and go into mouse input mode
		-- Stay in this state and recieve 3-byte mouse data packets forever
		-- Default rate is 100 packets per second
				WHEN INPUT_PACKETS =>
						mouse_state <= INPUT_PACKETS;
			END CASE;
		
END PROCESS SECUENCIAL;


COMBINACIONAL: process (CLK, RST)
begin		
 if RST = '1' THEN
	mouse_state2 <= INHIBIT_TRANS;
	
	
 elsif CLK'EVENT AND CLK = '1' THEN
	   mouse_state2 <= mouse_state;
  end if;
end process COMBINACIONAL;	
--------------------------------------------


	WITH mouse_state2 SELECT
-- Mouse Data Tri-state control line: '1' FLEX Chip drives, '0'=Mouse Drives
		DATO_DIR 	<=	'0'	WHEN INHIBIT_TRANS,
							'0'	WHEN LOAD_COMMAND,
							'0'	WHEN LOAD_COMMAND2,
							'1'	WHEN WAIT_OUTPUT_READY,
							'0'	WHEN WAIT_CMD_ACK,
							'0'	WHEN INPUT_PACKETS;
-- Mouse Clock Tri-state control line: '1' FLEX Chip drives, '0'=Mouse Drives
	WITH mouse_state SELECT
		MOUSE_CLK_DIR 	<=	'1'	WHEN INHIBIT_TRANS,
							'1'	WHEN LOAD_COMMAND,
							'1'	WHEN LOAD_COMMAND2,
							'0'	WHEN WAIT_OUTPUT_READY,
							'0'	WHEN WAIT_CMD_ACK,
							'0'	WHEN INPUT_PACKETS;
	WITH mouse_state SELECT
-- Input to FLEX chip tri-state buffer mouse clock_25Mhz line
		MOUSE_CLK_BUF 	<=	'0'	WHEN INHIBIT_TRANS,
							'1'	WHEN LOAD_COMMAND,
							'1'	WHEN LOAD_COMMAND2,
							'1'	WHEN WAIT_OUTPUT_READY,
							'1'	WHEN WAIT_CMD_ACK,
							'1'	WHEN INPUT_PACKETS;

-- filter for mouse clock	   
	



	--This process sends serial data going to the mouse
SEND_UART: process (HAB_ENVIA, Mouse_clK_filter)
variable contador_envia: STD_LOGIC_VECTOR (3 downto 0);
variable envia_cadena: STD_LOGIC;
variable cadena: STD_LOGIC_VECTOR(10 downto 0);
begin
if HAB_ENVIA = '1' then
	contador_envia := "0000";
    envia_cadena := '1';
	FIN_ENVIA <= '0';
		-- Send out Start Bit(0) + Command(F4) + Parity  Bit(0) + Stop Bit(1)
	cadena(8 downto 1) := CHAROUT ;
		-- START BIT
	cadena(0) := '0';
		-- COMPUTE ODD PARITY BIT
	cadena(9) :=  not (charout(7) xor charout(6) xor charout(5) xor 
		charout(4) xor Charout(3) xor charout(2) xor charout(1) xor 
		charout(0));
		-- STOP BIT 
	cadena(10) := '1';
		-- Data Available Flag to Mouse
		-- Tells mouse to clock out command data (is also start bit)
    DATO_SALIDA <= '0';

elsif(MOUSE_CLK_filter'event and MOUSE_CLK_filter='0') then
if DATO_DIR='1' then
		-- SHIFT OUT NEXT SERIAL BIT
  if envia_cadena = '1' then
		-- Loop through all bits in shift register
        if contador_envia <= "1001" then
         contador_envia := contador_envia + 1;
		-- Shift out next bit to mouse
         
         DATO_SALIDA <= cadena(1);
		 
		 cadena(9 downto 0) := cadena(10 downto 1);
		 cadena(10) := '1';
		 FIN_ENVIA <= '0';
		-- END OF CHARACTER
	 else
     	envia_cadena := '0';
		-- Signal the character has been output
		FIN_ENVIA <= '1';
		contador_envia := "0000";
	end if;
  end if;
end if;
end if;
end process SEND_UART;

RECV_UART: process(RST, mouse_clk_filter)
begin
if RST='1' then
	INCNT <= "0000";
    READ_CHAR <= '0';
	PACKET_COUNT <= "00";
    LB <= '0';
    RB <= '0';
	CHARIN <= "00000000";
elsif MOUSE_CLK_FILTER'event and MOUSE_CLK_FILTER='1' then
	if DATO_DIR='0' then
 		if PS2_DATA='0' and READ_CHAR='0' then
			READ_CHAR<= '1';
    		IREADY_SET<= '0';
 		else
		-- SHIFT IN NEXT SERIAL BIT
  		if READ_CHAR = '1' then
        	if INCNT < "1001" then
         		INCNT <= INCNT + 1;
         		SHIFTIN(7 downto 0) <= SHIFTIN(8 downto 1);
         		SHIFTIN(8) <= PS2_DATA;
	 			IREADY_SET <= '0';
		-- END OF CHARACTER
	 		else
	 			CHARIN <= SHIFTIN(7 downto 0);
     			READ_CHAR <= '0';
	 			IREADY_SET <= '1';
  	 			PACKET_COUNT <= PACKET_COUNT + 1;
		-- PACKET_COUNT = "00" IS ACK COMMAND
				if PACKET_COUNT = "00" then
		-- Set Cursor to middle of screen
				    cursor_column <= CONV_STD_LOGIC_VECTOR(320,10);
    				cursor_row <= CONV_STD_LOGIC_VECTOR(240,10);
				    NEW_cursor_column <= CONV_STD_LOGIC_VECTOR(320,10);
    				NEW_cursor_row <= CONV_STD_LOGIC_VECTOR(240,10);
				elsif PACKET_COUNT = "01" then
					PACKET_CHAR1 <= SHIFTIN(7 downto 0);
	-- Limit Cursor on Screen Edges	
	-- Check for left screen limit
	-- All numbers are positive only, and need to check for zero wrap around.
	-- Set limits higher since mouse can move up to 128 pixels in one packet
					if (cursor_row < 128) and ((NEW_cursor_row > 256) or (NEW_cursor_row < 2)) then
						cursor_row <= (others=>'0');
		
						-- Check for right screen limit
					elsif NEW_cursor_row > MAX_Y then
						cursor_row <= MAX_Y;
					else
						cursor_row <= NEW_cursor_row;
					end if;
			-- Check for top screen limit
					if (cursor_column < 128)  and ((NEW_cursor_column > 256)  or (NEW_cursor_column < 2)) then
						cursor_column <= (others=>'0');
			-- Check for bottom screen limit
					elsif NEW_cursor_column > MAX_X then
						cursor_column <= MAX_X;
					else
						cursor_column <= NEW_cursor_column;
					end if;
  				elsif PACKET_COUNT = "10" then
					PACKET_CHAR2 <= SHIFTIN(7 downto 0);
  				elsif PACKET_COUNT = "11" then
					PACKET_CHAR3 <= SHIFTIN(7 downto 0);
  				end if;
	 			INCNT <= (others=>'0');
  				if PACKET_COUNT = "11" then
    				PACKET_COUNT <= "01";
		-- Packet Complete, so process data in packet
		-- Sign extend X AND Y two's complement motion values and 
		-- add to Current Cursor Address
		--
		-- Y Motion is Negative since up is a lower row address
    				NEW_cursor_row <= cursor_row - (PACKET_CHAR3(7) & 
								PACKET_CHAR3(7) & PACKET_CHAR3);
    				NEW_cursor_column <= cursor_column + (PACKET_CHAR2(7) & 
								PACKET_CHAR2(7) & PACKET_CHAR2);
    				LB <= PACKET_CHAR1(0);
    				RB <= PACKET_CHAR1(1);
  				end if;
			end if;
  		end if;
 	end if;
 end if;
end if;
end process RECV_UART;

end behavior;
