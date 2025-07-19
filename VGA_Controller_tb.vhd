library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_Controller_tb is
end VGA_Controller_tb;

architecture rtl of VGA_Controller_tb is

    component VGA_Control is
        port (
            i_Clk : in std_logic;
            o_H_SYNC : out std_logic;
            o_V_SYNC : out std_logic;
            o_xCoord : out std_logic_vector (9 downto 0);
            o_yCoord : out std_logic_vector (9 downto 0);
            o_VideoOn : out std_logic
        );
    end component;

    constant clk_period : time := 40 ns;

    signal r_clk : std_logic := '0';
    signal hsync, vsync : std_logic;
    signal xPixelPos, yPixelPos : std_logic_vector(9 downto 0);
    signal videoOn : std_logic;

begin

    r_clk <= not r_clk after clk_period/2;

    DUT : entity work.VGA_Controller
        port map(
            i_Clk => r_clk,
            o_H_SYNC => hsync,
            o_V_SYNC => vsync,
            o_xCoord => xPixelPos,
            o_yCoord => yPixelPos,
            o_VideoOn => videoOn
        );

    stimulus_proc : process
    begin
        wait for 100 ms;
        assert false report "Simulation finished." severity note;
        wait;
    end process;
end architecture;