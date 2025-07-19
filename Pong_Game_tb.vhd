library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pong_Game_Logic_tb is
end entity;

architecture tb of Pong_Game_Logic_tb is

    component Pong_Game_Logic is
        port (
            i_Clk : in std_logic;
            i_Game_Start : in std_logic;

            i_Paddle_Up_P1 : in std_logic;
            i_Paddle_Up_P2 : in std_logic;
            i_Paddle_Dn_P1 : in std_logic;
            i_Paddle_Dn_P2 : in std_logic;

            o_VGA_HSync : out std_logic;
            o_VGA_VSync : out std_logic;

            o_VGA_Red : out std_logic_vector(2 downto 0);
            o_VGA_Grn : out std_logic_vector(2 downto 0);
            o_VGA_Blu : out std_logic_vector(2 downto 0);

            o_Score_P1 : out std_logic_vector(3 downto 0);
            o_Score_P2 : out std_logic_vector(3 downto 0)
        );
    end component;

    constant clk_period : time := 10 ns;

    signal clk         : std_logic := '0';
    signal game_start  : std_logic := '0';
    signal paddle_up_p1, paddle_dn_p1 : std_logic := '0';
    signal paddle_up_p2, paddle_dn_p2 : std_logic := '0';

    signal hsync, vsync : std_logic;
    signal red, grn, blu : std_logic_vector(2 downto 0);
    signal score_p1, score_p2 : std_logic_vector(3 downto 0);

begin

    clk <= not clk after clk_period/2;


    DUT: Pong_Game_Logic
        port map (   
            i_Clk => clk,
            i_Game_Start => game_start,

            i_Paddle_Up_P1 => paddle_up_p1,
            i_Paddle_Dn_P1 => paddle_dn_p1,
            i_Paddle_Up_P2 => paddle_up_p2,
            i_Paddle_Dn_P2 => paddle_dn_p2,

            o_VGA_HSync => hsync,
            o_VGA_VSync => vsync,

            o_VGA_Red => red,
            o_VGA_Grn => grn,
            o_VGA_Blu => blu,

            o_Score_P1 => score_p1,
            o_Score_P2 => score_p2
        );

    stim_proc : process
begin


    wait for 100 ns;
    game_start <= '1';
    wait for 20 ns;
    game_start <= '0';

    wait for 200 us;

    for i in 0 to 3 loop
        paddle_dn_p1 <= '1';
        wait for 100 us;
        paddle_dn_p1 <= '0';
        wait for 50 us;
    end loop;

    wait for 1 ms;

    for i in 0 to 2 loop
        paddle_up_p2 <= '1';
        wait for 80 us;
        paddle_up_p2 <= '0';
        wait for 60 us;
    end loop;

    wait for 4 ms;

    paddle_dn_p1 <= '1';
    wait for 100 us;
    paddle_dn_p1 <= '0';
    wait for 50 us;

    paddle_up_p1 <= '1';
    wait for 100 us;
    paddle_up_p1 <= '0';

    wait for 2 ms;

end process;

end architecture;


