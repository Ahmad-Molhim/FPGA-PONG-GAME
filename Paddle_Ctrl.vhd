library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pong_pkg.all;

entity Paddle_Ctrl is
    generic (
        g_PADDLE_X : integer
    );
    port (
        i_Clk : in std_logic;
        i_pixel_X_pos_div : in std_logic_vector(5 downto 0);
        i_pixel_Y_pos_div : in std_logic_vector(5 downto 0);
        i_paddle_up : in std_logic;
        i_paddle_dn : in std_logic;
        i_videoOn : in std_logic;

        o_Paddle_On : out std_logic;
        o_Paddle_Y : out std_logic_vector(5 downto 0)
        -- o_Paddle_X : out std_logic_vector(5 downto 0)
    );

end entity;

architecture rtl of Paddle_Ctrl is

    signal w_pixel_X_pos : integer range 0 to 2 ** i_pixel_X_pos_div'length := 0;
    signal w_pixel_Y_pos : integer range 0 to 2 ** i_pixel_X_pos_div'length := 0;

    signal r_Paddle_Count : integer range 0 to c_Paddle_Speed := 0;
    signal w_en_movement : std_logic;

    signal r_Paddle_On : std_logic;
    signal r_Paddle_Y : integer range 0 to c_Game_Height + c_Paddle_Height - 1 := 0;
    -- signal r_Paddle_X : integer range 0 to c_Game_Height + c_Paddle_Height - 1 := 0;

begin
    w_pixel_X_pos <= to_integer(unsigned(i_pixel_X_pos_div));
    w_pixel_Y_pos <= to_integer(unsigned(i_pixel_Y_pos_div));

    w_en_movement <= i_paddle_up xor i_paddle_dn;

    Paddle_Movement : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            if (w_en_movement = '1') then
                if (r_Paddle_Count = c_Paddle_Speed) then
                    r_Paddle_Count <= 0;
                    else
                    r_Paddle_Count <= r_Paddle_Count + 1;
                end if;
                else
                r_Paddle_Count <= 0;
            end if;

            if (i_Paddle_Up = '1' and r_Paddle_Count = c_Paddle_Speed) then
                if r_Paddle_Y /= 0 then
                    r_Paddle_Y <= r_Paddle_Y - 1;
                end if;

                elsif (i_Paddle_Dn = '1' and r_Paddle_Count = c_Paddle_Speed) then
                if r_Paddle_Y /= c_Game_Height - c_Paddle_Height - 1 then
                    r_Paddle_Y <= r_Paddle_Y + 1;
                end if;
            end if;
        end if;
    end process;

    Draw_Paddles : process (i_Clk) is
    begin
        if rising_edge(i_Clk) then
            if (w_pixel_X_pos = g_PADDLE_X and w_pixel_Y_pos >= r_Paddle_Y and
                w_pixel_Y_pos <= r_Paddle_Y + c_Paddle_Height) then
                r_Paddle_on <= '1';
                else
                r_Paddle_On <= '0';
            end if;
        end if;
    end process Draw_Paddles;
    o_Paddle_On <= r_Paddle_On;
    o_Paddle_Y <= std_logic_vector(to_unsigned(r_Paddle_Y, 6));

end architecture;