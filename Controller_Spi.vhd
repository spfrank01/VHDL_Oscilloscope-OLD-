library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Controller_Spi is
port(
	CLK : in std_logic;
	--RX
	MODE : in std_logic_vector(1 downto 0);
	
	-- SPI
	WDATA : out std_logic_vector(3 downto 0);
	START : out std_logic:='0';
	DONE 	: in std_logic);
end Controller_Spi;


architecture behave of Controller_Spi is
constant MAX_COUNTER: integer := 25000000;
constant VOLTAGE_REFER : integer := 3300;
   type state_type is (
        WAIT_TIME_REQ,
		  
		  --MODE OFF
		  MODE_OFF,
		  
		  --MODE SINGLE
		  REQ_VOLTAGE_SINGLE,
		  WAIT_DONE_SINGLE);
		  
  signal state: state_type := WAIT_TIME_REQ;
  signal timer : natural range 0 to 100000000 := 0;
  --signal count_time, voltage_data, voltage_data2 : integer :=0;
  signal mode_buffer : std_logic_vector(1 downto 0):="00";
  signal voltage_buffer : std_logic_vector(11 downto 0);
  signal channel_tem : std_logic_vector(3 downto 0);
begin
process(CLK) 
begin
	if rising_edge(CLK) then
		
		--if MODE /= mode_buffer then
		--	timer <= 25000000;
		--	state <= WAIT_TIME_REQ;
		--	mode_buffer <= MODE;
		--end if;
		
		case state is
		
			when WAIT_TIME_REQ =>
				--request_tx <= '0';
				START <= '0';
				--check <= "00000010";
				if MODE = "00" then
					state <= MODE_OFF;
				elsif MODE = "01" then
					channel_tem <= "1101";
					state	<= REQ_VOLTAGE_SINGLE;
				elsif MODE = "10" then
					channel_tem <= "1111";
					state	<= REQ_VOLTAGE_SINGLE;
				elsif MODE = "11" then
					state <= MODE_OFF;  --REQ_VOLTAGE_CH1_DUAL;
				end if;
		  
		  --MODE OFF
			when MODE_OFF =>
				--data_to_tx <= "00000000";
				--request_tx <= '1';
				state <= WAIT_TIME_REQ;
	
----------------------------------------------------------------------------------------	
		  --MODE SINGLE
			when REQ_VOLTAGE_SINGLE =>
			
				if DONE = '1' then
					WDATA <= channel_tem;
					START <= '1';
					state <= WAIT_DONE_SINGLE;
				end if;
				
			when WAIT_DONE_SINGLE =>
				START <= '0';
				if DONE = '1' then
					state <= WAIT_TIME_REQ;
				end if;
		
		end case;
	end if;

end process;
end behave;