library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Pong_Pkg.all;

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

        o_Score_P1 : out std_logic_vector(3 downto 0);
        o_Score_P2 : out std_logic_vector(3 downto 0)

    );
end entity;

architecture rtl of Pong_Game_Logic is

    type t_Game_FSM is (S_IDLE, S_GAME_RUNNING, S_P1_WINS, S_P2_WINS, S_CLEANUP);
    signal State : t_Game_FSM := S_IDLE;

    signal w_pixel_X_pos : std_logic_vector (9 downto 0);
    signal w_pixel_Y_pos : std_logic_vector (9 downto 0);

    signal w_pixel_X_pos_Div : std_logic_vector (5 downto 0) := (others => '0');
    signal w_pixel_Y_pos_Div : std_logic_vector (5 downto 0) := (others => '0');

    signal w_Paddle_Y_P1 : std_logic_vector(5 downto 0);
    signal w_Paddle_Y_P2 : std_logic_vector(5 downto 0);

    -- signal w_Paddle_X_P1 : std_logic_vector(5 downto 0);
    -- signal w_Paddle_X_P2 : std_logic_vector(5 downto 0);

    signal w_Paddle_Y_P1_Top : unsigned(5 downto 0);
    signal w_Paddle_Y_P2_Top : unsigned(5 downto 0);
    signal w_Paddle_Y_P1_Bot : unsigned(5 downto 0);
    signal w_Paddle_Y_P2_Bot : unsigned(5 downto 0);

    signal w_Paddle_P1_On : std_logic;
    signal w_Paddle_P2_On : std_logic;

    signal w_Game_On : std_logic;

    signal w_Score_P1 : integer := 0;
    signal w_Score_P2 : integer := 0;

    signal w_ball_x : std_logic_vector(5 downto 0);
    signal w_ball_y : std_logic_vector(5 downto 0);
    signal w_Ball_on : std_logic;

    signal w_VideoOn : std_logic;

    signal w_Draw_Any : std_logic;

