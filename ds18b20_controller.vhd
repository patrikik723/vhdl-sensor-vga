library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ds18b20_controller is
	port (
	clock : in std_logic;
	data_out : out std_logic_vector(11 downto 0);
	data : inout std_logic
	);
end ds18b20_controller;

	architecture Behavioral of ds18b20_controller is
			
	type state_type is (DELAY, RESET, SEND_COMMAND, READ_TIMESLOT, SKIP_ROM, CONVERT_T, READ_SCRATCHPAD, CONVERT_DELAY);
		signal current_state: state_type := RESET;
		signal data_senzor: std_logic_vector(71 downto 0) := (others => '0');
		
	begin
	process(clock) is

		variable i: integer range 0 to 35000000:= 0;
		variable read_sc : std_logic := '0'; 
		variable function_command : std_logic := '0';
		variable command : std_logic_vector(7 downto 0) := (others => '0');
		variable command_bit : integer range 0 to 10 := 0;
		variable read_bit : integer range 0 to 73 := 0;
		variable sensor_response 	: boolean := false;
		
	begin 
		if rising_edge(clock) then
		case current_state is 
		
			when DELAY => 
			
				if i > 30000000 then -- posilej data kazdych 30 sekund
					i := 0;
					current_state <= RESET;
				end if;
			
			when RESET =>
			
				if i = 1 then
					data <= '0';
				end if;
				
				if i = 500 then -- master	 stahne sbernici na 0 na minimalne 480 us
					data <= 'Z';
				end if;
				
				if i = 570 then -- zda se spravne navazala komunikace
				
					if data = '1' then
						sensor_response := false;
					else
						sensor_response := true;
					end if;
					
				end if;
				
				if i = 1000 then -- pak pullup na 15-60 us, pak na 60-240 log 0 od ds, nakonec se bus vytahne na 1, toto musi trvat min	 480 us 
				
					if sensor_response then
						current_state <= SKIP_ROM; -- po navazeni komunikace jdeme vzdy do skip_rom
					end if;
					i := 0;
					
				end if;
				
				
		when SEND_COMMAND =>
				
				if i = 1 then
					data <= 'Z';
				end if;
		
				if i = 3 then -- recovery ts je min 1 us
					data <= '0';
				end if;
				
				if i > 5 then -- pak bud uvolni sbernici nebo necha nulu
				
					if command_bit < 8 then -- 0 az 7
					
						if command(command_bit) = '1' then
							data <= 'Z'; -- pro 1 uvolni sbernici a pullup to hodi na 1
						else
							data <= '0'; -- pokud posila nulu, sbernice zustava na 0
						end if;
						
						if i = 64 then -- TIMESLOT MUSI MIT MIN 60 US
							i := 0;
							data <= 'Z';
							command_bit := command_bit + 1;
						end if;
						
					else
					
						i := 0;
						command_bit := 0;

						if command = "01000100" then -- skok na delay pro AD prevod teploty
									current_state <= CONVERT_DELAY;
									function_command := '0'; -- po convert to jde zpet do RESET, musime vynulovat function_command
						
						
						elsif function_command = '0' then -- jestli se predtim neposlal function_command, muzeme ho poslat
							if read_sc = '0' then -- jestli po ROM instrukci prijde CONVERT read_sc = 0 nebo READ read_sc = 1
								current_state <= CONVERT_T;
								read_sc := '1';
								function_command := '1';
							else 
								current_state <= READ_SCRATCHPAD; -- poslu command read_scratch
								read_sc := '0';
								function_command := '1';
							end if;
							
						elsif command = "10111110" then -- jestli prikaz byl READ_SCRATCHPAD, muzeme zacit cist TS
							current_state <= READ_TIMESLOT; 
							function_command := '0'; -- function_command probehl, musime ho ale vynulovat pro priste
							
						else
							current_state <= RESET;
							function_command := '0'; 
						end if;
					end if;
				end if;


		
		when SKIP_ROM =>
			if i = 1 then
				command := "11001100";
				current_state <= SEND_COMMAND; -- vzdy jdeme ze skip rom_rom do poslani commandu
				i := 0;
			end if;
		
		when CONVERT_T =>
			if i = 1 then
				command := "01000100";
				current_state <= SEND_COMMAND;
				i := 0;
			end if;
	
		when READ_SCRATCHPAD =>
			if i = 1 then
				command := "10111110";
				current_state <= SEND_COMMAND;
				i := 0;
			end if;
			
							
		when READ_TIMESLOT =>		-- stav pro cteni dat ze senzoru
			
			if i = 1 then
				data <= '0';
			end if;
			
			if i = 3 then
				data <= 'Z';
			end if;
			
			if i = 10 then -- po 10 us sample
			
				if read_bit < 72 then -- SLAVE posila 9 bytes, 72 bitů
				
					if data = '1' then 
						data_senzor(read_bit) <= '1';
					else 
						data_senzor(read_bit) <= '0';
					end if;
					
					read_bit := read_bit + 1;
					
				else
				
						i := 0;
						read_bit := 0;
						data_out(11 downto 0) <= std_logic_vector(data_senzor(11 downto 0)); -- bity pro teplotu 
						current_state <= DELAY;
						read_bit := 0;
						
				end if;
				
			end if;
				
			if i > 65 then -- Kazdy TS min 60 us
				i := 0;
			end if;
					
		when CONVERT_DELAY =>	-- stav pro prevod teploty
			
			if i = 750000 then
			
				current_state <= RESET;
				i := 0;
				
			end if;
		
		when others =>
		
			current_state <= RESET;
			
		end case;
				
				i := i + 1;
			
			end if;
		
	end process;

end Behavioral;