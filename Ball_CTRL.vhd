
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BallControl is
    port (
        i_Clk : in std_logic;
        i_Game_On : in std_logic;
        i_pixel_X_pos : in std_logic_vector(9 downto 0);
        i_pixel_Y_pos : in std_logic_vector(9 downto 0);

        o_ball_x : out unsigned(9 downto 0);
        o_ball_y : out unsigned(9 downto 0);
        o_Ball_On : out std_logic
    );

end entity;

architecture behavior of BallControl is

    constant X_MAX : integer := 639;
    constant Y_MAX : integer := 479;
    constant BALL_SIZE : integer := 16;
    constant BALL_VELOCITY_POS : integer := 2;
    constant BALL_VELOCITY_NEG : integer := - 2;
    constant Center_X : integer := 312;
    constant Center_Y : integer := 232;

    signal w_pixel_X_pos : integer;
    signal w_pixel_Y_pos : integer;
    signal w_VideoOn : std_logic;

    signal r_ball_y_t : unsigned(9 downto 0);
    signal r_ball_y_b : unsigned(9 downto 0);
    signal r_ball_x_l : unsigned(9 downto 0);
    signal r_ball_x_r : unsigned(9 downto 0);

    --Track left and top positions
    signal r_ball_x : unsigned(9 downto 0);
    signal r_ball_y : unsigned(9 downto 0);
    --buffer
    signal w_ball_x_next : unsigned(9 downto 0);
    signal w_ball_y_next : unsigned(9 downto 0);

    --Track square speed
    signal r_x_delta : unsigned(9 downto 0) := to_unsigned(2, 10);
    signal r_y_delta : unsigned(9 downto 0) := to_unsigned(2, 10);
    --buffer
    signal r_x_delta_next : unsigned(9 downto 0);
    signal r_y_delta_next : unsigned(9 downto 0);
    signal temp_r_x_delta_next : signed(9 downto 0);
    signal temp_r_y_delta_next : signed(9 downto 0);

    signal frameDone : std_logic;

begin

    w_pixel_X_pos <= TO_INTEGER(unsigned(i_pixel_X_pos));
    w_pixel_Y_pos <= TO_INTEGER(unsigned(i_pixel_Y_pos));
    frameDone <= '1' when (w_pixel_X_pos = 0 and w_pixel_Y_pos = 481) else
        '0';

    process (i_Clk)
    begin

        if rising_edge(i_Clk) then
            r_x_delta <= r_x_delta_next;
            r_y_delta <= r_y_delta_next;

            if (i_Game_On = '0') then
                r_ball_x <= TO_UNSIGNED(Center_X, 10);
                r_ball_y <= TO_UNSIGNED(Center_Y, 10);
            else
                r_ball_x <= w_ball_x_next;
                r_ball_y <= w_ball_y_next;

            end if;
        end if;
    end process;

    --Square
    r_ball_x_l <= r_ball_x;
    r_ball_y_t <= r_ball_y;
    r_ball_x_r <= r_ball_x_l + BALL_SIZE - 1;
    r_ball_y_b <= r_ball_y_t + BALL_SIZE - 1;

    --Ball Active Area
    o_Ball_On <= '1' when (w_VideoOn = '1' and (w_pixel_X_pos >= r_ball_x_l) and (w_pixel_X_pos <= r_ball_x_r) and (w_pixel_Y_pos >= r_ball_y_t) and (w_pixel_Y_pos <= r_ball_y_b)) else
        '0';

    --Move Ball after every frame 
    w_ball_x_next <= r_ball_x + r_x_delta when (frameDone = '1') else
        r_ball_x;
    w_ball_y_next <= r_ball_y + r_y_delta when (frameDone = '1') else
        r_ball_y;

    --Collision
    process (i_Clk)
    begin
        if rising_edge(i_Clk) then

            if (r_ball_y_t < 1) then
                r_y_delta_next <= to_unsigned(BALL_VELOCITY_POS, 10);

            elsif (r_ball_y_b > Y_MAX) then
                temp_r_y_delta_next <= to_signed(BALL_VELOCITY_NEG, 10);
                r_y_delta_next <= unsigned(temp_r_y_delta_next);

            elsif (r_ball_x_l < 1) then
                r_x_delta_next <= to_unsigned(BALL_VELOCITY_POS, 10);

            elsif (r_ball_x_r > X_MAX) then
                temp_r_x_delta_next <= to_signed(BALL_VELOCITY_NEG, 10);
                r_x_delta_next <= unsigned(temp_r_x_delta_next);

            else
                r_x_delta_next <= r_x_delta;
                r_y_delta_next <= r_y_delta;

            end if;
        end if;
    end process;

    o_ball_x <= r_ball_x;
end architecture;