begin

    VGA_Controller_inst : entity work.VGA_Controller
        port map(
            i_Clk => i_Clk,
            o_H_SYNC => o_VGA_HSync,
            o_V_SYNC => o_VGA_VSync,
            o_xCoord => w_pixel_X_pos,
            o_yCoord => w_pixel_Y_pos,
            o_VideoOn => w_VideoOn
        );

    w_pixel_X_pos_Div <= w_pixel_X_pos(w_pixel_X_pos'left downto 4);
    w_pixel_Y_pos_Div <= w_pixel_Y_pos(w_pixel_Y_pos'left downto 4);

    Paddle_Ctrl_P1_inst : entity work.Paddle_Ctrl
        generic map(
            g_PADDLE_X => c_Paddle_X_Pos_P1
        )
        port map(
            i_Clk => i_Clk,
            i_pixel_X_pos_div => w_pixel_X_pos_Div,
            i_pixel_Y_pos_div => w_pixel_Y_pos_Div,
            i_paddle_up => i_Paddle_Up_P1,
            i_paddle_dn => i_Paddle_Dn_P1,
            i_videoOn => w_VideoOn,
            o_Paddle_On => w_Paddle_P1_On,
            o_Paddle_Y => w_Paddle_Y_P1
            -- o_Paddle_X => w_Paddle_X_P1
        );

    Paddle_Ctrl_P2_inst : entity work.Paddle_Ctrl
        generic map(
            g_PADDLE_X => c_Paddle_X_Pos_P2
        )
        port map(
            i_Clk => i_Clk,
            i_pixel_X_pos_div => w_pixel_X_pos_Div,
            i_pixel_Y_pos_div => w_pixel_Y_pos_Div,
            i_paddle_up => i_Paddle_Up_P2,
            i_paddle_dn => i_Paddle_Dn_P2,
            i_videoOn => w_VideoOn,
            o_Paddle_On => w_Paddle_P2_On,
            o_Paddle_Y => w_Paddle_Y_P2
            -- o_Paddle_X => w_Paddle_X_P2
        );

    -- w_Paddle_X_P1 <= std_logic_vector(to_unsigned(c_Paddle_X_Pos_P1, 6));
    -- w_Paddle_X_P2 <= std_logic_vector(to_unsigned(c_Paddle_X_Pos_P2, 6));

    BallControl_inst : entity work.Ball_Control
        port map(
            i_Paddle_Y_P1_Bot => w_Paddle_Y_P1_Bot,
            i_Paddle_Y_P1_Top => w_Paddle_Y_P1_Top,
            i_Paddle_Y_P2_Bot => w_Paddle_Y_P2_Bot,
            i_Paddle_Y_P2_Top => w_Paddle_Y_P2_Top,
            -- i_Paddle_X_P1 => w_Paddle_X_P1,
            -- i_Paddle_X_P2 => w_Paddle_X_P2,
            i_Clk => i_Clk,
            i_Game_On => w_Game_On,
            i_pixel_X_pos_div => w_pixel_X_pos_Div,
            i_pixel_Y_pos_div => w_pixel_Y_pos_Div,
            i_VideoOn => w_VideoOn,
            o_ball_x => w_ball_x,
            o_ball_y => w_ball_y,
            o_Ball_On => w_Ball_On
        );

    w_Paddle_Y_P1_Top <= unsigned(w_Paddle_Y_P1);
    w_Paddle_Y_P1_Bot <= w_Paddle_Y_P1_Top + to_unsigned(c_Paddle_Height, w_Paddle_Y_P1_Bot'length);

    w_Paddle_Y_P2_Top <= unsigned(w_Paddle_Y_P2);
    w_Paddle_Y_P2_Bot <= w_Paddle_Y_P2_Top + to_unsigned(c_Paddle_Height, w_Paddle_Y_P2_Bot'length);

    GAME_MECHANICS : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            case State is
                when S_IDLE =>
                    if (i_Game_Start = '1') then
                        State <= S_GAME_RUNNING;
                    end if;

                when S_GAME_RUNNING =>
                    if (w_ball_x = std_logic_vector(to_unsigned(c_Game_Width - 1, w_ball_x'length))) then
                        if (unsigned(w_ball_y) < w_Paddle_Y_P2_Top or unsigned(w_ball_y) > w_Paddle_Y_P2_Bot) then
                            State <= S_P1_WINS;
                        end if;
                    elsif (w_ball_x = std_logic_vector(to_unsigned(0, w_ball_x'length))) then
                        if (unsigned(w_ball_y) < w_Paddle_Y_P1_Top or unsigned(w_ball_y) > w_Paddle_Y_P1_Bot) then
                            State <= S_P2_WINS;
                        end if;
                    end if;

                when S_P1_WINS =>
                    if (w_Score_P1 = c_Score_Limit - 1) then
                        w_Score_P1 <= 0;
                        w_Score_P2 <= 0;
                        State <= S_CLEANUP;
                    else
                        w_Score_P1 <= w_Score_P1 + 1;
                        State <= S_GAME_RUNNING;
                    end if;

                when S_P2_WINS =>
                    if (w_Score_P2 = c_Score_Limit - 1) then
                        w_Score_P2 <= 0;
                        w_Score_P1 <= 0;
                        State <= S_CLEANUP;
                    else
                        w_Score_P2 <= w_Score_P2 + 1;
                        State <= S_GAME_RUNNING;
                    end if;

                when S_CLEANUP =>
                    State <= S_IDLE;

                when others =>
                    State <= S_IDLE;

            end case;

        end if;

    end process;

    w_Game_On <= '1' when (State = S_GAME_RUNNING) else
    '0';

    w_Draw_Any <= w_Ball_on or w_Paddle_P1_On or w_Paddle_P2_On;

    o_VGA_Red <= (others => '1') when w_Draw_Any = '1' else
    (others => '0');
    o_VGA_Grn <= (others => '1') when w_Draw_Any = '1' else
    (others => '0');
    o_VGA_Blu <= (others => '0') when w_Draw_Any = '1' else
    (others => '0');

    o_Score_P1 <= std_logic_vector(to_unsigned(w_Score_P1, 4));
    o_Score_P2 <= std_logic_vector(to_unsigned(w_Score_P2, 4));

end architecture;