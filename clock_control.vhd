library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_control is
    port(
        default_clk : in std_logic;
        time_alarm_mode : in std_logic;   -- 0 for time, 1 for alarm
        show_change_mode : in std_logic;  -- 0 for show, 1 for change
        alarm_en : in std_logic;
        inc_digit : in std_logic;           -- increment current digit (must be in change mode)
        dec_digit : in std_logic;           -- decrement current digit (must be in change mode)
        left_digit : in std_logic;                -- go left one place (i.e. seconds to minutes, or minutes to hour)
        right_digit : in std_logic;               -- go right one place
        set : in std_logic;                 -- set the time or alarm (i.e. write enable for changing the time or alarm)
        hr_out1 : out std_logic_vector(6 downto 0);
        hr_out0 : out std_logic_vector(6 downto 0);
        min_out1 : out std_logic_vector(6 downto 0);
        min_out0 : out std_logic_vector(6 downto 0);
        sec_out1 : out std_logic_vector(6 downto 0);
        sec_out0 : out std_logic_vector(6 downto 0);
        AMPM_out : out std_logic;
        alarm_triggered : out std_logic;
		  clk_1Hz_out : out std_logic;
		  unused_leds : out std_logic_vector(6 downto 0)
    );
end clock_control;

architecture Behavioral of clock_control is
signal prev_state : std_logic_vector(1 downto 0) := "00";
signal curr_state : std_logic_vector(1 downto 0);
-- 00 is show time
-- 01 is change time
-- 10 is show alarm
-- 11 is change alarm

signal curr_digit : unsigned(1 downto 0) := "00";
-- 00 is seconds
-- 01 is minutes
-- 10 is hours

-- store temp values when changing the time or alarm (for display)
signal disp_hr : unsigned(3 downto 0);
signal disp_min : unsigned(5 downto 0);
signal disp_sec : unsigned(5 downto 0);
signal disp_AMPM : std_logic;

-- temp display outputs (use for blinking)
signal temp_hr_out1 : std_logic_vector(6 downto 0);
signal temp_hr_out0 : std_logic_vector(6 downto 0);
signal temp_min_out1 : std_logic_vector(6 downto 0);
signal temp_min_out0 : std_logic_vector(6 downto 0);
signal temp_sec_out1 : std_logic_vector(6 downto 0);
signal temp_sec_out0 : std_logic_vector(6 downto 0);

-- current time
signal curr_time_hr : unsigned(3 downto 0);
signal curr_time_min : unsigned(5 downto 0);
signal curr_time_sec : unsigned(5 downto 0);
signal curr_time_AMPM : std_logic; 

-- current alarm
signal curr_alarm_hr : unsigned(3 downto 0); -- 6
signal curr_alarm_min : unsigned(5 downto 0); -- 0
signal curr_alarm_sec : unsigned(5 downto 0); -- 0
signal curr_alarm_AMPM : std_logic := '0'; -- AM 

signal clk_1Hz : std_logic;

-- DEBOUNCED buttons
signal inc_digit_db : std_logic;           
signal dec_digit_db : std_logic;           
signal left_digit_db : std_logic;                
signal right_digit_db : std_logic;               
signal set_db : std_logic;


-- COMPONENTS
component debounce is
        port(
				clk        : in  std_logic;
				btn_raw    : in  std_logic;
				btn_pulse  : out std_logic
        );
end component debounce;

component second_pulse is
        port(
            default_clk : in std_logic;
            second_clk : out std_logic
        );
end component second_pulse;


component timekeep is
        port(
				default_clk : in std_logic;
            second_clk : in std_logic;
            hour_in : in unsigned(3 downto 0);
            minute_in : in unsigned(5 downto 0);
            second_in : in unsigned (5 downto 0);
            AMPM_in : in std_logic; -- 0 is AM, 1 is PM
            write_sel : in std_logic; -- 0 to update time and 1 to update alarm
            write_en : in std_logic;
            alarm_en : in std_logic;
            curr_time_hr : out unsigned (3 downto 0);
            curr_time_min : out unsigned (5 downto 0);
            curr_time_sec : out unsigned (5 downto 0);
            curr_time_AMPM : out std_logic;
            curr_alarm_hr : out unsigned (3 downto 0);
            curr_alarm_min : out unsigned (5 downto 0);
            curr_alarm_sec : out unsigned (5 downto 0);
            curr_alarm_AMPM : out std_logic;
            alarm_active : out std_logic
        );
