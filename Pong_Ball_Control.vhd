library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pong_pkg.all;

entity Ball_Control is
    port (
        i_Clk : in std_logic;
        i_Game_On : in std_logic;
        i_pixel_X_pos_div : in std_logic_vector(5 downto 0);
        i_pixel_Y_pos_div : in std_logic_vector(5 downto 0);
        i_VideoOn : in std_logic;

        i_Paddle_Y_P1_Top : in unsigned(5 downto 0);
        i_Paddle_Y_P2_Top : in unsigned(5 downto 0);
        i_Paddle_Y_P1_Bot : in unsigned(5 downto 0);
        i_Paddle_Y_P2_Bot : in unsigned(5 downto 0);

        -- i_Paddle_X_P1 : in std_logic_vector(5 downto 0);
        -- i_Paddle_X_P2 : in std_logic_vector(5 downto 0);

        o_ball_x : out std_logic_vector(5 downto 0);
        o_ball_y : out std_logic_vector(5 downto 0);
        o_Ball_On : out std_logic
    );
end entity;

architecture RTL of Ball_Control is

    constant Center_X : integer := c_Game_Width/2;
    constant Center_Y : integer := c_Game_Height/2;

    signal r_ball_x : integer range 0 to 2 ** i_pixel_X_pos_div'length := 0;
    signal r_ball_y : integer range 0 to 2 ** i_pixel_X_pos_div'length := 0;
    signal r_dx : std_logic;
    signal r_dy : std_logic;

    signal w_pixel_X_pos : integer range 0 to 2 ** i_pixel_X_pos_div'length := 0;
    signal w_pixel_Y_pos : integer range 0 to 2 ** i_pixel_X_pos_div'length := 0;

    signal r_Ball_On : std_logic := '0';

    -- signal r_Ball_X_Prev: integer range 0 to 64;
    -- signal r_Ball_Y_Prev: integer range 0 to 64;

    -- signal r_Ball_Count: integer;

    signal r_ball_counter : integer range 0 to c_Ball_Speed;

begin

    w_pixel_X_pos <= to_integer(unsigned(i_pixel_X_pos_div));
    w_pixel_Y_pos <= to_integer(unsigned(i_pixel_Y_pos_div));

    Ball_Movement : process (i_Clk)
    begin
        if rising_edge(i_Clk) then

            if i_Game_On = '0' then
                r_ball_x <= Center_X;
                r_ball_y <= Center_Y;
                r_dx <= '1'; -- start right
                r_dy <= '0'; -- start up
                else
                if r_ball_counter = c_Ball_Speed then
                    r_ball_counter <= 0;

                    -- PADDLE COLLISIONS

                    -- Left paddle
                    if r_dx = '0' and r_ball_x = 1 then
                        if r_ball_y >= i_Paddle_Y_P1_Top and r_ball_y <= i_Paddle_Y_P1_Bot then
                            r_dx <= '1'; -- bounce right
                        end if;
                    end if;

                    -- Right paddle 
                    if r_dx = '1' and r_ball_x = c_Game_Width - 2 then
                        if r_ball_y >= i_Paddle_Y_P2_Top and r_ball_y <= i_Paddle_Y_P2_Bot then
                            -- and r_ball_x > 0 and r_ball_x < unsigned(i_Paddle_X_P2)
                            r_dx <= '0'; -- bounce left
                        end if;
                    end if;

                    -- WALL COLLISIONS

                    -- Left and right edges
                    if r_ball_x = 0 then
                        r_dx <= '1'; -- right
                        elsif r_ball_x = c_Game_Width - 1 then
                        r_dx <= '0'; -- left
                    end if;

                    -- Top and bottom
                    if r_ball_y = 0 then
                        r_dy <= '1'; -- down
                        elsif r_ball_y = c_Game_Height - 1 then
                        r_dy <= '0'; -- up
                    end if;

                    -- BALL MOVEMENT

                    if r_dx = '1' then
                        r_ball_x <= r_ball_x + 1;
                        else
                        r_ball_x <= r_ball_x - 1;
                    end if;

                    if r_dy = '1' then
                        r_ball_y <= r_ball_y + 1;
                        else
                        r_ball_y <= r_ball_y - 1;
                    end if;

                    else
                    r_ball_counter <= r_ball_counter + 1;
                end if;
            end if;

        end if;
    end process;

    Draw_Ball : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            if (w_pixel_X_pos = r_ball_x and
                w_pixel_Y_pos = r_ball_y) then
                r_Ball_On <= '1';
                else
                r_Ball_On <= '0';
            end if;
        end if;
    end process;

    o_ball_x <= std_logic_vector(to_unsigned(r_ball_x, 6));
    o_ball_y <= std_logic_vector(to_unsigned(r_ball_y, 6));
    o_Ball_On <= r_Ball_On;

end architecture;