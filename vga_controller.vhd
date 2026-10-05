library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
	port(
			reset, clock : in std_logic;
			vsync, hsync : out std_logic;
			h_pos, v_pos : out integer;
			display_interval : out std_logic
			);

end vga_controller;	

architecture Behavioral of vga_controller is

		 constant h_display : integer := 640;  
		 constant h_front_porch : integer := 16;
		 constant hsync_pulse : integer := 96;
		 constant h_back_porch : integer := 48;
		 constant h_total : integer := 800; 

		 constant v_display : integer := 480; 
		 constant v_front_porch : integer := 10;
		 constant vsync_pulse : integer := 2;
		 constant v_back_porch : integer := 33;
		 constant v_total : integer := 525;  
			 
			 
		constant h_end : integer := 799;
		constant v_end : integer := 524;  

		signal sig_prenos_citace : std_logic;

		signal sig_h_citac : integer := 0;
		signal sig_v_citac : integer := 0;

component counter is
	generic (konec_linky : integer);
	port (clock,reset : in std_logic;
			prenos : out std_logic;
			stav : out integer
			);
	end component;

	begin
	
		h_citac : counter
		generic map(h_end)
		port map (  clock => clock,
						reset => reset,
						prenos => sig_prenos_citace,
						stav => sig_h_citac
						);
						
		v_citac : counter
		generic map(v_end)
		port map (  clock => sig_prenos_citace,
						reset => reset,
						prenos => open,
						stav => sig_v_citac
						);



		-- prvni snimek a radek zacina zobrazovaci oblasti, pak prijde horizontal front porch, pak hsync pulz a nakonec back porch
		-- sync pulz mel puvodne za funkce vraceni ukazatele na monitoru na novy radek, proto se zacina aktivni oblasti
		hsync <= '0' when sig_h_citac  >=  h_display + h_front_porch and sig_h_citac < h_display + h_front_porch + hsync_pulse else '1';
		
		
		-- proto i vertikalni cast zacina zobrazovaci oblasti, vsync ma za ukol nahodit novy snimek po tom starem
		vsync <= '0' when (sig_v_citac >= v_display + v_front_porch and sig_v_citac < v_display + v_front_porch + vsync_pulse) else '1';

		display_interval <= '1' when (sig_h_citac < h_display and sig_v_citac < v_display) else '0';
	
		h_pos <= sig_h_citac;	
		 
		v_pos <= sig_v_citac;
	
end Behavioral;