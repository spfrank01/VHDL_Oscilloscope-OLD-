library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


-------------------------------------------------------------------------------

entity lcd16x2_ctrl_demo2 is
  port (
    clk    : in  std_logic;
	 mode_select : in std_logic_vector(3 downto 0);
    lcd_e  : out std_logic;
    lcd_rs : out std_logic;
    lcd_rw : out std_logic;
    lcd_db : out std_logic_vector(7 downto 4));

end entity lcd16x2_ctrl_demo2;

-------------------------------------------------------------------------------

architecture behavior of lcd16x2_ctrl_demo2 is

  -- 
  signal timer : natural range 0 to 100000000 := 0;
  signal switch_lines : std_logic := '0';
  signal line1 : std_logic_vector(127 downto 0);
  signal line2 : std_logic_vector(127 downto 0);
  

  -- component generics
  constant CLK_PERIOD_NS : positive := 10;  -- 100 Mhz

  -- component ports
  signal rst          : std_logic;
  signal line1_buffer : std_logic_vector(127 downto 0);
  signal line2_buffer : std_logic_vector(127 downto 0);
  
  -- value of input
  signal data_buffer : std_logic_vector(7 downto 0) := X"31";
  signal count : integer range 0 to 10 := 0;
  signal status1_line1 : std_logic_vector(7 downto 0);
  signal status2_line1 : std_logic_vector(7 downto 0);
  signal status3_line1 : std_logic_vector(7 downto 0);
  signal status4_line1 : std_logic_vector(7 downto 0);
  signal status5_line1 : std_logic_vector(7 downto 0);
  signal status6_line1 : std_logic_vector(7 downto 0);
  signal check1_line2 : std_logic_vector(7 downto 0);
  signal check2_line2 : std_logic_vector(7 downto 0);
  signal check3_line2 : std_logic_vector(7 downto 0);
  signal check4_line2 : std_logic_vector(7 downto 0);
  signal f : std_logic_vector(7 downto 0);
begin  -- architecture behavior

  -- component instantiation
  DUT : entity work.lcd16x2_ctrl
    generic map (
      CLK_PERIOD_NS => CLK_PERIOD_NS)
    port map (
      clk          => clk,
      rst          => rst,
      lcd_e        => lcd_e,
      lcd_rs       => lcd_rs,
      lcd_rw       => lcd_rw,
      lcd_db       => lcd_db,
      line1_buffer => line1_buffer,
      line2_buffer => line2_buffer);

   rst <= '0';

  -- switch lines every second
  process(clk)
  begin
    if rising_edge(clk) then
	
      if timer = 0 then
			timer <= 50000000;
			count <= count + 1;
			if count = 3 then
				count <= 0;
				--data_buffer <= X"31";
			end if;
			
			if mode_select = "1101" then
				check1_line2 <= X"4f";
				check2_line2 <= X"4b";
				
				check3_line2 <= X"20";
				check4_line2 <= X"20";
				
			elsif mode_select = "1111" then
				check1_line2 <= X"20";
				check2_line2 <= X"20";
				
				check3_line2 <= X"4f";
				check4_line2 <= X"4b";
			
			elsif mode_select = "1011" then
				check1_line2 <= X"4f";
				check2_line2 <= X"4b";
				
				check3_line2 <= X"4f";
				check4_line2 <= X"4b";
			end if;
			
			f <= std_logic_vector(to_unsigned(count+48, 8));	
				
			--mode_select <= data_buffer;
			
			if count = 0 then
			
				status1_line1 <= X"4f";
				status2_line1 <= X"46";
				status3_line1 <= X"46";
				
				status4_line1 <= X"4f";
				status5_line1 <= X"46";
				status6_line1 <= X"46";
				
			elsif count = 1 then
			
				status1_line1 <= X"4f";
				status2_line1 <= X"4e";
				status3_line1 <= X"20";
				
				status4_line1 <= X"4f";
				status5_line1 <= X"46";
				status6_line1 <= X"46";
				
			elsif count = 2 then
			
				status1_line1 <= X"4f";
				status2_line1 <= X"46";
				status3_line1 <= X"46";
				
				status4_line1 <= X"4f";
				status5_line1 <= X"4e";
				status6_line1 <= X"20";
				
			elsif count = 3 then
			
				status1_line1 <= X"4f";
				status2_line1 <= X"4e";
				status3_line1 <= X"20";
				
				status4_line1 <= X"4f";
				status5_line1 <= X"4e";
				status6_line1 <= X"20";
				
			end if;
			
			  -- see the display's datasheet for the character map
			
				line2(127 downto 120) <= X"54";  -- T
				line2(119 downto 112) <= X"31";  -- 1
				line2(111 downto 104) <= X"20";  -- " "
				line2(103 downto 96)  <= X"3d";  -- =
				line2(95 downto 88)   <= check1_line2;  -- " "
				line2(87 downto 80)   <= check2_line2;  -- " "
				line2(79 downto 72)   <= X"20";  -- " "
				line2(71 downto 64)   <= X"20";  -- " "
				line2(63 downto 56)   <= X"54";  -- T
				line2(55 downto 48)   <= X"32";  -- 2
				line2(47 downto 40)   <= X"20";  -- " "
				line2(39 downto 32)   <= X"3d";  -- =
				line2(31 downto 24)   <= check3_line2;  -- " "
				line2(23 downto 16)   <= check4_line2;  -- " "
				line2(15 downto 8)    <= X"20";  -- " "
				line2(7 downto 0)     <= X"20";  -- " "
			
				line1(127 downto 120) <= X"43";  -- C
				line1(119 downto 112) <= X"48";  -- H
				line1(111 downto 104) <= X"31";  -- 1
				line1(103 downto 96)  <= X"3a";  -- :
				line1(95 downto 88)   <= status1_line1;  -- O
				line1(87 downto 80)   <= status2_line1;  -- N or F
				line1(79 downto 72)   <= status3_line1;  -- " " or F
				line1(71 downto 64)   <= X"20";  -- " "
				line1(63 downto 56)   <= X"43";  -- C
				line1(55 downto 48)   <= X"48";  -- H
				line1(47 downto 40)   <= X"32";  -- 2
				line1(39 downto 32)   <= X"3a";  -- :
				line1(31 downto 24)   <= status4_line1;  -- O
				line1(23 downto 16)   <= status5_line1;  -- N or F
				line1(15 downto 8)    <= status6_line1;  -- " " or F
				line1(7 downto 0)     <= f;  -- " "
      else
         timer <= timer - 1;
      
		end if;
	end if;     		
 end process;
  
   line1_buffer <= line1; --when switch_lines = '1' else line1;
   line2_buffer <= line2; --when switch_lines = '1' else line2;
end architecture behavior;