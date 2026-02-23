-- stores the current time (hr-min-sec-AMP/PM) as well as the current alarm setting (hr-min-sec-AM/PM)
-- should trigger the alarm independent of what state the display is in


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity timekeep is
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
end timekeep;

architecture Behavioral of timekeep is
-- initialize time to 12:00 AM
signal time_hr : unsigned(3 downto 0) := "1100"; -- 12
signal time_min : unsigned(5 downto 0) := "000000"; -- 0
signal time_sec : unsigned(5 downto 0) := "000000"; -- 0
signal time_AMPM : std_logic := '0'; -- AM 

-- initialize alarm to 6:00 AM
signal alarm_hr : unsigned(3 downto 0) := "0110"; -- 6
signal alarm_min : unsigned(5 downto 0) := "000000"; -- 0
signal alarm_sec : unsigned(5 downto 0) := "000000"; -- 0
signal alarm_AMPM : std_logic := '0'; -- AM 

signal curr_second_clk : std_logic;
signal prev_second_clk : std_logic;
signal rising_second_clk : std_logic;




begin

-- store the previous state of the 1Hz clock to determine edge
process (default_clk)
begin
    if rising_edge(default_clk) then
        prev_second_clk <= curr_second_clk;
        curr_second_clk <= second_clk;
    end if;
end process;

-- update time every second
-- AND for writing new time or alarm
process (default_clk)
begin
    if rising_edge(default_clk) then
        if (rising_second_clk = '1') then
            -- for 11:59:59 go to 12:00:00 and flip AM/PM
            if ((time_hr = 11) and (time_min = 59) and (time_sec = 59)) then
                time_hr <= "1100";
                time_min <= "000000";
                time_sec <= "000000";
                time_AMPM <= not time_AMPM;
                
            -- for xx:59:59 go to xx+1:00:00
            elsif ((time_min = 59) and (time_sec = 59)) then
                if (time_hr = 12) then
                    time_hr <= "0001";
                else
                    time_hr <= time_hr + "0001";
                end if;
                
                time_min <= "000000";
                time_sec <= "000000";
            
            -- for xx:yy:59 go to xx:yy+1:00
            elsif (time_sec = 59) then
                time_min <= time_min + "000001";
                time_sec <= "000000";
                
            -- otherwise just increment the seconds    
            else 
                time_sec <= time_sec + "000001";
            end if;
            
            -- changing the time
            if (write_en = '1') then
                if (write_sel = '0') then
                    -- update time
                    time_hr <= hour_in;
                    time_min <= minute_in;
                    time_sec <= second_in;
                    time_AMPM <= AMPM_in;
                else
                    -- update alarm
                    alarm_hr <= hour_in;
                    alarm_min <= minute_in;
                    alarm_sec <= second_in;
                    alarm_AMPM <= AMPM_in;
                end if;
            end if;
            
        end if;
    end if;
end process;

alarm_active <= '1' when
    (alarm_en = '1') and
    (time_hr = alarm_hr) and
    (time_min = alarm_min) and
    (time_AMPM = alarm_AMPM)
else
    '0';

curr_time_hr <= time_hr;
curr_time_min  <= time_min;
curr_time_sec <= time_sec;
curr_time_AMPM <= time_AMPM;

curr_alarm_hr <= alarm_hr;
curr_alarm_min  <= alarm_min;
curr_alarm_sec <= alarm_sec;
curr_alarm_AMPM <= alarm_AMPM;

-- rising edge on 1Hz signal
rising_second_clk <= '1' when (prev_second_clk = '0') and (curr_second_clk = '1') else '0';


end Behavioral;
