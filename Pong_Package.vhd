 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
package Pong_Pkg is
  constant c_Game_Width    : integer := 40;
  constant c_Game_Height   : integer := 30;
 
  constant c_Score_Limit : integer := 9;
   
  constant c_Paddle_Height : integer := 6;
 
  constant c_Paddle_Speed : integer := 1250000;
 
  constant c_Ball_Speed : integer  := 1250000;
   
  constant c_Paddle_X_Pos_P1 : integer := 0;
  constant c_Paddle_X_Pos_P2 : integer := c_Game_Width-1;
   
end package Pong_Pkg; 