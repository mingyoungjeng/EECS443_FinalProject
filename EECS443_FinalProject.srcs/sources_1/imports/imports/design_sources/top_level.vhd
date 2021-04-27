LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.MATH_REAL.ALL;

ENTITY top_level IS
	PORT(CLK100MHZ : IN  STD_LOGIC;
	     BTNC, BTNL, BTNR      : IN  STD_LOGIC;
	     AN        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	     CA        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	     locked: out std_logic
	    );
END top_level;

ARCHITECTURE behavior OF top_level IS	

    COMPONENT seven_segment_driver
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
    END COMPONENT;
    
    CONSTANT f_board   : REAL := 100.0E6; -- 100 MHz
    CONSTANT f_flicker : REAL := 62.5;    -- 62.5 Hz
    CONSTANT n_digits  : NATURAL := 8;    -- 8 7Segment Digits
	
    SIGNAL clk, rst      : STD_LOGIC;
    SIGNAL data, data_next: STD_LOGIC_VECTOR(4*n_digits - 1 DOWNTO 0) := (others =>'0');
    SIGNAL anodes   : STD_LOGIC_VECTOR(n_digits - 1 DOWNTO 0);
    SIGNAL cathodes : STD_LOGIC_VECTOR(6 DOWNTO 0);
    
    signal active_seg : natural := 0;
    signal active_data: std_logic_vector(3 downto 0) := (others =>'0');
    signal direction: std_logic := '0'; -- 0 is "clockwise", 1 is "anticlockwise"
    SIGNAL combination: natural := 16#ABCD#;

BEGIN
    process (BTNL, BTNR, BTNC)
    begin
        if ((BTNL xor BTNR) = '1') then
            if (direction = BTNR) then -- Changed direction
                direction <= direction xor '1';
                active_seg <= active_seg mod n_digits;
                active_data <= data((4*active_seg)+3 downto 4*active_seg);
            else -- Same direction
                active_data <= std_logic_vector(unsigned(active_data) + 1);
            end if;
        end if;
        
        locked <= '0';
        if (BTNC = '1' and data = std_logic_vector(to_unsigned(combination, data'length))) then
            locked <= '1';
        end if;
    end process;

    process (clk)
    begin
        if (clk'event and clk='1') then
            data <= data_next;
        end if;
    end process;
--    data_next <= data and std_logic_vector(resize(shift_left(unsigned(active_data), 4*active_seg), 4*n_digits));
    data_next <= std_logic_vector(unsigned(data) + 1);
    
    clk <= CLK100MHZ;
    rst <= '0';
    AN <= anodes;
    CA <= cathodes;

    i0 : seven_segment_driver
         GENERIC MAP (f_board => f_board,
                      f_flicker => f_flicker,
                      n_digits => n_digits
                     )
         PORT MAP (clk => clk,
                   rst => rst,
                   data => data,
                   anodes => anodes,
                   cathodes => cathodes
                  );
END behavior;