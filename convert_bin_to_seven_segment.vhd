library ieee;
use ieee.std_logic_1164.all;

entity convert_bin_to_seven_segment is 
port (
i_binVal: in std_logic_vector(3 downto 0);

o_Segment_A: out std_logic;
o_Segment_B: out std_logic;
o_Segment_C: out std_logic;
o_Segment_D: out std_logic;
o_Segment_E: out std_logic;
o_Segment_F: out std_logic;
o_Segment_G: out std_logic);

end entity convert_bin_to_seven_segment;

architecture rtl of convert_bin_to_seven_segment is 

begin 

process(i_binVal) 
   
variable o_convertedVal: std_logic_vector(6 downto 0);   

begin 

case i_binVal is
when "0000" => o_convertedVal := "0000001"; --0
when "0001" => o_convertedVal := "1001111"; --1
when "0010" => o_convertedVal := "0010010"; --2
when "0011" => o_convertedVal := "0000110"; --3
when "0100" => o_convertedVal := "1001100"; --4
when "0101" => o_convertedVal := "0100100"; --5
when "0110" => o_convertedVal := "0100000"; --6
when "0111" => o_convertedVal := "0001111"; --7
when "1000" => o_convertedVal := "0000000"; --8
when "1001" => o_convertedVal := "0000100"; --9
when "1010" => o_convertedVal := "0001000"; --A
when "1011" => o_convertedVal := "1100000"; --b
when "1100" => o_convertedVal := "0110001"; --C
when "1101" => o_convertedVal := "1000010"; --d
when "1110" => o_convertedVal := "0110000"; --E
when "1111" => o_convertedVal := "0111000"; --F
when others => o_convertedVal := "1111111"; 

end case;

o_Segment_A <= o_convertedVal(6);
o_Segment_B <= o_convertedVal(5);
o_Segment_C <= o_convertedVal(4);
o_Segment_D <= o_convertedVal(3);
o_Segment_E <= o_convertedVal(2);
o_Segment_F <= o_convertedVal(1);
o_Segment_G <= o_convertedVal(0);

end process;


end rtl;