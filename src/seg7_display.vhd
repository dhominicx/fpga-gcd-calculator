library ieee;
use ieee.std_logic_1164.all;

entity seg7_display is
	port(
		INPUT : in std_logic_vector(3 downto 0); -- 2^4 valeurs = 0...F
		SEG   : out std_logic_vector(6 downto 0) -- 7 segments en sortie
	);
end entity;

architecture behavioral of seg7_display is
begin
	with INPUT select
	SEG <= 	"0111111" when "0000",  --0
		"0000110" when "0001",  --1
		"1011011" when "0010",  --2
		"1001111" when "0011",  --3
		"1100110" when "0100",  --4
		"1101101" when "0101",  --5
		"1111101" when "0110",  --6
		"0000111" when "0111",  --7
		"1111111" when "1000",  --8
		"1101111" when "1001",  --9
		"1110111" when "1010",  --A
		"1111100" when "1011",  --B
		"0111001" when "1100",  --C
		"1011110" when "1101",  --D
		"1111001" when "1110",  --E
		"1110001" when "1111",  --F
		"0000000" when others;  --blanc s'il n'y a pas de digit

end architecture;
