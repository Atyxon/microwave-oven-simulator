library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mikrofala is
  port(
	 start_oven			  : in  std_logic;
	 open_doors			  : in  std_logic;
	 close_doors		  : in  std_logic;
    program_input      : in  unsigned(2 downto 0); --Wybieranie programu
	 time_input			  : in  unsigned(2 downto 0); --Wybieranie czasu
    reset_custom       : in  std_logic; --Resetowanie wartości customowych
	 
	 heating_time		  : out integer;
	 HEX_time			  : out std_logic_vector(6 downto 0); --HEX do wyświetlania wybranego czasu
	 HEX_program		  : out std_logic_vector(6 downto 0); --HEX do wyświetlania wybranego programu
	 HEX_power	   	  : out std_logic_vector(6 downto 0); --HEX do wyświetlania mocy grzania
	 LED_R 				  : out bit_vector(2 downto 0) --Czerwony LED do wyświetlania awarii/błędów
																		 --"000" Brak błędu
																		 --"001" Próba uruchomienia mikrofali przy otwartych drzwiach
																		 --"010" Przerwano grzanie
);
end mikrofala;

architecture microwave_control of mikrofala is

  type program_type is (pizza, popcorn, soup, tea, defrost, custom);
  type program_heat is (C60, C80, C100);
  type program_rotation_speed  is (RPM_1, RPM_2, RPM_3);
  
  signal selected_program 				: program_type;
  signal selected_heat 					: program_heat;
  signal selected_rotation_speed 	: program_rotation_speed;
  signal custom_temperature 			: unsigned(7 downto 0);
  signal custom_rotation_speed 		: unsigned(7 downto 0);
  signal heating_time_left 			: integer := 0;
  signal	doors_oppened 	  				: bit;
  signal oven_working 	 	  			: bit;
  
  begin
  process(program_input)
  begin
    case program_input is
      when "000" =>
			selected_program <= pizza;
			selected_heat <= C80;
			selected_rotation_speed <= RPM_2;
			HEX_program <= "0000001";
			HEX_power <= "0000001";
      when "001" =>
			selected_program <= popcorn;
			selected_heat <= C80;
			selected_rotation_speed <= RPM_1;
			HEX_program <= "0000010";
			HEX_power <= "0000010";
      when "010" =>
			selected_program <= soup;
			selected_heat <= C60;
			selected_rotation_speed <= RPM_3;
			HEX_program <= "0000011";
			HEX_power <= "0000011";
      when "011" =>
			selected_program <= tea;
			selected_heat <= C100;
			selected_rotation_speed <= RPM_2;
			HEX_program <= "0000100";
			HEX_power <= "0000100";
      when "100" =>
			selected_program <= defrost;
			selected_heat <= C60;
			selected_rotation_speed <= RPM_1;
			HEX_program <= "0000101";
			HEX_power <= "0000101";
      when "101" =>
			selected_program <= custom;
			HEX_program <= "1111111";
			HEX_power <= "1111111";
      when others =>
			selected_program <= custom;
			HEX_program <= "1111111";
			HEX_power <= "1111111";
    end case;
  end process;
  
  process(time_input)
  begin
    case program_input is
      when "000" => heating_time <= 1; HEX_time <= "0000001";
      when "001" => heating_time <= 2; HEX_time <= "0000010";
      when "010" => heating_time <= 5; HEX_time <= "0000011";
      when "011" => heating_time <= 10; HEX_time <= "0000100";
      when "100" => heating_time <= 15; HEX_time <= "0000101";
      when "101" => heating_time  <= 20; HEX_time <= "0000110";
      when others =>
    end case;
  end process;
  
  process(start_oven)
  begin
	 case doors_oppened is
		when '0' => oven_working <= '1';
      when others => LED_R <= "001";
    end case;
  end process;
  
  process(open_doors)
  begin
	 doors_oppened <= '1';
	 case oven_working is
		when '1' => 
			oven_working <= '0';
			LED_R <= "010";
      when others =>
    end case;
  end process;
  
  process(close_doors)
  begin
	 doors_oppened <= '0';
  end process;
  
end microwave_control;