end component timekeep;

component display_controller is
        port(
            hr_in : in unsigned(3 downto 0);
            min_in : in unsigned(5 downto 0);
            sec_in : in unsigned(5 downto 0);
            AMPM_in : in std_logic;
            hr_out1 : out std_logic_vector(6 downto 0);
            hr_out0 : out std_logic_vector(6 downto 0);
            min_out1 : out std_logic_vector(6 downto 0);
            min_out0 : out std_logic_vector(6 downto 0);
            sec_out1 : out std_logic_vector(6 downto 0);
            sec_out0 : out std_logic_vector(6 downto 0)
        );
end component display_controller;


begin

------------------------------------------------------------------ COMPONENTS

U0: timekeep
        port map (
				default_clk => default_clk, 
            second_clk => clk_1Hz,
            hour_in => disp_hr,
            minute_in => disp_min,
            second_in => disp_sec,
            AMPM_in => disp_AMPM,
            write_sel => curr_state(1),
            write_en => (set and curr_state(0)), --
            alarm_en => alarm_en,
            curr_time_hr => curr_time_hr,
            curr_time_min => curr_time_min,
            curr_time_sec => curr_time_sec,
            curr_time_AMPM => curr_time_AMPM,
            curr_alarm_hr => curr_alarm_hr,
            curr_alarm_min => curr_alarm_min,
            curr_alarm_sec => curr_alarm_sec,
            curr_alarm_AMPM => curr_alarm_AMPM,
            alarm_active => alarm_triggered
        );
        
U1: display_controller
        port map (
            hr_in => disp_hr,
            min_in => disp_min,
            sec_in => disp_sec,
            AMPM_in => disp_AMPM,
            hr_out1 => temp_hr_out1,
            hr_out0 => temp_hr_out0,
            min_out1 => temp_min_out1,
            min_out0 => temp_min_out0,
            sec_out1 => temp_sec_out1,
            sec_out0 => temp_sec_out0
        );
        
U2: second_pulse
        port map (
            default_clk => default_clk,
            second_clk => clk_1Hz
        );
		  
D0: debounce
        port map (
            clk => default_clk,
				btn_raw => inc_digit,
				btn_pulse => inc_digit_db
        );
		  
D1: debounce
        port map (
            clk => default_clk,
				btn_raw => dec_digit,
				btn_pulse => dec_digit_db
        );		  

D2: debounce
        port map (
            clk => default_clk,
				btn_raw => left_digit,
				btn_pulse => left_digit_db
        );
		  
D3: debounce
        port map (
            clk => default_clk,
				btn_raw => right_digit,
				btn_pulse => right_digit_db
        );

D4: debounce
        port map (
            clk => default_clk,
				btn_raw => set,
				btn_pulse => set_db
        );
		  
-- fsm
process(default_clk)
begin
    if rising_edge(default_clk) then
        prev_state <= curr_state;
        curr_state <= (time_alarm_mode) & (show_change_mode);
    end if;
end process;

