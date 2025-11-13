`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

`define DIGIT_ONE   4'B1110 // Digit enable signal for the first digit (active-low logic). Digit 1 is enabled (0); digits 2, 3, and 4 are disabled (1).
`define DIGIT_TWO   4'B1101 // Digit enable signal for the first digit (active-low logic). Digit 2 is enabled (0); digits 1, 3, and 4 are disabled (1).
`define DIGIT_THREE 4'B1011 // Digit enable signal for the first digit (active-low logic). Digit 3 is enabled (0); digits 1, 2, and 4 are disabled (1).
`define DIGIT_FOUR  4'B0111 // Digit enable signal for the first digit (active-low logic). Digit 4 is enabled (0); digits 1, 2, and 3 are disabled (1).

module digitSel( // Defines a digit selector module named "digitSel"
    // Digital logic input and output signals for the digitSel module
    input logic En,       // Circulation enable/pause input signal (En = 1 means the circulation is enabled, En = 0 means the circulation is paused)
    input logic Cw,       // Direction input signal (Cw = 1 for clockwise, Cw = 0 for counterclockwise)
    input logic clk,      // Input clock signal (driven by the slower "tic" from clockRate)
    output logic side,    // Output signal indicating the "half of rotation" (top/bottom side)
    output logic [7:0] An // Output digit enable signal for the four-digit seven-segment display
    );
    
    logic [2:0] accu; // 3-bit accumulator/counter for digit selection. This register accumulates/counts from 1-8 (0-7 digitally). It handles rollover/overflow automatically, which is required.
                      // The accumulator/counter is reset to 0 when the circuit is disabled.
    
    always @(posedge(clk)) begin  // Sequential block that runs on a rising edge of the slow clock ("clk" or "tic")
        if(En) begin              // If the circulation is enabled (En = 1)
            if(Cw)                // If the direction is clockwise (Cw = 1)
                accu <= accu + 1; // Increment the accumulator (moves the active digit clockwise)(non-blocking [<=] used here because this is sequential logic, not combinational logic)
            else                  // If the direction is counterclockwise (Cw = 0)
                accu <= accu - 1; // Decrement the accumulator (moves the active digit counterclockwise) (non-blocking [<=] used here because this is sequential logic, not combinational logic)
            end
         else begin               // If the circulation is paused (En = 0)
            accu <= 0;            // Reset the accumulator to 0 (non-blocking [<=] used here because this is sequential logic, not combinational logic)
         end
     end
    
    always_comb // Combinational block that sets the desired output digit enable signal (An)
        case (accu) // Use the 3-bit accumulator value to select the active digit
            0: An[3:0] = `DIGIT_ONE;   // Select digit 1 (1110) (blocking [=] used here because this is combinational logic, not sequential logic)
            1: An[3:0] = `DIGIT_TWO;   // Select digit 2 (1101) (blocking [=] used here because this is combinational logic, not sequential logic)
            2: An[3:0] = `DIGIT_THREE; // Select digit 3 (1011) (blocking [=] used here because this is combinational logic, not sequential logic)
            3: An[3:0] = `DIGIT_FOUR;  // Select digit 4 (0111) (blocking [=] used here because this is combinational logic, not sequential logic)
            4: An[3:0] = `DIGIT_FOUR;  // Select digit 4 again (start of the rotation's second half) (blocking [=] used here because this is combinational logic, not sequential logic)
            5: An[3:0] = `DIGIT_THREE; // Select digit 3 (blocking [=] used here because this is combinational logic, not sequential logic)
            6: An[3:0] = `DIGIT_TWO;   // Select digit 2 (blocking [=] used here because this is combinational logic, not sequential logic)
            7: An[3:0] = `DIGIT_ONE;   // Select digit 1 (blocking [=] used here because this is combinational logic, not sequential logic)
        endcase 
    assign An[7:4] = 4'b1111; // Disable the unused digits An[7:4] (active-low logic). Digits 1, 2, 3, and 4 are disabled (1).
    assign side = accu[2]; // The "side" signal determines which half of the square circuit rotates. The "side" signal gets its value from/is driven by accu[2], the Most Significant Bit (MSB) of this module's
                           // 3-bit accumulator/counter, which typically processes data from the on-board ADXL362 3-axis accelerometer. This bit (accu[2]) determines which half of the square circuit rotates:
                           // 0 represents the first half (0-3), and 1 represents the second half (4-7). The halves do not correspond to physical locations on the board, but a logical divison of the data range
                           // defined within your program's design. This rotation data is often used to control position feedback on the VGA display.
          
endmodule // End of module definition