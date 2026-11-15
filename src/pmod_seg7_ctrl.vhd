library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pmod_seg7_ctrl is
    port(
        clk    : in  std_logic;
        rst    : in  std_logic;
        in_val : in  std_logic_vector(7 downto 0);
        cat    : out std_logic;
        seg    : out std_logic_vector(6 downto 0)
    );
end pmod_seg7_ctrl;

architecture structural of pmod_seg7_ctrl is
    constant CNT_WIDTH : integer := 21; -- Aprox 60 hz
    constant CNT_MAX   : unsigned(CNT_WIDTH - 1 downto 0) := (others => '1');

    signal cnt       : unsigned(CNT_WIDTH - 1 downto 0):= (others => '0');
    signal digit_sel : std_logic;
    signal digit_val : std_logic_vector(3 downto 0);


    component seg7_display is
        port(
            indig7 : in  std_logic_vector(3 downto 0);
            outdig7 : out std_logic_vector(6 downto 0)
        );
    end component;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            cnt <= (others => '0');
        elsif rising_edge(clk) then
            if cnt = CNT_MAX then
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    digit_sel <= std_logic(cnt(cnt'high)); -- returns the value of the MSB
    cat <= digit_sel;

    with digit_sel select
        digit_val <= in_val(3 downto 0) when '0',
                     in_val(7 downto 4) when others;

    U_SEG7 : seg7_display
        port map(
            indig7  => digit_val,
            outdig7 => seg
        );
end structural;
