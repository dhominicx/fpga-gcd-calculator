library ieee;
use ieee.std_logic_1164.all;

--  pgcd : entite top-level
--  Assemble pgcd_dp (PO) et pgcd_fsm (PC)

entity pgcd is
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
end pgcd;

architecture structural of pgcd is

    -- Signaux d'interface PC <-> PO
    signal s_SEL    : std_logic;
    signal s_LOAD_X : std_logic;
    signal s_LOAD_Y : std_logic;
    signal s_SEL_XY : std_logic;
    signal s_XEQY   : std_logic;
    signal s_XGTY   : std_logic;

    component pgcd_dp
        generic(N : integer);
        port(
            CLK    : in  std_logic;
            RST    : in  std_logic;
            X      : in  std_logic_vector(N-1 downto 0);
            Y      : in  std_logic_vector(N-1 downto 0);
            SEL    : in  std_logic;
            LOAD_X : in  std_logic;
            LOAD_Y : in  std_logic;
            SEL_XY : in  std_logic;
            OUTPUT : out std_logic_vector(N-1 downto 0);
            XEQY   : out std_logic;
            XGTY   : out std_logic
        );
    end component;

    component pgcd_fsm
        generic(N : integer);
        port(
            CLK    : in  std_logic;
            RST    : in  std_logic;
            GO     : in  std_logic;
            XEQY   : in  std_logic;
            XGTY   : in  std_logic;
            SEL    : out std_logic;
            LOAD_X : out std_logic;
            LOAD_Y : out std_logic;
            SEL_XY : out std_logic;
            DONE   : out std_logic
        );
    end component;

begin

    -- Partie Operatve
    U_PO : pgcd_dp
        generic map(N => N)
        port map(
            CLK    => CLK,
            RST    => RST,
            X      => X,
            Y      => Y,
            SEL    => s_SEL,
            LOAD_X => s_LOAD_X,
            LOAD_Y => s_LOAD_Y,
            SEL_XY => s_SEL_XY,
            OUTPUT => OUTPUT,
            XEQY   => s_XEQY,
            XGTY   => s_XGTY
        );

    -- Partie Controle
    U_PC : pgcd_fsm
        generic map(N => N)
        port map(
            CLK    => CLK,
            RST    => RST,
            GO     => GO,
            XEQY   => s_XEQY,
            XGTY   => s_XGTY,
            SEL    => s_SEL,
            LOAD_X => s_LOAD_X,
            LOAD_Y => s_LOAD_Y,
            SEL_XY => s_SEL_XY,
            DONE   => DONE
        );

end structural;