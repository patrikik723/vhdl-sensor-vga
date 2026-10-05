library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity synch_reg_dht is
port (clock1,clock2, reset : in std_logic;
		temp_dht1, hum_dht1 : in std_logic_vector(7 downto 0);
		temp_dht2, hum_dht2 : out std_logic_vector(7 downto 0);
		temp_diff, hum_diff : out std_logic
		);
end synch_reg_dht;

architecture Behavioral of synch_reg_dht is

	signal temp_dht_reg : std_logic_vector(7 downto 0);
	signal hum_dht_reg : std_logic_vector(7 downto 0);
	signal new_data : std_logic := '0';
	signal temp_diff_reg : std_logic;
	signal hum_diff_reg : std_logic;
	
	-- funkce rostouci/klesajici templota
		function Compare(DataOld, DataNew : std_logic_vector(7 downto 0)) return std_logic is
		begin
			if DataNew > DataOld then
				return '1';
			else
				return '0';
			end if;
		end function;

begin

	process(clock1) is
	begin
		if rising_edge(clock1) then
			if reset = '0' then
				temp_dht_reg <= (others => '0');
				hum_dht_reg <= (others => '0');
				new_data <= '0';
			else
					if temp_dht1 /= temp_dht_reg or hum_dht1 /= hum_dht_reg then
					
						temp_diff_reg <= Compare(temp_dht_reg, temp_dht1);
						hum_diff_reg <= Compare(hum_dht_reg, hum_dht1);
					
						temp_dht_reg <= temp_dht1;
						hum_dht_reg <= hum_dht1;
						new_data <= '1';
					else
						new_data <= '0';
					end if;	
				end if;
		end if;
			
	end process;
	
	process(clock2) is
		variable new_data_reg : std_logic := '0';
	begin
		if rising_edge(clock2) then
			if reset = '0' then
					new_data_reg := '0';
					temp_dht2 <= (others => '0');
					hum_dht2 <= (others => '0');
			else
					new_data_reg := new_data;
					
					if new_data_reg = '1' then
					
						temp_diff <= temp_diff_reg;
						hum_diff <= hum_diff_reg;
					
						temp_dht2 <= temp_dht_reg;
						hum_dht2 <= hum_dht_reg;
					end if;
			end if;
		end if;
			
	end process;

end Behavioral;