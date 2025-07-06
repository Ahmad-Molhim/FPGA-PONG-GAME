LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY UART_RECEIVE IS
    GENERIC (
        g_RX_CLOCK_RATE : INTEGER := 217 --clock cycles/bit
    );
    PORT (
        i_Clk : IN STD_LOGIC;
        i_RX_Serial : IN STD_LOGIC;
        o_RX_Byte : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        o_RX_Done : OUT STD_LOGIC);
END ENTITY UART_RECEIVE;

ARCHITECTURE rtl OF UART_RECEIVE IS

    TYPE t_State IS (S_IDLE, S_CHECK, S_ASSEMBLE_DATA, S_STOP_BIT, S_CLEANUP);
    SIGNAL State : t_State;
    SIGNAL w_State : STD_LOGIC_VECTOR(2 DOWNTO 0);

    SIGNAL r_RX_Byte : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_Done : STD_LOGIC := '0';
    SIGNAL counter : INTEGER RANGE 0 TO g_RX_CLOCK_RATE - 1 := 0;
    SIGNAL bitCounter : INTEGER RANGE 0 TO 7 := 0;

BEGIN

    PROCESS (i_Clk) IS
    BEGIN
        IF rising_edge (i_Clk) THEN

            CASE State IS
                WHEN S_IDLE =>
                    counter <= 0;
                    bitCounter <= 0;
                    r_Done <= '0';

                    IF (i_RX_Serial = '0') THEN
                        State <= S_CHECK;

                    ELSE
                        State <= S_IDLE;

                    END IF;

                WHEN S_CHECK =>
                    IF (counter = (g_RX_CLOCK_RATE - 1)/2 AND i_RX_Serial = '0') THEN
                        counter <= 0;
                        State <= S_ASSEMBLE_DATA;

                    ELSIF (i_RX_Serial = '1') THEN
                        counter <= 0;
                        State <= S_IDLE;

                    ELSE
                        counter <= counter + 1;
                        State <= S_CHECK;

                    END IF;

                WHEN S_ASSEMBLE_DATA =>
                    IF (counter = g_RX_CLOCK_RATE - 1) THEN
                        r_RX_Byte(bitCounter) <= i_RX_Serial;
                        counter <= 0;

                        IF (bitCounter = 7) THEN

                            bitCounter <= 0;
                            State <= S_STOP_BIT;
                            
                        ELSE
                            bitCounter <= bitCounter + 1;
                            State <= S_ASSEMBLE_DATA;

                        END IF;

                    ELSE
                        counter <= counter + 1;
                        State <= S_ASSEMBLE_DATA;

                    END IF;

                WHEN S_STOP_BIT =>
                    IF (counter = g_RX_CLOCK_RATE - 1) THEN
                        r_Done <= '1';
                        counter <= 0;
                        State <= S_CLEANUP;

                    ELSE
                        counter <= counter + 1;
                        State <= S_STOP_BIT;

                    END IF;

                WHEN S_CLEANUP =>
                    r_Done <= '0';
                    State <= S_IDLE;

                WHEN OTHERS =>
                    State <= S_IDLE;

            END CASE;

        END IF;

    END PROCESS;

    o_RX_Done <= r_Done;
    o_RX_Byte <= r_RX_Byte;

    w_State <= "000" WHEN State = S_IDLE ELSE
        "001" WHEN State = S_CHECK ELSE
        "010" WHEN State = S_ASSEMBLE_DATA ELSE
        "011" WHEN State = S_STOP_BIT ELSE
        "100" WHEN State = S_CLEANUP ELSE
        "101";
END ARCHITECTURE rtl;