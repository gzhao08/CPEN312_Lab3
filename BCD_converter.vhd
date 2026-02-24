library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BCD_converter is
    port(
        input   : in  unsigned(5 downto 0);      -- 6-bit unsigned (0..63)
        tens : out std_logic_vector(3 downto 0); -- tens
        ones : out std_logic_vector(3 downto 0)  -- ones
    );
end BCD_converter;

architecture Behavioral of BCD_converter is
signal temp_tens : std_logic_vector(5 downto 0);
signal temp_ones : std_logic_vector(5 downto 0);
begin


temp_tens <= std_logic_vector(input / 10);
temp_ones <= std_logic_vector(input mod 10);
tens <= temp_tens(3 downto 0);
ones <= temp_ones(3 downto 0);

end Behavioral;