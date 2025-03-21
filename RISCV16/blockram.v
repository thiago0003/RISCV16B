`timescale 1ns/1ps

`include "RISCV16/defs.vh"

module  blockram
	( 	
		input clk, reset, write_enable,
		input  [1:0] byte_enable,
		input  [`BLOCK_RAM_SIZE -1:0] addr,  
		input  [15:0] data_in,
		output [15:0] data_out
	);

        (* ram_style = "block" *) reg [15:0] ram[0:(2 ** `BLOCK_RAM_SIZE) -1];
	
        reg [15:0] data;

        always @(posedge clk)
        begin		
            if(write_enable) begin
                if(byte_enable[0]) ram[addr[`BLOCK_RAM_SIZE -1:2]][7:0]  <= data_in[7:0];
                if(byte_enable[1]) ram[addr[`BLOCK_RAM_SIZE -1:2]][15:8] <= data_in[15:8];
            end
        end

        always @(posedge clk, negedge reset) begin
            if(reset == 1'b0) begin
                data <= 16'b0;
            end 
            else begin
                data <= ram[addr[`BLOCK_RAM_SIZE -1:2]];
            end
        end

        assign data_out = data;

endmodule
