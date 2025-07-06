library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_RECEIVE_tb is
end entity UART_RECEIVE_tb;

architecture rtl of UART_RECEIVE_tb is
    constant c_CLOCK : time := 40 ns;
    constant c_ClockPerBit: integer := 217;
    constant c_bitPeriod: time :=  8680 ns;

    signal r_Clk: std_logic;
    signal r_RX_Serial: std_logic;
    signal w_RX_Byte: std_logic_vector(7 downto 0);

  procedure UART_WRITE_BYTE (
    i_Data_In       : in  std_logic_vector(7 downto 0);
    signal o_Serial : out std_logic) is
  begin

    o_Serial <= '0';
    wait for c_bitPeriod;

    for ii in 0 to 7 loop
      o_Serial <= i_Data_In(ii);
      wait for c_bitPeriod;
    end loop;

    o_Serial <= '1';
    wait for c_bitPeriod;
  end UART_WRITE_BYTE;

  begin 

    UART_RECEIVE_INST: entity work.UART_RECEIVE
    generic map(
        g_RX_CLOCK_RATE => c_ClockPerBit
    )
    port map(
        i_Clk => r_Clk,
        i_RX_Serial => r_RX_Serial,
        o_RX_Byte => w_RX_Byte,
        o_RX_Done => open
    );

    r_Clk <= not r_Clk after c_CLOCK/2;

process

  begin

    wait until rising_edge(r_Clk);
    UART_WRITE_BYTE(X"37", r_RX_Serial);
    wait until rising_edge(r_Clk);

    if w_RX_Byte = X"37" then
      report "Test Passed - Correct Byte Received" severity note;
    else 
      report "Test Failed - Incorrect Byte Received" severity note;
    end if;

    assert false report "Tests Complete" severity failure;

    
end process;

end architecture rtl;