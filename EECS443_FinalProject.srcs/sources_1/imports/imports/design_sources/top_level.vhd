LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.MATH_REAL.ALL;

ENTITY top_level IS
	PORT(clk : IN  STD_LOGIC;
	     BTNC, BTNL, BTNR      : IN  STD_LOGIC;
	     AN        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	     CA        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	     unlocked: out std_logic
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
	
    signal data, data_next: STD_LOGIC_VECTOR(4*n_digits - 1 DOWNTO 0) := (others =>'0');
    signal active_seg, active_seg_next: natural := n_digits-1;
    signal direction: std_logic := '1'; -- 0 is "clockwise", 1 is "anticlockwise"
    signal combination: natural := 16#1234ABCD#;
    signal inc, dec: std_logic_vector(3 downto 0) := (others => '0');
    signal BTNL_state, BTNR_state: std_logic := '0';

BEGIN
    process (BTNL, BTNR, BTNC, clk)
    begin
        if (clk'event and clk = '1') then   
            if (BTNL='1' and BTNL_state='0') then
                if (direction = '0') then
                    active_seg <= active_seg_next;
                    direction <= '1';
                    data(4*active_seg_next+3 downto 4*active_seg_next) <= inc;
                else
                    data(4*active_seg+3 downto 4*active_seg) <= inc;
                end if;
            end if;     
           
            if (BTNR='1' and BTNR_state='0') then
                if (direction = '1') then
                    active_seg <= active_seg_next;
                    direction <= '0';
                    data(4*active_seg_next+3 downto 4*active_seg_next) <= dec;
                else
                    data(4*active_seg+3 downto 4*active_seg) <= dec;
                end if;
            end if;
            
            if (BTNC = '1') then
                if (data = std_logic_vector(to_unsigned(combination, data'length))) then
                    unlocked <= '1';
                else
                    unlocked <= '0';
                end if;
            end if;
            
            BTNL_state <= BTNL;
            BTNR_state <= BTNR;
        end if;
    end process;
    
    active_seg_next <= (active_seg + 7) mod n_digits;
    inc <= std_logic_vector(unsigned(data(4*active_seg+3 downto 4*active_seg)) + 1);
    dec <= std_logic_vector(unsigned(data(4*active_seg+3 downto 4*active_seg)) - 1);
    
    i0 : seven_segment_driver
         GENERIC MAP (f_board => f_board,
                      f_flicker => f_flicker,
                      n_digits => n_digits
                     )
         PORT MAP (clk => clk,
                   rst => '0',
                   data => data,
                   anodes => AN,
                   cathodes => CA
                  );
END behavior;