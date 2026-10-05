library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity dht11_controller is
	port ( clock : in std_logic;
			temperature_out: out std_logic_vector(7 downto 0);
			humidity_out: out std_logic_vector(7 downto 0); 
			data: inout std_logic
			);
end dht11_controller;

architecture Behavioral of dht11_controller is

type state_type is (DELAY,HOST_START, SLAVE_RESPONSE, DATA_SEND, FINISH);
signal current_state: state_type := HOST_START;
signal data_senzor: std_logic_vector(39 downto 0) := (others => '0')	;

begin
process(clock) is

	variable i: integer range 0 to 31000000 := 0;
	variable previous_voltage : std_logic := '0';
	variable data_bit: integer range -1 to 39 := 39;
	variable checksum : std_logic_vector(7 downto 0) := (others => '0')	; 
	
begin
	if rising_edge(clock) then
	case current_state is	
		
		when DELAY =>	-- posilej data kazdych 30 sekund
			if i > 30000000 then
				i := 0;
				data_bit := 39;
				current_state <= HOST_START;
			end if;
			
		when HOST_START =>	
		
					if i = 1 then 
						data <= '0';
					end if;
					
					if i > 18000 then -- senzor stahne na 18ms data pin na 0
						i := 0;
						current_state <= SLAVE_RESPONSE;
						data <= 'Z'; -- nastavi stav vysoke impedance pro komunikaci
					end if;
		
		when SLAVE_RESPONSE => -- odpoved senzoru, 80us na 0, 80us na 1. Pokud je 90 us, urcite je to v 1, po ktere prijde 0 pred prvnim bitem
					if i > 90 then
						if data = '0' then -- prvni start vyhodnocovaci pulz
							current_state <= DATA_SEND; 
							previous_voltage := '0';
							i := 0;
					   end if;
					end if;
					
		when DATA_SEND =>
			  if data_bit = -1 then
					current_state <= FINISH;
					i := 0;

			  elsif data = '0' then
					if previous_voltage = '1' then -- pokud minuly stav byl log 1, ale ted je 0, tak muzeme vyhodnotit delku pulzu
						 -- ulozeni bitu podle delky HIGH pulzu
						 if i > 50 then
							  data_senzor(data_bit+1) <= '1'; -- data_bit = 39, potrebujeme to ulozit na 40. misto, atd.
						 else
							  data_senzor(data_bit+1) <= '0';
						 end if;
						 
						 -- posun na dalsi bit
						 data_bit := data_bit - 1;
					end if;
					i := 0;
					previous_voltage := '0';

			  elsif data = '1' then  -- v logicke jednicce citac cita delku pulzu
					previous_voltage := '1';
			  end if;
	
		when FINISH =>
						-- kontrola parity, podku plati, tak tak odesli namerena data na vzsrup
					if data_senzor(7 downto 0) = (data_senzor(39 downto 32) + data_senzor(31 downto 24) + data_senzor(23 downto 16) + data_senzor(15 downto 8)) then
						humidity_out <= std_logic_vector(data_senzor(39 downto 32));
						temperature_out <= std_logic_vector(data_senzor(23 downto 16));
						
						
					end if;
					
				if i > 300 then -- pockej chcvili po odeslani
					current_state <= Delay;
				end if;
				
		when others =>
			current_state <= HOST_START;
			
	end case;
	
		
	i:= i+1;
	
end if;
end process;
end Behavioral;