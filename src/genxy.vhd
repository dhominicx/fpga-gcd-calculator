library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity genxy is
	generic(
		N : natural
	);
	port(
		SWITCH : in  std_logic_vector(3 downto 0);
		X      : out std_logic_vector(N-1 downto 0);
		Y      : out std_logic_vector(N-1 downto 0)
	);
end entity;

architecture behavioral of genxy is
	type lue_t is array (0 to  1) of std_logic_vector(15 downto 0);
	type lut_t is array (0 to 15) of lue_t;

	constant tab : lut_t := ( -- x, y => pgdc(x,y)
		(X"0100", X"0200"), -- 256, 512 => 256 (0x0100)
		(X"0110", X"0090"), -- 272, 144 => 16  (0x0010)
		(X"0120", X"0220"), -- 288, 544 => 32  (0x0020)
		(X"0014", X"001E"), --  20,  30 => 10  (0x000A)
		(X"0024", X"003C"), --  36,  60 => 12  (0x000C)
		(X"CAFE", X"CAFE"), -- => (0xCAFE)
		(X"DEAD", X"DEAD"), -- => (0xDEAD)
		(X"007E", X"0117"), -- 126, 279 => 9 (0x0009)
		(X"F00D", X"F00D"), -- 61453, 61453 => 61453 (0xFOOD)
		(X"01B3", X"001D"), -- 435,  29 => 29 (0x001D)
		(X"01B3", X"0105"), -- 435, 261 => 87 (0x0057)
		(X"3578", X"5034"), -- 13688, 20532 => 6844 (1ABC)
		(X"1EF1", X"3DE2"), -- 7921, 15842 => 7921 (1EF1)
		(X"CAFE", X"100D"), -- 51966, 4109 => 1
		(X"BABE", X"100D"), -- 47806, 4109 => 1
		(X"DEAD", X"1EEF")  -- 57005, 7919 => 1
	);

	signal X_S : std_logic_vector(15 downto 0);
	signal Y_S : std_logic_vector(15 downto 0);

begin

	with SWITCH select X_S <=
		tab(0)(0) when X"0",
		tab(1)(0) when X"1",
		tab(2)(0) when X"2",
		tab(3)(0) when X"3",
		tab(4)(0) when X"4",
		tab(5)(0) when X"5",
		tab(6)(0) when X"6",
		tab(7)(0) when X"7",
		tab(8)(0) when X"8",
		tab(9)(0) when X"9",
		tab(10)(0) when X"A",
		tab(11)(0) when X"B",
		tab(12)(0) when X"C",
		tab(13)(0) when X"D",
		tab(14)(0) when X"E",
		tab(15)(0) when X"F",
		X"DEAD" when others;

	with SWITCH select Y_S <=
		tab(0)(1) when X"0",
		tab(1)(1) when X"1",
		tab(2)(1) when X"2",
		tab(3)(1) when X"3",
		tab(4)(1) when X"4",
		tab(5)(1) when X"5",
		tab(6)(1) when X"6",
		tab(7)(1) when X"7",
		tab(8)(1) when X"8",
		tab(9)(1) when X"9",
		tab(10)(1) when X"A",
		tab(11)(1) when X"B",
		tab(12)(1) when X"C",
		tab(13)(1) when X"D",
		tab(14)(1) when X"E",
		tab(15)(1) when X"F",
		X"BEEF" when others;

	X <= X_S;
	Y <= Y_S;

end architecture behavioral;

