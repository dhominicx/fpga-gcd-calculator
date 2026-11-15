library ieee;
use ieee.std_logic_1164.all;

entity pgcd_top is
    port(
        CLK       : in  std_logic;
        RST       : in  std_logic;
        GO        : in  std_logic;
        SWITCH    : in  std_logic_vector(3 downto 0);
        READY     : out std_logic;
        PMOD1     : out std_logic_vector(6 downto 0);
        PMOD2     : out std_logic_vector(6 downto 0);
        SEL_DIGIT : out std_logic_vector(1 downto 0)
    );
end pgcd_top;

architecture structural of pgcd_top is
    signal s_x      : std_logic_vector(15 downto 0);
    signal s_y      : std_logic_vector(15 downto 0);
    signal s_output : std_logic_vector(15 downto 0);
    signal s_done   : std_logic;
    signal s_cat_0  : std_logic;
    signal s_cat_1  : std_logic;

    component genxy is
        generic(N : integer := 16);
        port(
            SWITCH : in  std_logic_vector(3 downto 0);
            X      : out std_logic_vector(15 downto 0);
            Y      : out std_logic_vector(15 downto 0)
        );
    end component;

    component pgcd is
        generic(N : integer := 16);
        port(
            CLK    : in  std_logic;
            RST    : in  std_logic;
            GO     : in  std_logic;
            X      : in  std_logic_vector(N-1 downto 0);
            Y      : in  std_logic_vector(N-1 downto 0);
            DONE   : out std_logic;
            OUTPUT : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component pmod_seg7_ctrl is
        port(
            clk    : in  std_logic;
            rst    : in  std_logic;
            in_val : in  std_logic_vector(7 downto 0);
            cat    : out std_logic;
            seg    : out std_logic_vector(6 downto 0)
        );
    end component;
begin
    U_GENXY : genxy
        generic map(N => 16)
        port map(
            SWITCH => SWITCH,
            X      => s_x,
            Y      => s_y
        );

    U_PGCD : pgcd
        generic map(N => 16)
        port map(
            CLK    => CLK,
            RST    => RST,
            GO     => GO,
            X      => s_x,
            Y      => s_y,
            DONE   => s_done,
            OUTPUT => s_output
        );

    U_PMOD_LOW : pmod_seg7_ctrl
        port map(
            clk    => CLK,
            rst    => RST,
            in_val => s_output(7 downto 0),
            cat    => s_cat_0,
            seg    => PMOD1
        );

    U_PMOD_HIGH : pmod_seg7_ctrl
        port map(
            clk    => CLK,
            rst    => RST,
            in_val => s_output(15 downto 8),
            cat    => s_cat_1,
            seg    => PMOD2
        );

    READY <= s_done;
    SEL_DIGIT <= s_cat_1 & s_cat_0;
end structural;
