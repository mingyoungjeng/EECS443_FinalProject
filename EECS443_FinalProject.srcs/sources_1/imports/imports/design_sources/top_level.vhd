LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.MATH_REAL.ALL;

ENTITY top_level IS
    PORT(clk                                     : IN  STD_LOGIC;
         BTNC, BTNL, BTNR                        : IN  STD_LOGIC;
         config                                  : in  std_logic; -- enable setting mode
         rst, rst_hard                           : in  STD_logic;
         AN                                      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         CA                                      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
         state_unlocked, state_locked, state_change : out std_logic;
         rst_hard_warn                          : out std_logic
        );
END top_level;

ARCHITECTURE behavior OF top_level IS

    COMPONENT seven_segment_driver
        GENERIC(f_board   : REAL    := 100.0E6; -- 100 MHz
                f_flicker : REAL    := 62.5; -- 62.5 Hz
                n_digits  : NATURAL := 8 -- 8 7-Segment Digits
               );
        PORT(clk      : IN  STD_LOGIC;
             rst      : IN  STD_LOGIC;
             data     : IN  STD_LOGIC_VECTOR(4 * n_digits - 1 DOWNTO 0);
             anodes   : OUT STD_LOGIC_VECTOR(n_digits - 1 DOWNTO 0);
             cathodes : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
            );
    END COMPONENT;
    
    component button is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           edge : out STD_LOGIC
           );
    end component;

    CONSTANT f_board   : REAL    := 100.0E6; -- 100 MHz
    CONSTANT f_flicker : REAL    := 62.5; -- 62.5 Hz
    CONSTANT n_digits  : NATURAL := 8;  -- 8 7Segment Digits

    signal data                        : STD_LOGIC_VECTOR(4 * n_digits - 1 DOWNTO 0) := (others => '0'); --data_next
    signal active_seg, active_seg_next : natural                                     := n_digits - 1;
    signal direction                   : std_logic                                   := '1'; -- 0 is "clockwise", 1 is "anticlockwise"
    signal inc, dec                    : std_logic_vector(3 downto 0)                := (others => '0');
    signal BTNL_state, BTNR_state      : std_logic := '0';
    
    signal reset, rst_sig: std_logic := '0';

    type lock_type is (locked, unlocked, change);
    signal lock_state, lock_next: lock_type := locked;

    constant default_combination : natural := 16#1f000000#;
    signal combination           : natural := default_combination;

BEGIN

    reset <= rst or rst_sig;
    process(clk, rst)
    begin
        if (rst = '1') then         -- reset
            data         <= (others => '0');
            active_seg   <= n_digits - 1;
            BTNL_state   <= '0';
            BTNR_state   <= '0';
            direction    <= '1';
        elsif (clk'event and clk = '1') then
            -- Left
            if (BTNL = '1' and BTNL_state = '0') then
                if (direction = '0') then
                    if (active_seg /= 0) then
                        active_seg                                               <= active_seg_next;
                        direction                                                <= '1';
                        data(4 * active_seg_next + 3 downto 4 * active_seg_next) <= inc;
                    end if;
                else
                    data(4 * active_seg + 3 downto 4 * active_seg) <= inc;
                end if;
            end if;

            -- Right
            if (BTNR = '1' and BTNR_state = '0') then
                if (direction = '1') then
                    if (active_seg /= 0) then
                        active_seg                                               <= active_seg_next;
                        direction                                                <= '0';
                        data(4 * active_seg_next + 3 downto 4 * active_seg_next) <= dec;
                    end if;
                else
                    data(4 * active_seg + 3 downto 4 * active_seg) <= dec;
                end if;
            end if;
            
            lock_state <= lock_next;
            BTNL_state <= BTNL;
            BTNR_state <= BTNR;
        end if;
    end process;
    
    process (lock_state, BTNC, config, reset)
    begin
        if (reset = '1') then
            rst_sig <= '0';
            if (rst_hard = '1') then
                combination <= default_combination;
            end if;
        else 
            state_locked <= '0';
            state_unlocked <= '0';
            state_change <= '0';
            case lock_state is
                when locked =>
                    state_locked <= '1';
                    if (BTNC = '1' and unsigned(data) = combination) then
                        rst_sig <= '1';
                        lock_next <= unlocked;
                    end if;
                when unlocked =>
                    state_unlocked <= '1';
                    if (config = '1') then
                        lock_next <= change;
                    end if;
                when change =>
                    state_change <= '1';
                    if (BTNC = '1') then
                        rst_sig <= '1';
                        lock_next <= locked;
                    end if;
            end case;
        end if;
    end process;

    -- Output 
    rst_hard_warn <= rst_hard;

    -- 7 Seg
    active_seg_next <= (active_seg + 7) mod n_digits;
    inc             <= std_logic_vector(unsigned(data(4 * active_seg + 3 downto 4 * active_seg)) + 1);
    dec             <= std_logic_vector(unsigned(data(4 * active_seg + 3 downto 4 * active_seg)) - 1);

    i0 : seven_segment_driver
        GENERIC MAP(f_board   => f_board,
                    f_flicker => f_flicker,
                    n_digits  => n_digits
                   )
        PORT MAP(clk      => clk,
                 rst      => '0',
                 data     => data,
                 anodes   => AN,
                 cathodes => CA
                );

END behavior;
