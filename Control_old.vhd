library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_unsigned.all;
entity Control_old is
	port (
			CLK : in std_logic;
			req_i : in std_logic;
	      rst_i  : in	 std_logic;		-- synchronous reset, active low
			START : out std_logic;
			DONE : in std_logic;
			mode_data : out std_logic_vector(3 downto 0);
			WDATA : out std_logic_vector(3 downto 0);
			DATA_IN : in std_logic_vector(7 downto 0));
end Control_old;

architecture behave of Control_old is
	signal channel_tem : std_logic_vector(3 downto 0);
	type state_type is (
		check_start_bit,
		check_mode_bit,
		single_channel,
		wait_for_spi,
		wait_for_dual,
		send_dual,
		dual_channel);
	signal state : state_type := check_start_bit;
	begin
		process(CLK, req_i, rst_i)
			begin
         if rst_i = '0' then
				state <= check_start_bit;
				START <= '0';
			elsif rising_edge(CLK)then
				case state is
					when check_start_bit =>
					
						if req_i = '0' and Data_IN = x"23" then
							state <= check_mode_bit;
						end if;
					
					when check_mode_bit =>
					
						if req_i = '0' then
							 if DATA_IN = x"30" then  -- 1 ascii
								 mode_data <= "0000";
								 state <= check_start_bit;
								 
							 elsif DATA_IN = x"31" then
								 mode_data <= "0001";
								 channel_tem <= "1101";
							    state <= single_channel;
								 
							 elsif DATA_IN = x"32" then
							    mode_data <= "0010";
								 channel_tem <= "1111";
							    state <= single_channel;
								 
							 elsif DATA_IN = x"33" then
							    mode_data <= "0011";
							    channel_tem <= "1101";
							    state <= dual_channel;
							 end if;
						end if;
					
					when single_channel =>

						if DONE = '1' then
							WDATA <= channel_tem;
							START <= '1';
							state <= wait_for_spi;
						end if;
					
					when wait_for_spi =>

						if DONE = '1' then
							START <= '0';
							state <= check_start_bit;
						end if;
							
					when dual_channel =>

						if DONE = '1' then
							WDATA <= channel_tem;
							START <= '1';
							state <= wait_for_dual;
						end if;
						
					when wait_for_dual =>

						if DONE = '1' then
							channel_tem <= "1111";
							START <= '0';
							state <= send_dual;
						end if;
						
					when send_dual =>

						if DONE = '1' then
							WDATA <= channel_tem;
							START <= '1';
							state <= wait_for_spi;
						end if;
						
				end case;
			end if;
		end process;
end behave;