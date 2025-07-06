library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Paddle_Ctrl is
    generic (
        g_PADDLE_X : integer
    );
    port (
        i_Clk : in std_logic;
        i_pixel_X_pos : in std_logic_vector(9 downto 0);
        i_pixel_Y_pos : in std_logic_vector(9 downto 0);
        i_paddle_up : in std_logic;
        i_paddle_dn : in std_logic;
        i_videoOn : in std_logic;

        o_Paddle_On : out std_logic;
        o_Paddle_Y : out unsigned(9 downto 0)

    );

end entity;

architecture rtl of Paddle_Ctrl is

    constant PADDLE_HEIGHT : integer := 100;
    constant PADDLE_WIDTH : integer := 12;
    constant X_MAX : integer := 639;
    constant Y_MAX : integer := 479;
    constant PADDLE_VELOCITY : integer := 20;

    signal w_pixel_X_pos : integer;
    signal w_pixel_Y_pos : integer;

    signal r_Paddle_On : std_logic;
    signal r_Paddle_Y : unsigned(9 downto 0);

    signal w_en_movement : std_logic;

begin
    w_pixel_X_pos <= to_integer(unsigned(i_pixel_X_pos));
    w_pixel_Y_pos <= to_integer(unsigned(i_pixel_Y_pos));

    w_en_movement <= i_paddle_up xor i_paddle_dn;

    Paddle_Movement : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            if (w_en_movement) then
                if (i_paddle_up = '1') then
                    if (r_Paddle_Y <= to_unsigned(1, 10)) then
                        r_Paddle_Y <= to_unsigned(1, 10);
                    else
                        r_Paddle_Y <= r_Paddle_Y - PADDLE_VELOCITY;
                    end if;

                elsif (i_paddle_dn = '1') then
                    if (r_paddle_Y >= to_unsigned(Y_MAX - PADDLE_HEIGHT, 10)) then
                        r_Paddle_Y <= to_unsigned(Y_MAX - PADDLE_HEIGHT, 10);
                    else
                        r_Paddle_Y <= r_Paddle_Y + PADDLE_VELOCITY;
                    end if;
                end if;
            end if;
        end if;
    end process;

    Draw_Paddle : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            if (i_videoOn = '1') then
                if (w_pixel_X_pos = g_PADDLE_X and w_pixel_Y_pos >= r_Paddle_Y and w_pixel_Y_pos <= r_Paddle_Y + PADDLE_HEIGHT) then
                    r_Paddle_On <= '1';

                else
                    r_Paddle_On <= '0';

                end if;

            else
                r_Paddle_On <= '0';

            end if;
        end if;

    end process;

    o_Paddle_On <= r_Paddle_On;
    o_Paddle_Y <= r_Paddle_Y;

end architecture;