-- initialize display to current settings when transitioning to a "change" mode
-- AND for changing digits
process(default_clk)
begin
    if rising_edge(default_clk) then
        -- detect a state change
        if not(prev_state = curr_state) then
            if (curr_state = "01") then
                -- change time mode -> initialize to current time
                disp_hr <= curr_time_hr;
                disp_min <= curr_time_min;
                disp_sec <= curr_time_sec;
                disp_AMPM <= curr_time_AMPM;
            elsif (curr_state = "11") then
                -- change alarm mode -> initialize to current alarm
                disp_hr <= curr_alarm_hr;
                disp_min <= curr_alarm_min;
                disp_sec <= curr_alarm_sec;
                disp_AMPM <= curr_alarm_AMPM;
            end if;
            -- set cur_digit to 0 whenever state change
            curr_digit <= "00";
        end if;

        --display current data if in show mode
        if (curr_state = "00") then
            -- show time mode
            disp_hr <= curr_time_hr;
            disp_min <= curr_time_min;
            disp_sec <= curr_time_sec;
            disp_AMPM <= curr_time_AMPM;
        elsif (curr_state = "10") then
            -- show alarm mode
            disp_hr <= curr_alarm_hr;
            disp_min <= curr_alarm_min;
            disp_sec <= curr_alarm_sec;
            disp_AMPM <= curr_alarm_AMPM;
        end if;
        
        -- LEFT RIGHT
        -- go left one place
        if (left_digit_db = '1') then
            if (curr_digit = "10") then
                curr_digit <= "00";
            else
                curr_digit <= curr_digit + "01";
            end if;
        end if;
        
        -- go right one place
        if (right_digit_db = '1') then
            if (curr_digit = "00") then
                curr_digit <= "10";
            else
                curr_digit <= curr_digit - "01";
            end if;
        end if;
        
        -- INCREMENT DECREMENT
        if (curr_state(0) = '1') then
            -- increment digit
            if (inc_digit_db = '1') then
                if (curr_digit = "00") then
                    -- seconds
                    if (disp_sec = 59) then
                        disp_sec <= (others => '0');
                    else
                        disp_sec <= disp_sec + 1;
                    end if;
                elsif (curr_digit = "01") then
                    -- minutes
                    if (disp_min = 59) then
                        disp_min <= (others => '0');
                    else
                        disp_min <= disp_min + 1;
                    end if;
                else 
                    -- hours
                    if (disp_hr = 12) then
                        disp_hr <= "0001";
                        disp_AMPM <= not disp_AMPM;
                    else
                        disp_hr <= disp_hr + 1;
                    end if;
                end if;
            end if;
            
            -- decrement digit
            if (dec_digit_db = '1') then
                if (curr_digit = "00") then
                    -- seconds
                    if (disp_sec = 0) then
                        disp_sec <= "111011";
                    else
                        disp_sec <= disp_sec - 1;
                    end if;
                elsif (curr_digit = "01") then
                    -- minutes
                    if (disp_min = 0) then
                        disp_min <= "111011";
                    else
                        disp_min <= disp_min - 1;
                    end if;
                else 
                    -- hours
                    if (disp_hr = 1) then
                        disp_hr <= "1100";
                        disp_AMPM <= not disp_AMPM;
                    else
                        disp_hr <= disp_hr - 1;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

-- blink current digit if in a change mode
-- hours
hr_out1 <= (others => '1') when (curr_state(0) = '1') and (curr_digit = "10") and (clk_1Hz = '0') else
           temp_hr_out1;
           
hr_out0 <= (others => '1') when (curr_state(0) = '1') and (curr_digit = "10") and (clk_1Hz = '0') else
           temp_hr_out0;
           

-- minutes
min_out1 <= (others => '1') when (curr_state(0) = '1') and (curr_digit = "01") and (clk_1Hz = '0') else
            temp_min_out1;
           
    
min_out0 <= (others => '1') when (curr_state(0) = '1') and (curr_digit = "01") and (clk_1Hz = '0') else
            temp_min_out0;
           

-- seconds
sec_out1 <= (others => '1') when (curr_state(0) = '1') and (curr_digit = "00") and (clk_1Hz = '0') else
           temp_sec_out1;
           
    
sec_out0 <= (others => '1') when (curr_state(0) = '1') and (curr_digit = "00") and (clk_1Hz = '0') else
           temp_sec_out0;

-- hr_out1 <= temp_hr_out1;
-- hr_out0 <= temp_hr_out0;
-- min_out1 <= temp_min_out1;
-- min_out0 <= temp_min_out0;
-- sec_out1 <= temp_sec_out1;
-- sec_out0 <= temp_sec_out0;

AMPM_out <= disp_AMPM;
clk_1Hz_out <= clk_1Hz;

unused_leds <= "0000000";

end Behavioral;
