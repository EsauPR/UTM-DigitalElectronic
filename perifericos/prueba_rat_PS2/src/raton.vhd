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
signal mouse_ste, mouse_ste_next			: state_type;
signal wait_counter	 						: std_logic_vector(10 DOWNTO 0);
signal CHARIN, CHAROUT						: std_logic_vector(7 DOWNTO 0);
signal new_cursor_row, new_cursor_column 	: std_logic_vector(9 DOWNTO 0);
signal cursor_row, cursor_column 			: std_logic_vector(9 DOWNTO 0);
signal INCNT, contador_envia, mSB_OUT 		: std_logic_vector(3 DOWNTO 0);
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

--La linea de de reloj del dipositivo PS2 es forzada a un estado logico bajo al menos 60uS 
-- para inhibir cualquier transmision

--Se envia el comando para inicializar el raton en modo Streaming mediante el comando F4
--  esto es, el raton enviará la informacion referente al movimiento
--  y estado de los botones en paquetes de 3 bytes


SECUENCIAL: process (CLK, RST)
begin		
 if RST = '1' THEN
	mouse_ste <= INHIBIT_TRANS;	
 elsif CLK'EVENT AND CLK = '1' THEN
	mouse_ste <= mouse_ste_next;
 end if;
end process SECUENCIAL;


COMBINACIONAL: process (mouse_ste, wait_counter, FIN_ENVIA, IREADY_SET)			 
begin
	CASE mouse_ste IS				
		
         WHEN INHIBIT_TRANS =>  
			HAB_ENVIA <= '0';	
				
			IF FIN_CONTADOR = '1' THEN
				mouse_ste_next <= LOAD_COMMAND;
			else
				mouse_ste_next <= INHIBIT_TRANS;
			END IF;
					-- Habilita el modo Streaming, comando F4
			charout <= "11110100";
			
		WHEN LOAD_COMMAND =>
			HAB_ENVIA <= '1';
			mouse_ste_next <= LOAD_COMMAND2;
		WHEN LOAD_COMMAND2 =>
			HAB_ENVIA <= '1';
			mouse_ste_next <= WAIT_OUTPUT_READY;
		-- Espera al Mouse para temporizar todos los bits en el comando
		-- El comando enviado es F4, Habilita el Modo Streaming
		
		WHEN WAIT_OUTPUT_READY =>
			HAB_ENVIA <= '0';
			-- Espera a que todos los datos sean temporizados con el registro de desplazamiento
			IF FIN_ENVIA='1' THEN
				mouse_ste_next <= WAIT_CMD_ACK;
			ELSE
				mouse_ste_next <= WAIT_OUTPUT_READY;
			END IF;
			
		-- Espera a que el mouse regrese el Comando de Reconocimiento, FA
		WHEN WAIT_CMD_ACK =>
			HAB_ENVIA <= '0';
			IF IREADY_SET='1' THEN
				mouse_ste_next <= INPUT_PACKETS;
			END IF;
			
		-- El mouse está inicializado, las lineas de datos y reloj se mantienen como entradas
		-- Mantiene al mouse en este estado, recibiendo paquetes de 3-bytes
		-- La razón por defecto es de 100 paquetes por segundo
		WHEN INPUT_PACKETS =>
			mouse_ste_next <= INPUT_PACKETS;
		END CASE;
		
END PROCESS COMBINACIONAL;	
--------------------------------------------


	WITH mouse_ste SELECT
-- Controla la dirección de la linea de Datos
		DATO_DIR 	<=	'0'	WHEN INHIBIT_TRANS,
							'0'	WHEN LOAD_COMMAND,
							'0'	WHEN LOAD_COMMAND2,
							'1'	WHEN WAIT_OUTPUT_READY,
							'0'	WHEN WAIT_CMD_ACK,
							'0'	WHEN INPUT_PACKETS;
-- Controla la dirección de la linea de Reloj
	WITH mouse_ste SELECT
		MOUSE_CLK_DIR 	<=	'1'	WHEN INHIBIT_TRANS,
							'1'	WHEN LOAD_COMMAND,
							'1'	WHEN LOAD_COMMAND2,
							'0'	WHEN WAIT_OUTPUT_READY,
							'0'	WHEN WAIT_CMD_ACK,
							'0'	WHEN INPUT_PACKETS;
	WITH mouse_ste SELECT
-- Se conecta con la línea de reloj del mouse, para la inicialización
		MOUSE_CLK_BUF 	<=	'0'	WHEN INHIBIT_TRANS,
							'1'	WHEN LOAD_COMMAND,
							'1'	WHEN LOAD_COMMAND2,
							'1'	WHEN WAIT_OUTPUT_READY,
							'1'	WHEN WAIT_CMD_ACK,
							'1'	WHEN INPUT_PACKETS;


-- Este proceso envía un dato serial por las líneas del mouse
	
SEND_SERIAL: process (HAB_ENVIA, Mouse_clK_filter)
variable contador_envia: STD_LOGIC_VECTOR (3 downto 0);
variable envia_cadena: STD_LOGIC;
variable cadena: STD_LOGIC_VECTOR(10 downto 0);
begin
	
if HAB_ENVIA = '1' then	  			-- Prepara el dato a enviar
	contador_envia := "0000";
    envia_cadena := '1';
	FIN_ENVIA <= '0';
	-- Bit de Inicio
	cadena(0) := '0';
	-- Bits con el comando (F4)
	cadena(8 downto 1) := CHAROUT ;
	-- Bit de paridad impar
	cadena(9) :=  not (charout(7) xor charout(6) xor charout(5) xor charout(4) xor
					   charout(3) xor charout(2) xor charout(1) xor charout(0));
	-- Bit de paro 
	cadena(10) := '1';
	-- Solicita al mouse temporizar la salida (además de ser un bit de inicio)
    DATO_SALIDA <= '0';

