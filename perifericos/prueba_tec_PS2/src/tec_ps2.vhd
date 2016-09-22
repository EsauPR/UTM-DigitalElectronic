

library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Teclado is
	generic(	
		FREC: 	natural := 50_000 -- FREC. DE OPERACION DEL RELOJ PRINCIPAL
	);	
	port(		
		clk:	  in  STD_LOGIC;	-- Reloj principal
		reset:	  in  STD_LOGIC;	-- Reset	asincrono
		tec_clk:  inout STD_LOGIC;	-- Linea de Reloj del teclado
		Dato_ps:  inout STD_LOGIC;	-- Linea de Datos del teclado
		ERROR:	  out STD_LOGIC;	-- Indicador de Error				
		CR_Listo: out STD_LOGIC;	-- Indicador de Codigo_Rastreo listo		
		Codigo_Rastreo:  out STD_LOGIC_VECTOR(7 downto 0);	-- Codigo de Rastreo capturado
		CNS:  	         out STD_LOGIC_VECTOR(2 downto 0)	-- Indicadores de LED en el teclado						
	);
end entity;
  
architecture arch of Teclado is

--	MAQUINA DE ESTADOS DEL TECLADO DE PARA LA RECEPCION Y ENVIO DE DATOS
type ME_TECLADO is (
	INICIAL, 	-- Revisa si se ha recibido bit de inicio o se desea enviar una orden
	DATO0, 		-- Guarda bit de inicio en la recepcion
	DATO_y_PARIDAD, -- Guarda el dato enviado por el teclado y el bit de paridad	
	PARO, 	 		 -- Guarda el bit de paro enviado por el teclado
	PETICION_PARA_ENVIAR, --Aplica un nivel logico bajo a la senal de reloj del teclado	
	LIBRERA_TEC_CLK,	-- Libera la senal de reloj del teclado y envia bit de inicio
	DATO_ORDEN, 		-- Envia orden al teclado
	PARIDAD_ORDEN, 	-- Envia bit de paridad al teclado
	ACK					-- Envia bit de paro al teclado y espera bit de reconocimiento
);

signal Edo_act, Edo_sig: ME_TECLADO;

--	Indicadores de Tecla presionada
signal Tecla_Presionada:	STD_LOGIC;	-- Indicador de tecla presionada
signal Tecla_Liberada:  	STD_LOGIC;

--	Senales del Codigo de Rastreo
signal CR_DETECTADO:  		STD_LOGIC; 	-- Indica que se recibio un Codigo Rastreo (CR) del teclado
signal CR_DETECTADO_SIG: 	STD_LOGIC;	
signal CR:	 		 STD_LOGIC_VECTOR(10 downto 0);	-- Registro para almacenar el Codigo de Rastreo
signal CR_Int_Sig: STD_LOGIC_VECTOR(10 downto 0);	
signal Codigo_Rastreo_LISTO:  STD_LOGIC;	-- Indica que se tiene el Codigo de Rastreo listo

-- PARIDAD 
signal inicializa_paridad:  STD_LOGIC;	-- Inicializa Paridad a '1'
signal paridad_obtenida:  STD_LOGIC;	-- paridad calculada
signal bit_paridad:  STD_LOGIC;			-- bit para obtener paridad
signal ERROR_SIG:  STD_LOGIC;				-- Indicador de error

-- SENALES AUXILIARES DE RELOJ Y DATO DE TECLADO
signal Reloj_Teclado:  		STD_LOGIC;	--Reloj ps2 Interno
signal Reloj_Teclado_sig:	STD_LOGIC;	
signal Dato_Teclado: 		STD_LOGIC;	--Dato  ps2 Interno
signal Dato_Teclado_sig: 	STD_LOGIC;	

-- CONTADOR MODULO 8
constant	maximo:   	NATURAL := 7;	
subtype	contador is NATURAL range 0 to maximo;
signal 	cntr: 	 contador;
signal 	cuenta: 	 STD_LOGIC;

