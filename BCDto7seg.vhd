library ieee;
use ieee.std_logic_1164.all;

entity BCDto7Seg is
	port
	(
		-- Input ports
		BCD	: in  STD_LOGIC_VECTOR (3 downto 0);
		-- Output ports
		DISPLAY	: out STD_LOGIC_VECTOR(0 to 6)
	);
end BCDto7Seg;

architecture Behavioral of BCDto7Seg is
	-- Declarations (optional)
	signal bcd_in : STD_LOGIC_VECTOR(3 downto 0);
	signal display_out: STD_LOGIC_VECTOR(0 to 6);
	
begin
	bcd_in<=BCD;
	DISPLAY<=display_out;

	process(bcd_in) is
		-- Declaration(s)
	begin
		-- Sequential Statement(s)
		case bcd_in is
			when "0000" => display_out <= "1000000"; -- 0
		   when "0001" => display_out <= "1111001"; -- 1
		   when "0010" => display_out <= "0100100"; -- 2
		   when "0011" => display_out <= "0110000"; -- 3
		   when "0100" => display_out <= "0011001"; -- 4
		   when "0101" => display_out <= "0010010"; -- 5
		   when "0110" => display_out <= "0000010"; -- 6
		   when "0111" => display_out <= "1111000"; -- 7
		   when "1000" => display_out <= "0000000"; -- 8
		   when "1001" => display_out <= "0010000"; -- 9
		   when others => display_out <= "0111111"; -- blank (all OFF)
		end case;
	
	end process;


end Behavioral;
