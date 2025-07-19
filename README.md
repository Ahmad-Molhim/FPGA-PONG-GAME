# FPGA-PONG-GAME
A classic Pong game implemented on FPGA using VHDL, featuring real-time 640×480 VGA output at 60Hz, button-controlled input, and a finite state machine for game logic and scoring



📁 Project Modules Overview
1. Seven Segment Display Interface
Displays each player's score using two seven-segment displays. Player 1’s score is shown on the first display and Player 2’s on the second. The game resets automatically when either player reaches a score of 9.

2. UART Receiver Controller
Implements a UART receiver that listens for input from a keyboard. The game remains idle until a valid UART signal is received, which then triggers the game to start.

3. UART Receiver Testbench
Simulates UART communication by emulating serial data input. This testbench verifies the correct decoding of UART signals and validates the receiver’s response to various input scenarios.

4. VGA Controller
Generates a 640×480 VGA video signal at 60Hz. Handles horizontal and vertical synchronization, pixel timing, and screen refresh to render the game objects in real-time on a VGA display.

5. VGA Controller Testbench
Simulates the VGA timing signals and verifies correct horizontal and vertical sync behavior, ensuring pixel scanning and screen refresh occur as expected.

6. Ball Control
Handles the logic for ball movement, screen boundary collision, paddle interaction, and drawing the ball on the screen.

7. Paddle Control
Manages paddle movement based on user input, collision detection with the ball, and dawing the paddles on the screen.

8. Game Logic (FSM)
Implements the core game mechanics using a finite state machine (FSM). Tracks the game state, updates scores, detects winning conditions based on ball-paddle interactions, and controls game flow.

9. Game Logic Testbench
Simulates the full game logic and verifies FSM behavior, including transitions between game states (idle, running and scoring) based on simulated events such as ball position and game start triggers.

10. Top Module
Serves as the main integration unit, instantiating and connecting all submodules. Designed for modularity and ease of modifying game settings or expanding functionality.

11. Game Package (Constants and Settings)
Contains all game-related constants and configuration parameters, such as paddle dimensions, screen dimensions, and score limits. This package makes the game easily configurable and user-friendly for future adjustments or extensions.


