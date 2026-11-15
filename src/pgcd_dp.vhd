library ieee;
use ieee.std_logic_1164.all;

--  pgcd_dp : Partie Operative (chemin de donnees)
--  Calcule le PGCD de X et Y sur N bits

--  Schema interne:

--   X -> mux_x (SEL=0->outsub, SEL=1->X) -> reg_x (LOAD_X) -> qx
--   Y -> mux_y (SEL=0->outsub, SEL=1->Y) -> reg_y (LOAD_Y) -> qy

--   qx -> mux_selxy_x (SEL_XY=0->qx, 1->outsub) -> sub_a ???
--   qy -> mux_selxy_y (SEL_XY=0->qy, 1->outsub) -> sub_b ???-> subn -> outsub

--   qx, qy -> compn -> XEQY, XGTY
--   qx -> OUTPUT  (le resultat final est dans reg_x)

entity pgcd_dp is
    generic(N : integer := 16);
    port(
        CLK    : in  std_logic;
        RST    : in  std_logic;
        X      : in  std_logic_vector(N-1 downto 0);
        Y      : in  std_logic_vector(N-1 downto 0);
        SEL    : in  std_logic;       -- 1 => charge entree X/Y, 0 => charge outsub
        LOAD_X : in  std_logic;
        LOAD_Y : in  std_logic;
        SEL_XY : in  std_logic;       -- 1 => A=qx B=outsub,  0 => A=qx B=qy
        OUTPUT : out std_logic_vector(N-1 downto 0);
        XEQY   : out std_logic;
        XGTY   : out std_logic
    );
end pgcd_dp;

architecture structural of pgcd_dp is

    -- ---- signaux internes ----
    signal qx       : std_logic_vector(N-1 downto 0);  -- sortie reg X
    signal qy       : std_logic_vector(N-1 downto 0);  -- sortie reg Y
    signal outsub   : std_logic_vector(N-1 downto 0);  -- sortie soustractor
    signal d_regx   : std_logic_vector(N-1 downto 0);  -- entree reg X
    signal d_regy   : std_logic_vector(N-1 downto 0);  -- entree reg Y
    signal sub_a    : std_logic_vector(N-1 downto 0);  -- operande A du soustractor
    signal sub_b    : std_logic_vector(N-1 downto 0);  -- operande B du soustractor
    signal bout_unused : std_logic;

    -- ---- declarations de composants ----
    component muxn
        generic(N : integer);
        port(
            X      : in  std_logic_vector(N-1 downto 0);
            Y      : in  std_logic_vector(N-1 downto 0);
            SEL    : in  std_logic;
            OUTPUT : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component registre
        generic(N : integer);
        port(
            D    : in  std_logic_vector(N-1 downto 0);
            RST  : in  std_logic;
            LOAD : in  std_logic;
            CLK  : in  std_logic;
            Q    : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component subtractor_n
        generic(N : integer);
        port(
            A    : in  std_logic_vector(N-1 downto 0);
            B    : in  std_logic_vector(N-1 downto 0);
            Bin  : in  std_logic;
            Diff : out std_logic_vector(N-1 downto 0);
            Bout : out std_logic
        );
    end component;

    component compn
        generic(N : integer);
        port(
            X    : in  std_logic_vector(N-1 downto 0);
            Y    : in  std_logic_vector(N-1 downto 0);
            xeqy : out std_logic;
            xgty : out std_logic
        );
    end component;

begin

    -- Couche 1: mux d'entree des registres
    --   SEL=1 => on charge l'entree externe X (ou Y)
    --   SEL=0 => on charge le resultat du soustractor
    mux_regx : muxn
        generic map(N => N)
        port map(
            X      => outsub,   -- SEL=0
            Y      => X,        -- SEL=1
            SEL    => SEL,
            OUTPUT => d_regx
        );

    mux_regy : muxn
        generic map(N => N)
        port map(
            X      => outsub,   -- SEL=0
            Y      => Y,        -- SEL=1
            SEL    => SEL,
            OUTPUT => d_regy
        );

    -- Couche 2: registres X et Y
    reg_x : registre
        generic map(N => N)
        port map(
            D    => d_regx,
            RST  => RST,
            LOAD => LOAD_X,
            CLK  => CLK,
            Q    => qx
        );

    reg_y : registre
        generic map(N => N)
        port map(
            D    => d_regy,
            RST  => RST,
            LOAD => LOAD_Y,
            CLK  => CLK,
            Q    => qy
        );

    -- Couche 3: mux de selection pour le soustractor
    --   SEL_XY=0 => A=qx, B=qy  (X-Y ou Y-X selon l'etat FSM)
    --   SEL_XY=1 => A=qx, B=outsub (cas XMINY: on refait X-outsub)

    --   En pratique:
    --     etat XMINY : on veut X - Y  -> sub_a=qx, sub_b=qy  (SEL_XY=1)
    --     etat YMINX : on veut Y - X  -> sub_a=qy, sub_b=qx  (SEL_XY=0)
    mux_suba : muxn
        generic map(N => N)
        port map(
            X      => qy,       -- SEL_XY=0 -> Y-X: A=qy
            Y      => qx,       -- SEL_XY=1 -> X-Y: A=qx
            SEL    => SEL_XY,
            OUTPUT => sub_a
        );

    mux_subb : muxn
        generic map(N => N)
        port map(
            X      => qx,       -- SEL_XY=0 -> Y-X : B=qx
            Y      => qy,       -- SEL_XY=1 -> X-Y : B=qy
            SEL    => SEL_XY,
            OUTPUT => sub_b
        );

    -- Couche 4: soustractor N bits
    sub_inst : subtractor_n
        generic map(N => N)
        port map(
            A    => sub_a,
            B    => sub_b,
            Bin  => '0',
            Diff => outsub,
            Bout => bout_unused
        );

    -- Comparateur: compare les valeurs courantes des registres
    cmp_inst : compn
        generic map(N => N)
        port map(
            X    => qx,
            Y    => qy,
            xeqy => XEQY,
            xgty => XGTY
        );

    -- Le resultat final est la valeur du registre X
    OUTPUT <= qx;

end structural;