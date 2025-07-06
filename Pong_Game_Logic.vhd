library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pong_Game_Logic is
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

        o_Score : out std_logic_vector(3 downto 0)

    );
end entity;

architecture rtl of Pong_Game_Logic is

    type t_Game_FSM is (S_IDLE, S_GAME_RUNNING, S_P1_WINS, S_P2_WINS, S_CLEANUP);
    signal State : t_Game_FSM := S_IDLE;

    constant X_MAX : integer := 639;
    constant Y_MAX : integer := 479;
    constant BALL_SIZE : integer := 16;
    constant PADDLE_HEIGHT : integer := 100;
    constant Score_Limit : integer := 9;

    constant PADDLE_P1_X : integer := 20;
    constant PADDLE_P2_X : integer := 620;

    signal w_pixel_X_pos : std_logic_vector (9 downto 0);
    signal w_pixel_Y_pos : std_logic_vector (9 downto 0);

    signal pixel_X_pos : integer;
    signal pixel_Y_pos : integer;

    signal w_Paddle_Y_P1 : unsigned(9 downto 0);
    signal w_Paddle_Y_P2 : unsigned(9 downto 0);

    signal w_VideoOn : std_logic;

    signal w_Paddle_Y_P1_Top : unsigned(9 downto 0);
    signal w_Paddle_Y_P2_Top : unsigned(9 downto 0);
    signal w_Paddle_Y_P1_Bot : unsigned(9 downto 0);
    signal w_Paddle_Y_P2_Bot : unsigned(9 downto 0);

    signal w_Paddle_P1_On : std_logic;
    signal w_Paddle_P2_On : std_logic;

    signal w_Game_On : std_logic;

    signal w_Score : unsigned (3 downto 0) := to_unsigned(0, 4);

    signal w_ball_x : unsigned(9 downto 0);
    signal w_ball_y : unsigned(9 downto 0);
    signal w_Ball_on : std_logic;

    signal w_Draw_Any : std_logic;

begin

    pixel_X_pos <= to_integer(unsigned(w_pixel_X_pos));
    pixel_Y_pos <= to_integer(unsigned(w_pixel_Y_pos));

    VGA_Controller_inst : entity work.VGA_Controller
        port map(
            i_Clk => i_Clk,
            o_H_SYNC => o_VGA_HSync,
            o_V_SYNC => o_VGA_VSync,
            o_xCoord => w_pixel_X_pos,
            o_yCoord => w_pixel_Y_pos,
            o_VideoOn => w_VideoOn
        );

    Paddle_Ctrl_P1_inst : entity work.Paddle_Ctrl
        generic map(
            g_PADDLE_X => PADDLE_P1_X
        )
        port map(
            i_Clk => i_Clk,
            i_pixel_X_pos => w_pixel_X_pos,
            i_pixel_Y_pos => w_pixel_Y_pos,
            i_paddle_up => i_Paddle_Up_P1,
            i_paddle_dn => i_Paddle_Dn_P1,
            i_videoOn => w_VideoOn,
            o_Paddle_On => w_Paddle_P1_On,
            o_Paddle_Y => w_Paddle_Y_P1
        );

    Paddle_Ctrl_P2_inst : entity work.Paddle_Ctrl
        generic map(
            g_PADDLE_X => PADDLE_P2_X
        )
        port map(
            i_Clk => i_Clk,
            i_pixel_X_pos => w_pixel_X_pos,
            i_pixel_Y_pos => w_pixel_Y_pos,
            i_paddle_up => i_Paddle_Up_P2,
            i_paddle_dn => i_Paddle_Dn_P2,
            i_videoOn => w_VideoOn,
            o_Paddle_On => w_Paddle_P2_On,
            o_Paddle_Y => w_Paddle_Y_P2
        );

    BallControl_inst : entity work.BallControl
        port map(
            i_Clk => i_Clk,
            i_Game_On => w_Ball_on,
            i_pixel_X_pos => w_pixel_X_pos,
            i_pixel_Y_pos => w_pixel_Y_pos,
            o_ball_x => w_ball_x,
            o_ball_y => w_ball_y,
            o_Ball_On => w_Ball_On
        );

    w_Paddle_Y_P1_Top <= w_Paddle_Y_P1;
    w_Paddle_Y_P1_Bot <= w_Paddle_Y_P1_Top + PADDLE_HEIGHT;

    w_Paddle_Y_P2_Top <= w_Paddle_Y_P2;
    w_Paddle_Y_P2_Bot <= w_Paddle_Y_P2_Top + PADDLE_HEIGHT;

    GAME_MECHANICS : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            case State is
                when S_IDLE =>
                    w_Game_On <= '0';

                    if (i_Game_Start = '1') then
                        State <= S_GAME_RUNNING;
                    end if;

                when S_GAME_RUNNING =>
                    w_Game_On <= '1';

                    if (w_ball_x + BALL_SIZE >= X_MAX) then
                        if (w_ball_y + BALL_SIZE < w_Paddle_Y_P2_Top or w_ball_y + BALL_SIZE > w_Paddle_Y_P2_Bot) then
                            State <= S_P1_WINS;
                        end if;
                    elsif (w_ball_x <= 15) then
                        if (w_ball_y + BALL_SIZE < w_Paddle_Y_P1_Top or w_ball_y + BALL_SIZE > w_Paddle_Y_P1_Bot) then
                            State <= S_P2_WINS;
                        end if;
                    end if;

                when S_P1_WINS =>
                    w_Game_On <= '0';
                    if (w_Score = Score_Limit) then
                        w_Score <= to_unsigned(0, 4);
                    else
                        w_Score <= w_Score + 1;
                    end if;

                    State <= S_CLEANUP;

                when S_P2_WINS =>
                    w_Game_On <= '0';

                    if (w_Score = Score_Limit) then
                        w_Score <= to_unsigned(0, 4);
                    else
                        w_Score <= w_Score + 1;
                    end if;

                when S_CLEANUP =>
                    w_Game_On <= '0';
                    State <= S_IDLE;

                when others =>
                    State <= S_IDLE;

            end case;

        end if;

    end process;

    w_Draw_Any <= w_Ball_on or w_Paddle_P1_On or w_Paddle_P2_On;

    o_VGA_Red <= (others => '1') when w_Draw_Any = '1' else
        (others => '0');
    o_VGA_Grn <= (others => '1') when w_Draw_Any = '1' else
        (others => '0');
    o_VGA_Blu <= (others => '0') when w_Draw_Any = '1' else
        (others => '0');

    o_Score <= std_logic_vector(w_Score);

end architecture;