-- RETARDO 100US ANTES DE ENVIAR LA ORDEN
signal Retardo:  		STD_LOGIC;				-- Indicador de que se realice un retardo
signal Retardo_sig:  STD_LOGIC;
signal Realiza_conteo_Retardo: STD_LOGIC; -- Mantiene el retardo
signal Fin_Retardo:  STD_LOGIC;				-- Indica que se ha efectuado el retardo
signal cntr_Retardo: STD_LOGIC_VECTOR (12 downto 0);	-- Contador 
constant max_retardo: 	NATURAL:=FREC/10;	-- Frecuencia de reloj/10 [Khz]

-- ORDENES AL TECLADO
signal ORDEN: STD_LOGIC_VECTOR (7 downto 0);  	-- Orden a enviar
signal Enviar_Orden:  STD_LOGIC;	  		-- Indica que se envie una orden al teclado
signal AUXILIAR: STD_LOGIC_VECTOR(7 DOWNTO 0);	-- Registro auxiliar en el proceso de envio de ordenes

constant RESET_PS2: STD_LOGIC_VECTOR(7 downto 0) := "11111111"; -- 0xFF orden de reset al teclado
constant SR_LEDS:   STD_LOGIC_VECTOR(7 downto 0) := "11101101"; -- 0xED orden de encendido/apagado de LEDs
constant SSCS: 	  STD_LOGIC_VECTOR(7 downto 0) := "11110000"; -- 0xFO orden para establecer el conjunto de codigos de rastreo
constant SCS3: 	  STD_LOGIC_VECTOR(7 downto 0) := "00000011"; -- 0x03 orden que programa el conj. de codigos de rastreo 3

-- constantes utiles  
constant OK: 			STD_LOGIC_VECTOR(7 downto 0)	:=	"10101010";	-- 0xAA prueba del teclado exitosa
constant NOK: 			STD_LOGIC_VECTOR(7 downto 0)	:=	"11111100";	-- 0xFC fallo en prueba del teclado
constant ACK_T: 		STD_LOGIC_VECTOR(7 downto 0)	:=	"11111010";	-- 0xFA byte de reconicimiento
constant F0: 			STD_LOGIC_VECTOR(7 downto 0)	:=  "11110000"; -- Primer byte del codigo de liberacion 

-- Indicadores 
constant CAPS:		STD_LOGIC_VECTOR(7 downto 0)	:=	"00010100";	--	Codigo de rastreo de tecla Bloq Mayus
constant NUM: 		STD_LOGIC_VECTOR(7 downto 0)	:=	"01110110";	-- Codigo de rastreo de tecla Bloq Num
constant SCROLL: 	STD_LOGIC_VECTOR(7 downto 0)	:=	"01011111";	-- Codigo de rastreo de tecla Bloq Desp
signal   LEDS:      STD_LOGIC_VECTOR(2 DOWNTO 0);    -- Señal con el estado de los LEDS

--	DETECCION DE FLANCOS
signal TEC_CLK2:   STD_LOGIC; -- Senal de reloj de teclado 
signal Flanco_act: STD_LOGIC;
signal flanco_sig: STD_LOGIC;
signal Flanco_Bajada_Clk_Tec: 	 STD_LOGIC;

	type ME_DF is (	--Maquina de estados de deteccion de flancos de bajada de la senal de reloj
		ESPERA_TECLK_BAJO, -- Espera a que la senal de reloj pase de nivel logico alto a bajo
		ESPERA_TECLK_ALTO  -- Espera a que la senal de reloj pase de nivel logico bajo a alto
	);

signal Edo_act_DF, Edo_sig_DF: ME_DF;

