library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
  generic (
    CLK_HZ      : integer := 50000000;
    DEBOUNCE_MS : integer := 40
  );
  port (
    clk        : in  std_logic;
    btn_raw    : in  std_logic;
    btn_pulse  : out std_logic
  );
end debounce;

architecture rtl of debounce is

  constant N_STABLE : integer := (CLK_HZ/1000)*DEBOUNCE_MS;
  constant CNT_BITS : integer := 20; -- enough for ~1M cycles

  signal ff1, ff2      : std_logic := '0';
  signal stable_cnt    : unsigned(CNT_BITS-1 downto 0) := (others=>'0');
  signal last_sample   : std_logic := '0';
  signal debounced     : std_logic := '0';
  signal debounced_d   : std_logic := '0';

begin

  -- 1) Synchronizer (metastability protection)
  process(clk)
  begin
    if rising_edge(clk) then
      ff1 <= btn_raw;
      ff2 <= ff1;
    end if;
  end process;

  -- 2) Debounce logic
  process(clk)
  begin
    if rising_edge(clk) then

      if ff2 = last_sample then
        if stable_cnt < to_unsigned(N_STABLE-1, CNT_BITS) then
          stable_cnt <= stable_cnt + 1;
        else
          debounced <= last_sample;
        end if;
      else
        last_sample <= ff2;
        stable_cnt  <= (others=>'0');
      end if;

      debounced_d <= debounced;
    end if;
  end process;

  -- 3) One-clock pulse on rising edge
  btn_pulse <= debounced and not debounced_d;

end rtl;