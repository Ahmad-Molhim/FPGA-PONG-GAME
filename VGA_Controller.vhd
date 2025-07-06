library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGA_Controller is
    port (
        i_Clk : in std_logic;
        o_H_SYNC : out std_logic;
        o_V_SYNC : out std_logic;
        o_xCoord : out std_logic_vector (9 downto 0);
        o_yCoord : out std_logic_vector (9 downto 0);
        o_VideoOn : out std_logic
    );

end entity VGA_Controller;

architecture RTL of VGA_Controller is
    constant H_SYNC_CYC : integer := 92;
    constant H_SYNC_BACK : integer := 50;
    constant H_SYNC_ACT : integer := 640;
    constant H_SYNC_FRONT : integer := 18;
    constant H_SYNC_TOTAL : integer := 800;
    
    constant V_SYNC_CYC : integer := 2;
    constant V_SYNC_BACK : integer := 33;
    constant V_SYNC_ACT : integer := 480;
    constant V_SYNC_FRONT : integer := 10;
    constant V_SYNC_TOTAL : integer := 525;
    
    signal H_counter : integer := 0;
    signal V_counter : integer := 0;
begin

    H_POS : process (i_Clk)
    begin
        if rising_edge(i_Clk) then

            if (H_counter = H_SYNC_TOTAL - 1) then
                H_counter <= 0;

            else
                H_counter <= H_counter + 1;

            end if;

        end if;

    end process;

    V_POS : process (i_Clk)
    begin
        if rising_edge(i_Clk) then
            if (H_counter = H_SYNC_TOTAL - 1) then

                if (V_counter = V_SYNC_TOTAL - 1) then
                    V_counter <= 0;

                else
                    V_counter <= V_counter + 1;

                end if;

            end if;

        end if;

    end process;

    o_H_SYNC <= '0' when ((H_counter >= (H_SYNC_ACT + H_SYNC_FRONT)) and (H_counter < (H_SYNC_ACT + H_SYNC_FRONT + H_SYNC_CYC))) else
        '1';

    o_V_SYNC <= '0' when ((V_counter >= (V_SYNC_ACT + V_SYNC_FRONT)) and (V_counter < (V_SYNC_ACT + V_SYNC_FRONT + V_SYNC_CYC))) else
        '1';

    o_VideoOn <= '1' when (H_counter < H_SYNC_ACT and V_counter < V_SYNC_ACT) else
        '0';

    o_xCoord <= std_logic_vector(to_unsigned(H_counter, o_xCoord'length));
    o_yCoord <= std_logic_vector(to_unsigned(V_counter, o_yCoord'length));

end architecture;