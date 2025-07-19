library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pong_Game_Top is
    port (
        i_Clk : in std_logic;
        i_UART_RX : in std_logic;

        i_Switch_1 : in std_logic;
        i_Switch_2 : in std_logic;
        i_Switch_3 : in std_logic;
        i_Switch_4 : in std_logic;

        o_VGA_HSync : out std_logic;
        o_VGA_VSync : out std_logic;

        o_VGA_Red : out std_logic_vector(2 downto 0);
        o_VGA_Grn : out std_logic_vector(2 downto 0);
        o_VGA_Blu : out std_logic_vector(2 downto 0);

        o_Segment1_A : out std_logic;
        o_Segment1_B : out std_logic;
        o_Segment1_C : out std_logic;
        o_Segment1_D : out std_logic;
        o_Segment1_E : out std_logic;
        o_Segment1_F : out std_logic;
        o_Segment1_G : out std_logic;

        o_Segment2_A : out std_logic;
        o_Segment2_B : out std_logic;
        o_Segment2_C : out std_logic;
        o_Segment2_D : out std_logic;
        o_Segment2_E : out std_logic;
        o_Segment2_F : out std_logic;
        o_Segment2_G : out std_logic;

        o_RX_Done : out std_logic
    );
end entity;

architecture rtl of Pong_Game_Top is

    signal w_RX_Done : std_logic;

    signal w_Switch_1 : std_logic;
    signal w_Switch_2 : std_logic;
    signal w_Switch_3 : std_logic;
    signal w_Switch_4 : std_logic;

    signal w_Score_P1 : std_logic_vector(3 downto 0);
    signal w_Score_P2 : std_logic_vector(3 downto 0);

begin

    UART_RECEIVE_inst : entity work.UART_RECEIVE
        generic map(
            g_RX_CLOCK_RATE => 217
        )
        port map(
            i_Clk => i_Clk,
            i_RX_Serial => i_UART_RX,
            o_RX_Done => w_RX_Done,
            o_RX_Byte => open
        );

    DebounceSwitch1_inst : entity work.DebounceSwitch
        port map(
            i_Clk => i_Clk,
            i_Switch => i_Switch_1,
            o_Switch => w_Switch_1
        );

    DebounceSwitch2_inst : entity work.DebounceSwitch
        port map(
            i_Clk => i_Clk,
            i_Switch => i_Switch_2,
            o_Switch => w_Switch_2
        );

    DebounceSwitch3_inst : entity work.DebounceSwitch
        port map(
            i_Clk => i_Clk,
            i_Switch => i_Switch_3,
            o_Switch => w_Switch_3
        );

    DebounceSwitch4_inst : entity work.DebounceSwitch
        port map(
            i_Clk => i_Clk,
            i_Switch => i_Switch_4,
            o_Switch => w_Switch_4
        );

    convert_bin_to_seven_segment_1_inst : entity work.convert_bin_to_seven_segment
        port map(
            i_binVal => w_Score_P1,
            o_Segment_A => o_Segment1_A,
            o_Segment_B => o_Segment1_B,
            o_Segment_C => o_Segment1_C,
            o_Segment_D => o_Segment1_D,
            o_Segment_E => o_Segment1_E,
            o_Segment_F => o_Segment1_F,
            o_Segment_G => o_Segment1_G
        );

    convert_bin_to_seven_segment_2_inst : entity work.convert_bin_to_seven_segment
        port map(
            i_binVal => w_Score_P2,
            o_Segment_A => o_Segment2_A,
            o_Segment_B => o_Segment2_B,
            o_Segment_C => o_Segment2_C,
            o_Segment_D => o_Segment2_D,
            o_Segment_E => o_Segment2_E,
            o_Segment_F => o_Segment2_F,
            o_Segment_G => o_Segment2_G
        );

    Pong_Game_Logic_inst : entity work.Pong_Game_Logic
        port map(
            i_Clk => i_Clk,
            i_Game_Start => w_RX_Done,
            i_Paddle_Up_P1 => w_Switch_1,
            i_Paddle_Up_P2 => w_Switch_3,
            i_Paddle_Dn_P1 => w_Switch_2,
            i_Paddle_Dn_P2 => w_Switch_4,
            o_VGA_HSync => o_VGA_HSync,
            o_VGA_VSync => o_VGA_VSync,
            o_VGA_Red => o_VGA_Red,
            o_VGA_Grn => o_VGA_Grn,
            o_VGA_Blu => o_VGA_Blu,
            o_Score_P1 => w_Score_P1,
            o_Score_P2 => w_Score_P2
        );

        o_RX_Done <= w_RX_Done;

    end architecture;