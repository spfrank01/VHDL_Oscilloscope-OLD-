library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;
entity Control_test is
	port (
			CLK : in std_logic;
			rst_i : in std_logic;
			BT : in std_logic;
			WDATA : out std_logic_vector(3 downto 0);
			DATA_IN : in std_logic_vector(7 downto 0));
end Control_test;

architecture behave of Control_test is
	signal channel_tem : std_logic_vector(3 downto 0);
	type state_type is (
		check_mode_bit,
		wait_button,
		single_channel);
	signal state : state_type := check_mode_bit;
	begin
		process(CLK, rst_i)
			begin
         if rst_i = '0' then
				state <= check_mode_bit;
			elsif rising_edge(CLK)then
				case state is
				
					when check_mode_bit =>
					
						if BT = '0' then
							state <= wait_button;
						end if;
						
					when wait_button =>
						if BT = '1' and DATA_IN = "00100000" then
							channel_tem <= "1101";
							state <= single_channel;
						elsif BT = '1' and DATA_IN = "00100001" then
							channel_tem <= "1111";
							state <= single_channel;
						elsif BT = '1' and DATA_IN = "00100010" then
							channel_tem <= "1011";
							state <= single_channel;
						end if;
					
					when single_channel =>
						WDATA <= channel_tem;
						state <= check_mode_bit;
	
				end case;
			end if;
		end process;
end behave;