elsif(MOUSE_CLK_filter'event and MOUSE_CLK_filter='0') then
	if DATO_DIR='1' then				-- Asegura terminal como salida		
  		if envia_cadena = '1' then
		 -- Lazo para el registro de desplazamiento
          if contador_envia <= "1001" then
              contador_envia := contador_envia + 1;
			  -- Desplaza para el siguiente bit
              DATO_SALIDA <= cadena(1);
		      cadena(9 downto 0) := cadena(10 downto 1);
		      cadena(10) := '1';
		      FIN_ENVIA <= '0';
	       else							-- Finaliza el envío
     	      envia_cadena := '0';
		      FIN_ENVIA <= '1';	        -- Señaliza el fin de envío
		      contador_envia := "0000";
	       end if;
        end if;
     end if;
end if;
end process SEND_SERIAL;

RECV_SERIAL: process(RST, mouse_clk_filter)
begin
if RST='1' then											-- Preparado para recibir
	INCNT <= "0000";
    READ_CHAR <= '0';
	PACKET_COUNT <= "00";
    LB <= '0';
    RB <= '0';
	CHARIN <= "00000000";
elsif MOUSE_CLK_FILTER'event and MOUSE_CLK_FILTER='1' then	  	-- Evento en el reloj del mouse
	if DATO_DIR='0' then									  	-- Asegura terminal como entrada
 		if PS2_DATA='0' and READ_CHAR='0' then				  	-- Bit de inicio
			READ_CHAR<= '1';
    		IREADY_SET<= '0';
 		else
		
  		if READ_CHAR = '1' then								  	-- Bits de datos
        	if INCNT < "1001" then
         		INCNT <= INCNT + 1;
         		SHIFTIN(7 downto 0) <= SHIFTIN(8 downto 1);
         		SHIFTIN(8) <= PS2_DATA;
	 			IREADY_SET <= '0';
	 		else
	 			CHARIN <= SHIFTIN(7 downto 0);					-- Caracter listo
     			READ_CHAR <= '0';
	 			IREADY_SET <= '1';
  	 			PACKET_COUNT <= PACKET_COUNT + 1;
		
				if PACKET_COUNT = "00" then						-- Byte Inicial
				-- Ajusta el cursor al centro de la pantalla
				    cursor_column <= CONV_STD_LOGIC_VECTOR(320,10);
    				cursor_row <= CONV_STD_LOGIC_VECTOR(240,10);
				    NEW_cursor_column <= CONV_STD_LOGIC_VECTOR(320,10);
    				NEW_cursor_row <= CONV_STD_LOGIC_VECTOR(240,10);
				elsif PACKET_COUNT = "01" then				   -- Primer Byte del paquete
					PACKET_CHAR1 <= SHIFTIN(7 downto 0);
					-- Revisa los límites verticales del cursor en la pantalla
					-- Sólo se manejan numeros positivos
					-- El mouse no se puede mover más de 128 pixeles en un paquete
					-- Limite inferior: 
					if (cursor_row < 128) and ((NEW_cursor_row > 256) or (NEW_cursor_row < 2)) then
						cursor_row <= (others=>'0');
					-- Limite superior:
					elsif NEW_cursor_row > MAX_Y then
						cursor_row <= MAX_Y;
					else
						cursor_row <= NEW_cursor_row;
					end if;
					
					-- Revisa los límites horizontales del cursor en la pantalla
					-- Limite de la Izquierda
					if (cursor_column < 128)  and ((NEW_cursor_column > 256)  or (NEW_cursor_column < 2)) then
						cursor_column <= (others=>'0');
					-- Límite de la derecha
					elsif NEW_cursor_column > MAX_X then
						cursor_column <= MAX_X;
					else
						cursor_column <= NEW_cursor_column;
					end if;
  				elsif PACKET_COUNT = "10" then					   -- Segundo Byte del Paquete
					PACKET_CHAR2 <= SHIFTIN(7 downto 0);
  				elsif PACKET_COUNT = "11" then
					PACKET_CHAR3 <= SHIFTIN(7 downto 0);		   -- Tercer Byte del Paquete
  				end if;
	 			INCNT <= (others=>'0');
  				if PACKET_COUNT = "11" then		   					-- Con el paquete completo 
				-- Calcula la nueva posición vertical, extiende en signo y suma el desplazamiento 
				-- (resta por la dirección de crecimiento)
    				NEW_cursor_row <= cursor_row - (PACKET_CHAR3(7) & 
									  PACKET_CHAR3(7) & PACKET_CHAR3);
				-- Calcula la nueva posición horizontal, extiende en signo y suma el desplazamiento 	
    				NEW_cursor_column <= cursor_column + (PACKET_CHAR2(7) & 
					PACKET_CHAR2(7) & PACKET_CHAR2);
					
				-- Obtiene el estado de los botones
    				LB <= PACKET_CHAR1(0);
    				RB <= PACKET_CHAR1(1);
				
					PACKET_COUNT <= "01";					-- Obtendrá el byte 1 del nuevo paquete	
  				end if;
			end if;
  		end if;
 	end if;
 end if;
end if;
end process RECV_SERIAL;

end behavior;
