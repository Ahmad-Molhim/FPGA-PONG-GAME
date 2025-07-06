library ieee;
use ieee.std_logic_1164.all;

entity DebounceSwitch is 
port(
i_Clk: in std_logic;
i_Switch: in std_logic;
o_Switch: out std_logic);

end entity DebounceSwitch; 

architecture rtl of DebounceSwitch is 

constant c_Limit: integer := 250000;
signal counter: integer range 0 to c_Limit := 0;
signal r_stable: std_logic := '0';

begin 

project4: process(i_Clk) is  
begin 
if rising_edge(i_Clk) then 

if (i_Switch /= r_stable and counter < c_Limit) then 
counter <= counter + 1;

elsif (counter = c_Limit) then 
r_stable <= i_Switch;
counter <= 0;

else 
counter <= 0;

end if;

end if;

end process project4;

o_Switch <= r_stable;

end rtl;

