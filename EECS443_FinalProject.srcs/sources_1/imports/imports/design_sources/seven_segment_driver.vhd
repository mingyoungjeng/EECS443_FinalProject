LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.MATH_REAL.ALL;

ENTITY seven_segment_driver IS
        GENERIC(f_board   : REAL := 100.0E6; -- 100 MHz
                f_flicker : REAL := 62.5;    -- 62.5 Hz
                n_digits  : NATURAL := 8     -- 8 7-Segment Digits
                );
	PORT(clk      : IN  STD_LOGIC;
	     rst      : IN  STD_LOGIC;
	     data     : IN  STD_LOGIC_VECTOR(4*n_digits - 1 DOWNTO 0);
	     anodes   : OUT STD_LOGIC_VECTOR(n_digits - 1 DOWNTO 0);
	     cathodes : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	    );
END seven_segment_driver;

ARCHITECTURE behavior OF seven_segment_driver IS

constant f_refresh : real := real(n_digits) * f_flicker;
constant count_max1 : natural := integer((f_board/f_refresh) - real(1));
constant count_max2 : natural := n_digits - 1;

signal current_state1, next_state1, current_state2, next_state2 : natural;
signal data_sig : unsigned(3 downto 0);
signal anodes_sig : std_logic_vector(n_digits - 1 DOWNTO 0);

BEGIN

process (clk, rst)
begin
if (rst = '1') then
    current_state1 <= 0;
    current_state2 <= 0;
elsif (clk'event and clk='1') then
    current_state1 <= next_state1;
    current_state2 <= next_state2;
end if;
end process;

next_state1 <= current_state1 + 1 when current_state1 /= count_max1 else 0;
next_state2 <= current_state2 when current_state1 /= count_max1 else
               current_state2 + 1 when current_state2 /= count_max2 else 
               0;
         
process (current_state2)
begin
    anodes <= (others => '1');
    anodes(current_state2) <= '0';
end process;

data_sig <= unsigned(data((4*current_state2)+3 downto 4*current_state2));
cathodes <= "1000000" when data_sig = 0 else
            "1111001" when data_sig = 1 else
            "0100100" when data_sig = 2 else
            "0110000" when data_sig = 3 else
            "0011001" when data_sig = 4 else
            "0010010" when data_sig = 5 else
            "0000010" when data_sig = 6 else
            "1111000" when data_sig = 7 else
            "0000000" when data_sig = 8 else
            "0010000" when data_sig = 9 else
            "0001000" when data_sig = 10 else
            "0000011" when data_sig = 11 else
            "1000110" when data_sig = 12 else
            "0100001" when data_sig = 13 else
            "0000110" when data_sig = 14 else
            "0001110" when data_sig = 15 else
            "0000000";    

END behavior;