begin
   
	---------------------------------------------------------------------------------------------
	--					ENTRADAS/SALIDAS DE LAS LINEAS DE DATOS Y RELOJ DEL TECLADO
	---------------------------------------------------------------------------------------------
	TECA:
	tec_clk		<= 'Z' when Reloj_Teclado  = '1' else '0';  	
	dato_Ps		<= 'Z' when Dato_Teclado   = '1' else '0';

	---------------------------------------------------------------------------------------------
	--					SALIDAS DE CODIGO DE RASTREO DEL MODULO
	---------------------------------------------------------------------------------------------
	TECB:
	CR_Listo		<= Codigo_Rastreo_LISTO;	-- Indica que el Codigo de Rastreo esta LISTO								
	Codigo_Rastreo 	<= CR(8 downto 1);			-- Codigo de Rastreo de Salida
	---------------------------------------------------------------------------------
	------------	DETECTA FLANCOS DE BAJADA DEL RELOJ DE TECLADO			------------
	---------------------------------------------------------------------------------
	TEC1:	process (edo_act_DF, TEC_CLK2)
	begin
		--Flanco_Sig <= '0';		
		--edo_sig_DF		<=	edo_act_DF;
		case Edo_act_DF is
			when ESPERA_TECLK_BAJO =>		--Espera a que la senal pase a nivel logico bajo
				if TEC_CLK2 ='0' then			
					Flanco_Sig <= '1';		-- Indicador de flanco de bajada detectado
					edo_sig_DF <= ESPERA_TECLK_ALTO;
				else
					Flanco_Sig <= '0';		-- Indicador de flanco de bajada detectado
					edo_sig_DF <= ESPERA_TECLK_BAJO;
				end if;
			when ESPERA_TECLK_ALTO =>		--Espera a que la senal pase a nivel logico bajo
				Flanco_Sig <= '0';
				if TEC_CLK2 ='1' then
					edo_sig_DF		<=	ESPERA_TECLK_BAJO;
				else
					edo_sig_DF <= ESPERA_TECLK_ALTO;
				end if;
			when others=>edo_sig_DF<=	ESPERA_TECLK_BAJO;
		end case;
	end process;
	
	TEC1B:	process (clk, reset) --Actualiza la maquina de estados detectora de flancos
	begin
		if reset = '1' then
			TEC_CLK2			  <= '1';				
			edo_act_DF			  <= ESPERA_TECLK_BAJO;
			Flanco_Bajada_Clk_Tec <= '0';			
		elsif clk'EVENT and clk = '1' then
			TEC_CLK2		<=	TEC_CLK;		
			edo_act_DF	<=	edo_sig_DF;
			Flanco_Bajada_Clk_Tec <= Flanco_sig; --Indicador de que se ha detectado un flaco de bajada
		end if;		
	end process;
	---------------------------------------------------------------------------------------------
	--											CONTADOR MOD 8		
	---------------------------------------------------------------------------------------------
	TEC2:	process (reset, clk)
	begin
		if reset = '1' then	-- limpia el valor en reset
			cntr<=0;
		elsif clk'EVENT and clk = '1' then
			if cuenta = '1' then 
				cntr<=cntr+1;	-- Incrementa el valor en 1
			end if;
		end if;
	end process;
	---------------------------------------------------------------------------------------------
	--									OBTIENE LA PARIDAD DEL DATO
	---------------------------------------------------------------------------------------------
	TEC3:	process (inicializa_paridad,clk)
	begin
		if inicializa_paridad = '1' then	 -- inicializa la paridad a 1
			paridad_obtenida <= '1';
		elsif  clk'EVENT AND clk = '1' then
			if bit_paridad='1' then 	--	Si se tiene un bit 1 en el dato
				paridad_obtenida <= NOT paridad_obtenida; -- niega el bit de paridad para los bits 1
			end if;
		end if;
	end process;	
   ---------------------------------------------------------------------------------------------
	--								REALIZA UN CONTEO PARA OBTENER 100 us
	---------------------------------------------------------------------------------------------
	TEC4:	process (Reset, clk)
	begin
		if Reset='1' then
			Fin_Retardo	 <= '0';	
			cntr_Retardo <= (others=>'0');
			Realiza_conteo_retardo <='0';			
		elsif clk'EVENT and clk = '1' then			
			Fin_Retardo	 <= '0';	
			if Retardo='1' then  --Si se desea obtener un conteo de 100us
				Realiza_conteo_retardo <='1';
			elsif Realiza_conteo_retardo ='1' then	
				if cntr_Retardo < max_retardo then	--si no ha llegado al valor maximo	
					cntr_Retardo <= cntr_Retardo + '1'; --incrementa en 1 al contador
				else								--si llego al maximo conteo...
					Realiza_conteo_retardo <='0';  --Inicializa senal
					cntr_Retardo <= (others=>'0'); --Inicializa contador
					Fin_Retardo	 <= '1';	-- Habilita esta senal por un ciclo de reloj principal
				end if;						
			end if;	
		end if;
	end process;
	
	---------------------------------------------------------------------------------
	------------		ENVIO Y RECEPCION DE DATOS DEL TECLADO 				------------
	---------------------------------------------------------------------------------
	TEC5:	process (Flanco_Bajada_Clk_Tec, dato_ps, edo_act,paridad_obtenida,CR,cntr, 
			Enviar_Orden,ORDEN,Fin_Retardo)
	begin
		CR_Int_Sig		<=	CR;	-- El CR siguiente es igual al anterior	
		CUENTA			<=	'0';	-- No incrementa al contador modulo 8			
		Retardo_sig  	<=	'0'; 	-- No inicia el contador para el retardo
		bit_paridad		<=	'0';	-- No hay bit de paridad a calcular
		ERROR_SIG		<=	'0';	-- No hay error
		inicializa_paridad<=	'0';	-- No inicializa paridad
		CR_DETECTADO_SIG	<=	'0';	-- No se ha recibido el CR
		Dato_Teclado_sig 	<= '1'; 	-- Linea de datos en triestado
		Reloj_Teclado_sig <= '1';  -- Linea de reloj en triestado
		edo_sig			   <=	edo_act; 
	
		case edo_act is		
			WHEN INICIAL =>
				if (Flanco_Bajada_Clk_Tec and NOT dato_ps) = '1' then	-- Si hay un flanco de bajada y hay bit de inicio
					inicializa_paridad	<='1';		-- Inicializa bit de paridad
					CR_Int_Sig(0)			<= dato_ps; -- Almacena el bit recibido 
					edo_sig  				<= DATO0;					
				elsif Enviar_Orden = '1' then  -- Si hay una orden lista a enviar al teclado...
					inicializa_paridad	<=	'1';	-- Inicializa bit de paridad				
					Retardo_sig  			<= '1'; 	-- Inicio de retardo para la peticion para enviar
					Reloj_Teclado_sig		<= '0';	-- senal de reloj en bajo
					Edo_Sig 					<= PETICION_PARA_ENVIAR;
			end if;   											
			
			---------------------------------------------------------------		
			----------------	RECEPCION DE DATOS DEL TECLADO
			---------------------------------------------------------------				
			WHEN DATO0 =>	--Obtiene el 1er bit de datos
				if Flanco_Bajada_Clk_Tec = '1'  then	-- Si hay al flanco de bajada del reloj de teclado
					CR_Int_Sig(1)	<=	dato_ps;				-- Guarda el bit
					bit_paridad		<=	dato_ps;				-- Calcula la paridad
					edo_sig 			<= DATO_y_PARIDAD;  
				end if;

			WHEN DATO_y_PARIDAD =>	--Obtiene los 7 bits restantes y el bit de paridad
				if Flanco_Bajada_Clk_Tec = '1' then
					if cntr < 7 then 				-- Si todavia no llega a 8 bits de datos capturados					
						Cuenta 				<= '1';	-- Mantiene activo conteo mod 8
						CR_Int_Sig(cntr+2)<= dato_ps;
						bit_paridad			<=	dato_ps;					
 					else
						Cuenta 	<= '1';			-- Sobreflujo del contador
						if dato_ps/=paridad_obtenida then -- Si no coinciden la paridad del dato recibida y la calculada...
							error_SIG	<='1';
						end if;
						CR_Int_Sig(9) 	<= dato_ps;	-- Recibe Bit de PARIDAD de linea de datos del teclado
						Edo_Sig 			<= PARO;
					end if;
				end if;					
		
			WHEN PARO =>		
				if Flanco_Bajada_Clk_Tec = '1' then
					CR_DETECTADO_SIG	<=	'1';				
					CR_Int_Sig(10)		<=	dato_ps;		-- Recibe Bit de PARO
					error_SIG			<=	NOT dato_ps;-- Error su el Bit de PARO es 0
					edo_sig 				<= INICIAL;		-- Regresa al estado INICIAL
				end if;				
		
			---------------------------------------------------------------		
			--------------	ENVIO DE ORDENES AL TECLADO
			---------------------------------------------------------------				
			-- Mantiene la senal de reloj ps2 y la linea de datos por lo menos 100us, y
			-- configura el 1er bit de datos
  			WHEN PETICION_PARA_ENVIAR => 	-- Espera 100us
				if Fin_Retardo = '0' then
  					Reloj_Teclado_sig <= '0'; 					--	Mantiene senal de reloj en bajo
  				else  					
  					Edo_Sig 				<= LIBRERA_TEC_CLK;	-- Libera la senal de reloj
  				end if; 	

  			WHEN LIBRERA_TEC_CLK => 	 
				if Flanco_Bajada_Clk_Tec= '0' then  	
					Dato_Teclado_sig 	<= '0'; -- Pone bit de inicio y espera al flanco de bajada
  					Edo_Sig 				<= LIBRERA_TEC_CLK;	-- Libera la senal de reloj		
  				else 
					bit_paridad 		<= ORDEN(cntr);
					Dato_Teclado_sig 	<= ORDEN(cntr); -- 1er Bit de datos (LSB)					  				
					edo_sig 				<= DATO_ORDEN;
				end if;  			
				  				
			WHEN DATO_ORDEN =>			
				if Flanco_Bajada_Clk_Tec= '0' then							
					Dato_Teclado_sig	<= ORDEN(cntr);
				elsif cntr<7 THEN
					Cuenta 				<= '1';			
					bit_paridad 		<= ORDEN(CNTR+1);
					Dato_Teclado_sig 	<= ORDEN(CNTR+1);
 				else 					-- Si se envio el 8vo bit 
					Cuenta 				<= '1';	-- Suma 1 para que haya sobreflujo del contador
					Dato_Teclado_sig 	<=	paridad_obtenida;	-- Envia Bit de paridad al teclado
					edo_sig 				<= PARIDAD_ORDEN;		  								
				end if;			

			WHEN PARIDAD_ORDEN =>
				if Flanco_Bajada_Clk_Tec= '0' then  
  					Dato_Teclado_sig 	<= paridad_obtenida;
				else	
  					Dato_Teclado_sig 	<= '1'; -- Crea bit de paro 
  					Edo_Sig	 			<= ACK;
  				end if;  				
		
   			WHEN ACK =>
				if Flanco_Bajada_Clk_Tec = '0' then  
	 					Dato_Teclado_sig 	<= '1';
   					Edo_Sig 				<= ACK;
   				else		
   					Error_Sig	<= dato_Ps; --Error si recibe 1
   					Edo_Sig 		<= INICIAL;
   			end if;
  			WHEN OTHERS => edo_sig <= INICIAL; 	   		
  		end case;  
	end process;
	
	TEC5B:	process (reset, clk) 	----	ACTUALIZACION DE SENALES Y ESTADOS 
	begin
		if reset = '1' then			
			edo_act 			<= INICIAL;		--	Edo. INICIAL
			Dato_Teclado	<= '1';			--	Pone la linea de datos en triestado
			Reloj_Teclado 	<= '1';			--	Pone la linea de relon en triestado
			CR					<=	(others=>'0'); -- Inializa Codigo_Rastreo a 0's
		elsif clk'EVENT AND clk = '1' then	
			edo_act 			<= edo_sig;		
			Dato_Teclado	<= Dato_Teclado_sig;
			Reloj_Teclado 	<= Reloj_Teclado_sig;
			CR					<=	CR_Int_Sig;				
			CR_DETECTADO	<=	CR_DETECTADO_SIG;		
			RETARDO			<=	RETARDO_SIG;
			ERROR				<=	ERROR_SIG;	
		end if;
	end process;	

	----------------------------------------------------------------------------------------------------------------
	--	DETECTA LA TECLA SOLO CUANDO SE PRESIONA UNA VEZ O SE MANTIENE PRESIONADA 
	-- (Es decir, desecha el codigo de liberacion)
	----------------------------------------------------------------------------------------------------------------
	TEC6:	process(clk, reset)	
	begin
		if reset='1' then 
			Tecla_Presionada 	<= '0';	-- Por defecto, no hay datos recibidos
			Tecla_Liberada 	<= '0';		
		elsif clk'event and clk = '1' then
			Tecla_Presionada <= '0';	-- Inicializa indicador de codigo de rastreo (CR)
			if CR_DETECTADO= '1' then		 -- Si se detecta un CR
				Tecla_Presionada <= '1';	 -- Indica que se esta presionando la tecla
				if CR(8 downto 1) = F0 then -- Si detecta que el CR es un el 1er byte del codigo de liberacion...
					Tecla_Presionada 	<= '0';	-- No esta listo el CR de salida
					Tecla_Liberada 	<= '1';	-- Activa senal a '1' para esperar el 2o byte del codigo de liberacion
				elsif Tecla_Liberada = '1' then 	-- Si despues de F0 se recibe el siguiente CR...
					Tecla_Presionada 	<= '0';		-- No se toma en cuenta ese CR
					Tecla_Liberada 	<= '0';		-- No se ha liberado la tecla
				end if;
			end if;
		end if;
	end process;	
	--------------------------------------------------------------------------------
	--		ASIGNA LOS ORDENES A ENVIAR
	--------------------------------------------------------------------------------
	TEC7:	process(clk, reset)
	variable LEDS_var: STD_LOGIC_VECTOR(2 downto 0);
	begin
		if reset='1' then
			Codigo_Rastreo_LISTO	<=	'0'; 	-- No hay CR (codigo de rastreo) listo
			Enviar_ORDEN			<=	'1';	--	Indicacion de que se envie la orden de reset de teclado
			LEDS 	<=(OTHERS =>'0');			-- Leds apagados			
			ORDEN	<=	RESET_PS2;				-- Orden de reset
		elsif clk'event and clk='1' then 
			Codigo_Rastreo_LISTO	<=	'0';	--	No hay CR listo 
			Enviar_ORDEN			<=	'0';	-- Deshabilita la indicacion de envio de orden
			if (error_sig = '1') then		--	Si hay un error, aplica reset al teclado
				LEDS				<=	(OTHERS =>'0');
				Enviar_ORDEN	<=	'1';
				ORDEN				<=	RESET_PS2; 
			end if;

			IF Tecla_Presionada ='1' THEN -- Si aparece un CR de teclado
				CASE CR (8 DOWNTO 1) IS		
					WHEN OK | NOK => 			-- AA prueba exitosa de reset o FC (no exitosa al conectar mal el teclado)
						LEDS			 <= (OTHERS =>'0');
						ORDEN			 <= SSCS; -- orden de asignacion del conjunto de codigos de rastreo (Set Scan Code Set)
	 				   Enviar_ORDEN <= '1';
	 					AUXILIAR		 <= "00000010"; -- Guarda byte 0x02 que indicara la accion a realizar despues de la orden SSCS
					WHEN CAPS | NUM | SCROLL =>	-- Si es SCROLL, NUM o CAPS...
						ORDEN				<=	SR_LEDS;		-- Orden para encender/apagar los LEDS
	 					Enviar_ORDEN	<=	'1';			-- Indica que se envie la orden
	 					AUXILIAR		<=	CR(8 downto 1);-- Guarda CR
					WHEN ACK_T => 	-- Byte de reconocimiento del teclado
						AUXILIAR	<=	(others=>'1');	--Incializa AUXILIAR para que en sig. ciclo entre a others del case
						LEDS_var := LEDS;
						IF AUXILIAR=CAPS THEN
							LEDS_var(2):=NOT LEDS_var(2); ORDEN<="00000"& LEDS_var; Enviar_ORDEN<='1';
						ELSIF AUXILIAR=NUM THEN 
						   LEDS_var(1):=NOT LEDS_var(1); ORDEN<="00000"& LEDS_var; Enviar_ORDEN<='1';
						ELSIF AUXILIAR=SCROLL THEN 
							LEDS_var(0):=NOT LEDS_var(0); ORDEN<="00000"& LEDS_var; Enviar_ORDEN<='1';
						ELSIF AUXILIAR="00000010" THEN -- Despues del reset y de la orden el SSCS...
								Enviar_ORDEN <='1';
								ORDEN			 <=	SCS3;  -- Orden de asignar el conjunto de codigos de rastreo 3
						END IF;
						LEDS <= LEDS_var;
					WHEN OTHERS =>	Codigo_Rastreo_LISTO<='1';	-- Activa la bandera de CR listo
				END CASE;			
			END IF;		
			CNS	<=	LEDS;		-- LEDS enciendios/apadados de Mayusculas, Bloq Num y Bloq Despl
		END IF;
	END PROCESS;						 

end architecture;
