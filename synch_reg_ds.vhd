library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity synch_reg_ds is
port (clock1,clock2, reset : in std_logic;
		data_ds1 : in std_logic_vector(11 downto 0);
		data_ds2 : out std_logic_vector(11 downto 0);
		data_diff : out std_logic -- 1 = teplota roste | 0 = data klesaji
		);
end synch_reg_ds;

architecture Behavioral of synch_reg_ds is

	signal data_ds_reg : std_logic_vector(11 downto 0);
	signal new_data : std_logic := '0';
	signal data_diff_reg : std_logic := '0';
	
	-- funkce rostouci/klesajici templota
		function Compare(DataOld, DataNew : std_logic_vector(11 downto 0)) return std_logic is
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
				data_ds_reg <= (others => '0');
				new_data <= '0';
			else
				if data_ds1 /= data_ds_reg then
				
					data_diff_reg <= Compare(data_ds_reg, data_ds1);
					
					data_ds_reg <= data_ds1;
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
			else
				new_data_reg := new_data;
					if new_data_reg = '1' then
						
						data_diff <= data_diff_reg;
					
						data_ds2 <= data_ds_reg;
					end if;
			end if;
		end if;
			
	end process;

end Behavioral;