library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_controller is
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
end display_controller;

architecture Behavioral of display_controller is


---------------------------------------
--COMPONENTS
component BCD_converter is
        port(
            input   : in  unsigned(5 downto 0);
            tens : out std_logic_vector(3 downto 0); -- tens
            ones : out std_logic_vector(3 downto 0)  -- ones
        );
end component BCD_converter;

component BCDto7seg is
        port(
            BCD	: in  STD_LOGIC_VECTOR (3 downto 0);
            DISPLAY	: out STD_LOGIC_VECTOR(0 to 6)
        );
end component BCDto7seg;
---------------------------------------------

signal hr1 : std_logic_vector(3 downto 0);
signal hr0 : std_logic_vector(3 downto 0);
signal min1 : std_logic_vector(3 downto 0);
signal min0 : std_logic_vector(3 downto 0);
signal sec1 : std_logic_vector(3 downto 0);
signal sec0 : std_logic_vector(3 downto 0);


begin

--- BCD CONVERSION
U0: BCD_converter
        port map (
            input => ("00" & hr_in),
            tens  => hr1,
            ones  => hr0
        );
  
U1: BCD_converter
        port map (
            input => min_in,
            tens  => min1,
            ones  => min0
        );

U2: BCD_converter
        port map (
            input => sec_in,
            tens  => sec1,
            ones  => sec0
        );
        
-- 7SEG CONVERSION
S0: BCDto7seg
        port map (
            BCD => hr1,
            DISPLAY  => hr_out1
        );
        
S1: BCDto7seg
        port map (
            BCD => hr0,
            DISPLAY  => hr_out0
        );

S2: BCDto7seg
        port map (
            BCD => min1,
            DISPLAY  => min_out1
        );
        
S3: BCDto7seg
        port map (
            BCD => min0,
            DISPLAY  => min_out0
        );        

S4: BCDto7seg
        port map (
            BCD => sec1,
            DISPLAY  => sec_out1
        );

S5: BCDto7seg
        port map (
            BCD => sec0,
            DISPLAY  => sec_out0
        );

end Behavioral;
