LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.MATH_REAL.ALL;

ENTITY top_level IS
	PORT(clk : IN  STD_LOGIC;
	     BTNC, BTNL, BTNR      : IN  STD_LOGIC;
	     config : in std_logic; -- enable setting mode
	     rst	   : in STD_logic;
	     AN        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	     CA        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	     state_unlocked, state_locked, state_set: out std_logic;
	     state_out : out std_logic_vector(1 Downto 0);
	     config_out: out std_logic
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
	
    signal data: STD_LOGIC_VECTOR(4*n_digits - 1 DOWNTO 0) := (others =>'0'); --data_next
    signal active_seg, active_seg_next: natural := n_digits-1;
    signal direction: std_logic := '1'; -- 0 is "clockwise", 1 is "anticlockwise"
    signal inc, dec: std_logic_vector(3 downto 0) := (others => '0');
    signal BTNL_state, BTNR_state: std_logic := '0';
    
    -- States
    	-- Locked
    	signal locked_state: std_logic := '0'; --  (0 := locked; 1:= unlocked)
    
   		-- Change
    	signal change_state: std_logic := '0'; --  1:= change the combo mode
    

    signal combination: natural := 16#1f000000#; --1234ABCD
    constant starting_combination: natural := 16#1f000000#; --1234ABCD


BEGIN



-- Unlock
    unlock: process (BTNL, BTNR, BTNC, config, clk,rst)
    begin
        if (clk'event and clk = '1') then
        	if (rst = '1') then -- reset
        	    locked_state <= '0';
        		change_state <= '0';
        		data <= (others => '0');
        		active_seg <= 0;
        		BTNL_state <= '0';
        		BTNR_state <= '0';
        		 

        	else
        		-- Left
				   if (BTNL='1' and BTNL_state='0') then
					if (direction = '0') then
						active_seg <= active_seg_next;
						direction <= '1';
						data(4*active_seg_next+3 downto 4*active_seg_next) <= inc;
					else
						data(4*active_seg+3 downto 4*active_seg) <= inc;
					end if;
				end if;     
				
				
			   -- Right
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
					if (change_state = '1') then
						-- Update the new combination
						combination <= to_integer(unsigned (data));
						
						-- reset all the things
						data <= (others => '0');
						
						change_state <= '0';
						locked_state <= '0';
					else
						-- Check Lock state
						if (data = std_logic_vector(to_unsigned(combination, data'length))) then
							locked_state <= '1'; -- unlocked
						else
							locked_state <= '0'; -- locked
						end if;
					end if;
				end if;
				
				-- change to config mode

				if (config ='1' and (change_state /= '1')) then
				   	change_state  <= locked_state and config;
        			data <= (others => '0');
        			active_seg <= 0;
        			BTNL_state <= '0';
        			BTNR_state <= '0';
				else
					BTNL_state <= BTNL;
					BTNR_state <= BTNR;
				
				end if;
				
				

				
				
        	end if; 
        end if;
    end process;
    
    -- seting the new combo


--set: process (config,locked_state,clk,rst)
--    begin
--        if (clk'event and clk = '1') then
--        	if (rst = '1') then -- reset
----        		data <= (others => '0');
----        		locked_state <= '0';
----        		change_state <= '0';
----        		active_seg <= 0;
----        		combination <= starting_combination;
----			;

--        	else
--        	    change_state  <= locked_state and config;
--			end if;
--        end if;
--    end process;

    -- Output 
    state_unlocked 	<= locked_state and not change_state;
    state_locked   	<= not locked_state;
    state_set 		<= change_state;
    
    -- temp state out
    state_out <= (0 => locked_state, 1 => change_state);
    config_out <= config;
    
    -- 7 Seg
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