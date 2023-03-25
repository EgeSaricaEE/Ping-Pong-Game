--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package Constants is

 --Horizontal Synchronization Constants
    constant VIS_H: integer:= 640;
    constant FP_H: integer:= 16;
    constant SP_H: integer:= 96;
    constant BP_H: integer:= 48;
    constant TOT_H: integer:= VIS_H + FP_H + SP_H + BP_H; --800 in total
    --Vertical Synchronization Constants
    constant VIS_V: integer:= 480;
    constant FP_V: integer:= 10;
    constant SP_V: integer:= 2;
    constant BP_V: integer:= 33;
    constant TOT_V: integer:= VIS_V + FP_V + SP_V + BP_V; --525 in total
    --Paddle Size Constants
    constant PADDLE_WIDTH: integer:= 92;
    constant PADDLE_HEIGHT: integer:= 12;
    constant PRESCALER_PADDLE: integer:= 40000; --Adjusted to prevent debouncing   
    --Ball Size Constants
    constant BALL_SIDE: integer:= 11;
    constant BALL_INITIAL_X: integer:= FP_H + SP_H + BP_H + (VIS_H - BALL_SIDE - 1) / 2;
    constant BALL_INITIAL_Y: integer:= 315;
    constant PRESCALER_BALL: integer:= 140000;
 
end Constants;
