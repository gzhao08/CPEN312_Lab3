library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_control is
    port(
        default_clk : in std_logic;
        change_time_mode : in std_logic;   -- press to change from show time to change time
        change_alarm_mode : in std_logic;  -- press to change from show alarm to change alarm
        alarm_en : in std_logic;
        inc_digit : in std_logic;           -- increment current digit (must be in change mode)
        dec_digit : in std_logic;           -- decrement current digit (must be in change mode)
        left : in std_logic;                -- go left one place (i.e. seconds to minutes, or minutes to hour)
        right : in std_logic;               -- go right one place
        set : in std_logic;                 -- set the time or alarm (i.e. write enable for changing the time or alarm)
        hr_out1 : out std_logic_vector(6 downto 0);
        hr_out0 : out std_logic_vector(6 downto 0);
        min_out1 : out std_logic_vector(6 downto 0);
        min_out0 : out std_logic_vector(6 downto 0);
        sec_out1 : out std_logic_vector(6 downto 0);
        sec_out0 : out std_logic_vector(6 downto 0);
        AMPM_out : out std_logic;
        alarm_triggered : out std_logic
    );
end clock_control;

architecture Behavioral of clock_control is
signal curr_state : std_logic_vector(1 downto 0) := "00";
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

-- COMPONENTS
component second_pulse is
        port(
            default_clk : in std_logic;
            second_clk : out std_logic
        );
end component second_pulse;

component timekeep is
        port(
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
            second_clk : in std_logic;
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
            second_clk => clk_1Hz,
            hour_in => disp_hr,
            minute_in => disp_min,
            second_in => disp_sec,
            AMPM_in => disp_AMPM,
            write_sel => curr_state(1),
            write_en => (set and curr_state(0)),
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
            second_clk => clk_1Hz,
            hr_in => disp_hr,
            min_in => disp_min,
            sec_in => disp_sec,
            AMPM_in => disp_AMPM,
            hr_out1 => hr_out1,
            hr_out0 => hr_out0,
            min_out1 => min_out1,
            min_out0 => min_out0,
            sec_out1 => sec_out1,
            sec_out0 => sec_out0
        );
        
U2: second_pulse
        port map (
            default_clk => default_clk,
            second_clk => clk_1Hz
        );



-- change time mode button pressed
process(change_time_mode)
begin
    if rising_edge(change_time_mode) then
        if (curr_state = "00") then
            -- in time state so go to other time state
            curr_state <= "01";
            curr_digit <= "00";
        elsif (curr_state = "01") then
            curr_state <= "00";
        else    
            -- if in an alarm state, go to show time state
            curr_state <= "00";
        end if;
        
        -- initialize display to current time
        disp_hr <= curr_time_hr;
        disp_min <= curr_time_min;
        disp_sec <= curr_time_sec;
        disp_AMPM <= curr_time_AMPM;
        
    end if;
end process;

-- change alarm mode button pressed
process(change_alarm_mode)
begin
    if rising_edge(change_alarm_mode) then
        if (curr_state = "10") then
            curr_state <= "11";
            curr_digit <= "00";
        elsif (curr_state = "11") then
            curr_state <= "10";
        else    
            -- if in a time state, go to show alarm state
            curr_state <= "10";
        end if;
        
        -- initialize display to current alarm
        disp_hr <= curr_alarm_hr;
        disp_min <= curr_alarm_min;
        disp_sec <= curr_alarm_sec;
        disp_AMPM <= curr_alarm_AMPM;
    end if;
end process;

-- increment digit
process(inc_digit)
begin
    if ((curr_state(0) = '1') and rising_edge(inc_digit)) then
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
end process;

-- decrement digit
process(dec_digit)
begin
    if ((curr_state(0) = '1') and rising_edge(dec_digit)) then
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
end process;

-- changing digit
process(left,right)
begin
    if rising_edge(left) then
        if (curr_digit = "10") then
            curr_digit <= "00";
        else
            curr_digit <= curr_digit + "01";
        end if;
    end if;
    if rising_edge(right) then
        if (curr_digit = "00") then
            curr_digit <= "10";
        else
            curr_digit <= curr_digit - "01";
        end if;
    end if;
end process;

end Behavioral;
