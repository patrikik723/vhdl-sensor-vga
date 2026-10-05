library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_to_text_ds is
    port (
        clock           : in std_logic;
        reset           : in std_logic;
		  data : in std_logic_vector(11 downto 0); 
        addr_out        : out std_logic_vector(4 downto 0)
    );
end data_to_text_ds;

architecture Behavioral of data_to_text_ds is

    -- Definice adresaci pro znaky do rom
    constant ADDR_T       : std_logic_vector(4 downto 0) := "00000"; -- 'T'
    constant ADDR_E       : std_logic_vector(4 downto 0) := "00001"; -- 'E'
    constant ADDR_P       : std_logic_vector(4 downto 0) := "00010"; -- 'P'
    constant ADDR_L       : std_logic_vector(4 downto 0) := "00011"; -- 'L'
    constant ADDR_O       : std_logic_vector(4 downto 0) := "00100"; -- 'O'
    constant ADDR_A       : std_logic_vector(4 downto 0) := "00101"; -- 'A'
    constant ADDR_DEGREE  : std_logic_vector(4 downto 0) := "00110"; -- '°'
    constant ADDR_C       : std_logic_vector(4 downto 0) := "00111"; -- 'C'
    constant ADDR_V       : std_logic_vector(4 downto 0) := "01000"; -- 'V'
    constant ADDR_H       : std_logic_vector(4 downto 0) := "01001"; -- 'H'
    constant ADDR_K       : std_logic_vector(4 downto 0) := "01010"; -- 'K'
    constant ADDR_S       : std_logic_vector(4 downto 0) := "01011"; -- 'S'
    constant ADDR_PERCENT : std_logic_vector(4 downto 0) := "01100"; -- '%'
    constant ADDR_0       : std_logic_vector(4 downto 0) := "01101"; -- '0'
    constant ADDR_1       : std_logic_vector(4 downto 0) := "01110"; -- '1'
    constant ADDR_2       : std_logic_vector(4 downto 0) := "01111"; -- '2'
    constant ADDR_3       : std_logic_vector(4 downto 0) := "10000"; -- '3'
    constant ADDR_4       : std_logic_vector(4 downto 0) := "10001"; -- '4'
    constant ADDR_5       : std_logic_vector(4 downto 0) := "10010"; -- '5'
    constant ADDR_6       : std_logic_vector(4 downto 0) := "10011"; -- '6'
    constant ADDR_7       : std_logic_vector(4 downto 0) := "10100"; -- '7'
    constant ADDR_8       : std_logic_vector(4 downto 0) := "10101"; -- '8'
    constant ADDR_9       : std_logic_vector(4 downto 0) := "10110"; -- '9'
    constant ADDR_SPACE   : std_logic_vector(4 downto 0) := "10111"; -- ' '
    constant ADDR_COMMA   : std_logic_vector(4 downto 0) := "11000"; -- ','
	 
	 -- Funkce pro převod číslic na adresy adresy
    function digit_to_ascii(digit : integer range 0 to 9) return std_logic_vector is
    begin
        case digit is
            when 0 => return ADDR_0;
            when 1 => return ADDR_1;
            when 2 => return ADDR_2;
            when 3 => return ADDR_3;
            when 4 => return ADDR_4;
            when 5 => return ADDR_5;
            when 6 => return ADDR_6;
            when 7 => return ADDR_7;
            when 8 => return ADDR_8;
            when 9 => return ADDR_9;
            when others => return ADDR_SPACE; -- Defaultní hodnota
        end case;
    end function;


    -- Signály

    signal row_counter  : integer range 0 to 7 := 7;

begin

    process(clock)
	 
		variable char_counter : integer range 0 to 31 := 0; 
		
		variable temp_data_var : integer range 0 to 60; -- max teplota pro DS18B20 je 60
		variable temp_frac_var : integer range 0 to 99;
		
		variable temp_data_dig1 : integer range 0 to 9;
		variable temp_data_dig2 : integer range 0 to 9; 	
		variable temp_frac_dig1 : integer range 0 to 9;
		variable temp_frac_dig2 : integer range 0 to 9;
		
		variable fraction_int : integer range 0 to 15;
	
		
    begin
        if rising_edge(clock) then
            if reset = '0' then
                char_counter := 0;
                row_counter <= 7;
                addr_out <= ADDR_SPACE;
					 
            else
					
						 temp_data_var := to_integer(unsigned(data(11 downto 4)));

						 fraction_int := to_integer(unsigned(data(3 downto 0)));
						 temp_frac_var := (fraction_int * 625) / 100;  -- Vypocet desetinne hodnoty podle datasheetu
						 
						 temp_data_dig1 := temp_data_var / 10;
						 temp_data_dig2 := temp_data_var mod 10;
						 temp_frac_dig1 := temp_frac_var / 10;
						 temp_frac_dig2 := temp_frac_var mod 10;
												
							 -- Počítání řádků (0 až 7)
							  if row_counter = 7 then
									row_counter <= 0;

									  -- Generování adres pro ROM podle čítače znaků
									  case char_counter is
											-- "TEPLOTA "
											when 0 => addr_out <= ADDR_T;
											when 1 => addr_out <= ADDR_E;
											when 2 => addr_out <= ADDR_P;
											when 3 => addr_out <= ADDR_L;
											when 4 => addr_out <= ADDR_O;
											when 5 => addr_out <= ADDR_T;
											when 6 => addr_out <= ADDR_A;
											when 7 => addr_out <= ADDR_SPACE;

											-- Čísla teploty
											when 8 => addr_out <= digit_to_ascii(temp_data_dig1); 
											when 9 => addr_out <= digit_to_ascii(temp_data_dig2); 
											when 10 => addr_out <= ADDR_COMMA; 
											when 11 => addr_out <= digit_to_ascii(temp_frac_dig1); 
											when 12 => addr_out <= digit_to_ascii(temp_frac_dig2); 
											when 13 => addr_out <= ADDR_SPACE; 
											when 14 => addr_out <= ADDR_DEGREE; 
											when 15 => addr_out <= ADDR_C;
											when 16 => addr_out <= ADDR_SPACE;

											-- "VLHKOST "
											when 17 => addr_out <= ADDR_V;
											when 18 => addr_out <= ADDR_L;
											when 19 => addr_out <= ADDR_H;
											when 20 => addr_out <= ADDR_K;
											when 21 => addr_out <= ADDR_O;
											when 22 => addr_out <= ADDR_S;
											when 23 => addr_out <= ADDR_T;
											when 24 => addr_out <= ADDR_SPACE;

											-- Čísla vlhkosti
											when 25 => addr_out <= ADDR_SPACE; 
											when 26 => addr_out <= ADDR_SPACE; 
											when 27 => addr_out <= ADDR_COMMA; 
											when 28 => addr_out <= ADDR_SPACE;
											when 29 => addr_out <= ADDR_SPACE;
											when 30 => addr_out <= ADDR_SPACE;
											when 31 => addr_out <= ADDR_PERCENT;

											when others => addr_out <= ADDR_SPACE;
									  end case;

									  -- Posun čítače znaků
											if char_counter = 15 then
												 char_counter := 0;
											else
												 char_counter := char_counter + 1;
											end if;
											
								else
									row_counter <= row_counter + 1;
							  end if;
							  
					end if;		  
             end if;
    end process;

end Behavioral;