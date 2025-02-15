`timescale 1ns / 1ps

module power_on_reset(
    input clk, rst_b_i,
    output resetn
);

reg rst_b_ff;
reg rst_b_ff2;

always @ (posedge clk) begin
    rst_b_ff <= rst_b_i;
    rst_b_ff2 <= rst_b_ff;
end

assign resetn = rst_b_ff2;

endmodule