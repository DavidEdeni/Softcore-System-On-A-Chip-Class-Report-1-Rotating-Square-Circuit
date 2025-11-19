`timescale 1ns / 1ps // Defines this module's simulation time unit (1 ns) and time precision unit (1 ps)

`define TOPSIDE    1'b0 // Constant 1-bit "side" signal for when the 3-bit accumulator (accu) [from the digitSel.sv (System Verilog) module] is in the first half (0-3), representing the top side/half
`define BOTTOMSIDE 1'b1 // Constant 1-bit "side" signal for when the 3-bit accumulator (accu) [from the digitSel.sv (System Verilog) module] is in the second half (4-7), representing the bottom side/half
`define TOP        7'b0011100 // Constant 7-bit/segment display pattern for the text "TOP" (segments A-G) (Segment A: Bit 0, Segment B: Bit 1, Segment C: Bit 2, Segment D: Bit 3, Segment E: Bit 4, Segment F: Bit 5, Segment G: Bit 6)
                              // 7'XXXXXXX: Bit 6/Seg G, Bit 5/Seg F, Bit 4/Seg E, Bit 3/Seg D, Bit 2/Seg C, Bit 1/Seg B, Bit 0/Seg A.
                              // The segments are activated by driving the cathodes (CA-CG) LOW. This means 0 = ON.
                              // 0011100 means segment G is on, segment F is on, segment E is off, segment D is off, segment C is off, segment B is on, and segment A is on.
`define BOTTOM     7'b1100010 // Constant 7-bit/segment display pattern for the text "BOTTOM" (segments A-G) (Segment A: Bit 0, Segment B: Bit 1, Segment C: Bit 2, Segment D: Bit 3, Segment E: Bit 4, Segment F: Bit 5, Segment G: Bit 6)
                              // 7'XXXXXXX: Bit 6/Seg G, Bit 5/Seg F, Bit 4/Seg E, Bit 3/Seg D, Bit 2/Seg C, Bit 1/Seg B, Bit 0/Seg A.
                              // The segments are activated by driving the cathodes (CA-CG) LOW. This means 0 = ON.
                              // 1100011 means segment G is off, segment F is off, segment E is on, segment D is on, segment C is on, segment B is off, and segment A is on.

                              
//              Nexys4 DDR™ FPGA Board One-digit Seven Segment Display Model (Common anode circuit): 
//                                AN0      <- Anodes
//                                 |
//                              ---A---                --
//                             |       |                 |
//                             F       B                  > Segments A, B, F, and G are all on when Case "TOPSIDE" is active, when side = 1 (1'b1), when the top/second half (4-7) of the square circuit is set to rotate. This pattern (7'b0011100) is generated.
//                             |       |                 |
//                              ---G---                --
//                             |       |                 |
//                             E       C                  > Segments A, C, D, and E are all on when Case "BOTTOMSIDE" is active, when side = 0 (1'b0), when the bottom/first half (0-3) of the square circuit is set to rotate. This pattern (7'b1100010) is generated.
//                             |       |                 |
//                              ---D---                --
//                             |       |
//                            CG      DP    <- Cathodes


module segSel( // Defines a segment selector module named "segSel"
    // Digital logic input and output signals for the segSel module
    input logic side, // Input signal indicating the "half of rotation" (top/bottom side) from the digitSel module's accu[2]
    output logic [6:0] CX // Output 7-bit/segment signal (segments A to G) that drives the active digit (AN0 on the diagram)
    );
    
    always_comb begin // Combinational block that sets a rotation pattern (TOP or BOTTOM) depending on the side input signal
        case (side) // Selects an action based on the value of the "side" input signal (0 or 1)
            `TOPSIDE: // Case when the "side" signal is 1'b0 (the first half of rotation)
                CX <= `TOP; // Set the 7-bit/segment output (CX) to display the "TOP" pattern (7'b1100010)
            `BOTTOMSIDE: // Case when the "side" signal is 1'b1 (the second half of rotation)
                CX <= `BOTTOM; // Set the 7-bit/segment output (CX) to display the "BOTTOM" pattern (7'b1100011)
        endcase
    end
    
endmodule // End of module definition


//              Nexys4 DDR™ FPGA Board One-digit Seven Segment Display Model (Common anode circuit):
//                                AN0      <- Anodes
//                                 |
//                              ---A---
//                             |       |
//                             F       B
//                             |       |
//                              ---G---
//                             |       |
//                             E       C
//                             |       |
//                              ---D---
//                             |       |
//                            CG      DP    <- Cathodes


//              Nexys4 DDR™ FPGA Board Eight-digit Seven Segment Display Model (Common anode circuit):
//       AN7        AN6        AN5        AN4       AN3        AN2        AN1        AN0      <- Anodes
//        |          |          |          |         |          |          |          |
//     ---A---    ---A---    ---A---    ---A---   ---A---    ---A---    ---A---    ---A--- 
//    |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |
//    F       B  F       B  F       B  F       B  F       B  F       B  F       B  F       B
//    |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |
//     ---G---    ---G---    ---G---    ---G---    ---G---    ---G---    ---G---    ---G---
//    |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |
//    E       C  E       C  E       C  E       C  E       C  E       C  E       C  E       C
//    |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |
//     ---D---    ---D---    ---D---    ---D---    ---D---    ---D---    ---D---    ---D---
//    |       |  |       |  |       |  |       |  |       |  |       |  |       |  |       |
//   CA      CB CC      CD CE      CF CG      DP  CA      CB CC      CD CE      CF CG      DP   <- Cathodes