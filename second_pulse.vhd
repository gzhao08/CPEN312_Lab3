-- on Basys3 the default clock is 100MHz so period is 10^-8
-- on DE1-SoC the defualt clock is 50MHz so period is 20^-8

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity second_pulse is
    port(
        default_clk : in std_logic;
        second_clk : out std_logic
    );
end second_pulse;

architecture Behavioral of second_pulse is

constant TOTAL_COUNT : integer := 50000000;

signal counter : unsigned(25 downto 0) := (others => '0');

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
second_clk <= '1' when (counter <= TOTAL_COUNT/2-1) else '0';

end Behavioral;
