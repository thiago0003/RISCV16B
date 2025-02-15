`timescale 1ns/1ps

`include "RISCV16/defs.vh"

// `ifdef DEBUG_MODE
  module external_reset(
    input clk, 
    output resetn);

    reg [5:0] q = 6'b0;
  
    always@(negedge clk)
        q <= {q,1'b1};

    assign resetn = &q;
  endmodule
// `endif