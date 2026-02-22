-- on Basys3 the default clock is 100MHz so period is 10^-8
-- on DE1-SoC the defualt clock is 50MHz so period is 20^-8

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity second_pulse is
    generic (
        BOARD : integer := 0  -- 0 = basys3, 1 = DE1-SoC
    );
    port(
        default_clk : in std_logic;
        second_clk : out std_logic
    );
end second_pulse;

architecture Behavioral of second_pulse is

constant TOTAL_COUNT : integer := 
    100000000 when BOARD = 0 else
    50000000;

signal counter : std_logic_vector(0 to 23) := (others => '0');

begin

-- count TOTAL_COUNT ticks from the defualt clock for 1 second
process(default_clk)
begin
  if rising_edge(default_clk) then
    if (counter >= TOTAL_COUNT-1) then
        counter <= (others => '0');
    else
        counter <= counter + 1;
    end if;
  end if;
end process;

-- tick the second hand every half cycle
process(counter)
begin
    if (counter <= TOTAL_COUNT/2-1) then
        second_clk <= '1';
    else 
        second_clk <= '0';
    end if;
end process;

end Behavioral;
