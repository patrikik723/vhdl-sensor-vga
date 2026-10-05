library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
generic (konec_linky : integer :=799); 
port (clock,reset : in std_logic;
		prenos : out std_logic;
		stav : buffer integer
	);
end counter;

architecture Behavioral of counter is
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '0' then
                -- Synchronní reset
                stav <= 0;
                prenos <= '0';
            elsif stav = konec_linky then
                -- Přetečení čítače
                stav <= 0;
                prenos <= '1';
            else
                -- Inkrementace čítače
                stav <= stav + 1;
                prenos <= '0';
            end if;
        end if;
    end process;
end Behavioral;