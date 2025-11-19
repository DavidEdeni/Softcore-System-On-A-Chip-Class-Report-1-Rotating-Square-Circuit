`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

module clockRate#(parameter N = 29)( // Defines a counter module named "clockRate" with a a configurable bit width parameter N (default value 29)
    // Digital logic input and output signals for the clockRate module
    input logic clk,                 // Input clock signal (usually 100 MHz for FPGAs). This signal provides timing and synchronization for digital circuits.
    input logic rst,                 // Active-high reset input signal. This signal resets a digital circuit to a known starting state. rst = 1 → reset is on (the circuit resets). rst = 0 → reset is off (the circuit runs normally).
    input logic en,                  // Enable input signal to control counting. This signal controls whether a module is active or paused.
    output logic tic                 // Output pulse signal. This signal is used as a slower clock tic (pulse).
    );
    
    logic [N-1:0] count, ncount; // Declare 29-bit (N-bit) registers for a current counter value (count) and a next counter value (ncount)
    
    always_ff@(posedge(clk), posedge(rst)) // Sequential block that runs on a rising edge of a clock (when clock goes from 0 → 1) or when reset goes high (when reset goes from 0 → 1)
        if(rst)                            // If reset is active (reset = 1)
            count <= 0;                    // Reset counter to zero (non-blocking [<=] used here because this is sequential logic, not combinational logic)
        else
            count <= ncount;               // Otherwise update counter with the next counter value (non-blocking [<=] used here because this is sequential logic, not combinational logic)
            
    always_comb begin                  // Combinational block that calculates the next counter value for the clockRate module
        if(en)                         // If enable is active (en = 1)
            if(count < 10000000) begin // If the counter is less than 10 million (10,000,000)
                ncount = count + 1;    // Increment the counter by 1 (blocking [=] used here because this is combinational logic, not sequential logic)
            end
            else begin
                ncount = 0;            // Reset the next counter value to 0 when the count value reaches the 10,000,000 limit (blocking [=] used here because this is combinational logic, not sequential logic)
            end
        else
            ncount = count;            // If not enabled (en = 0), hold the current counter value (blocking [=] used here because this is combinational logic, not sequential logic)
    end
    
    assign tic = (count == 1); // Generate a single-cycle pulse when the counter equals 1 (used as a timing tic). This creates a short periodic tic (pulse) each time the counter resets and restarts counting.

endmodule // End of module definition
