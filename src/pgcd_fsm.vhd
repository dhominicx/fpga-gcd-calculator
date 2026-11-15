library ieee;
use ieee.std_logic_1164.all;

--  pgcd_fsm : Partie Controle (machine a etats de Moore)
--
--  Etats et sorties (tableau du sujet) :
--  STATE   | SEL LOAD_X LOAD_Y SEL_XY DONE
--  START   |  0    0      0      0     0
--  INIT    |  1    1      1      0     0
--  TEST    |  0    0      0      0     0
--  XMINY   |  0    1      0      1     0
--  YMINX   |  0    0      1      0     0
--  RES     |  0    0      0      0     1
--
--  Transitions (voir Figure 3 du sujet) :
--  START  --GO=0-->   START
--  START  --GO=1-->   INIT
--  INIT   ----------> TEST
--  TEST   --XGTY^XEQY (X=Y)     --> RES
--  TEST   --XGTY^~XEQY (X>Y)    --> XMINY
--  TEST   --~XGTY^~XEQY (Y>X)   --> YMINX
--  TEST   --~XGTY^XEQY (X=Y)    --> RES   (meme condition que XGTY^XEQY)
--  XMINY  ----------> TEST
--  YMINX  ----------> TEST
--  RES    ----------> RES  (boucle, attend nouveau cycle)

entity pgcd_fsm is
    generic(N : integer := 16);
    port(
        CLK    : in  std_logic;
        RST    : in  std_logic;   -- reset asynchrone actif haut
        GO     : in  std_logic;
        XEQY   : in  std_logic;
        XGTY   : in  std_logic;
        SEL    : out std_logic;
        LOAD_X : out std_logic;
        LOAD_Y : out std_logic;
        SEL_XY : out std_logic;
        DONE   : out std_logic
    );
end pgcd_fsm;

architecture fsm of pgcd_fsm is

    type fsm_state is (START, INIT, TEST, XMINY, YMINX, RES);
    signal current_state : fsm_state;
    signal next_state    : fsm_state;

begin

    -- Processus sequentiel: mise a jour de l'etat
    state_p : process(CLK, RST)
    begin
        if RST = '1' then
            current_state <= START;
        elsif CLK = '1' and CLK'EVENT then
            current_state <= next_state;
        end if;
    end process;

    -- Processus combinatoire: calcul du prochain etat
    transition_p : process(current_state, GO, XEQY, XGTY)
    begin
        case current_state is

            when START =>
                if GO = '1' then
                    next_state <= INIT;
                else
                    next_state <= START;
                end if;

            when INIT =>
                next_state <= TEST;

            when TEST =>
                if XEQY = '1' then
                    -- X = Y : PGCD trouve
                    next_state <= RES;
                elsif XGTY = '1' then
                    -- X > Y : on soustrait Y de X
                    next_state <= XMINY;
                else
                    -- Y > X : on soustrait X de Y
                    next_state <= YMINX;
                end if;

            when XMINY =>
                next_state <= TEST;

            when YMINX =>
                next_state <= TEST;

            when RES =>
                next_state <= RES;

            when others =>
                next_state <= START;

        end case;
    end process;

    -- Processus combinatoire: generation des sorties (Moore)
    -- Les sorties dependent uniquement de l'etat courant
    output_p : process(current_state)
    begin
        -- Valeurs par defaut
        SEL    <= '0';
        LOAD_X <= '0';
        LOAD_Y <= '0';
        SEL_XY <= '0';
        DONE   <= '0';

        case current_state is
            when START =>
                SEL    <= '0';
                LOAD_X <= '0';
                LOAD_Y <= '0';
                SEL_XY <= '0';
                DONE   <= '0';

            when INIT =>
                -- Charge les entrees X et Y dans les registres
                SEL    <= '1';
                LOAD_X <= '1';
                LOAD_Y <= '1';
                SEL_XY <= '0';
                DONE   <= '0';

            when TEST =>
                SEL    <= '0';
                LOAD_X <= '0';
                LOAD_Y <= '0';
                SEL_XY <= '0';
                DONE   <= '0';

            when XMINY =>
                -- X = X - Y : on charge le resultat du soustractor dans reg_x
                SEL    <= '0';
                LOAD_X <= '1';
                LOAD_Y <= '0';
                SEL_XY <= '1';   -- sub_a=qx, sub_b=qy  => outsub = X-Y
                DONE   <= '0';

            when YMINX =>
                -- Y = Y - X : on charge le resultat du soustractor dans reg_y
                SEL    <= '0';
                LOAD_X <= '0';
                LOAD_Y <= '1';
                SEL_XY <= '0';   -- sub_a=qy, sub_b=qx  => outsub = Y-X
                DONE   <= '0';

            when RES =>
                SEL    <= '0';
                LOAD_X <= '0';
                LOAD_Y <= '0';
                SEL_XY <= '0';
                DONE   <= '1';

            when others =>
                null;
        end case;
    end process;

end fsm;