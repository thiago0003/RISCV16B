
`include "RISCV16/decoder_position.vh"


module memory_RISCV(
    input         clk, reset, rbusy, mem_read_enable_DEC, mem_write_enable_DEC,
    input  [15:0] alu_result, src2_data, data_read, 
    input  [18:0] instruction_decoder_RISCV_C,
    output        mem_write_enable, mem_read_enable,
    output [1:0]  byte_enable,
    output [15:0] load_data, data_memory
);

	assign load_data = data_read;

	//Memory 
	assign mem_write_enable = mem_write_ff;
	assign mem_read_enable = mem_read_ff;

	reg rbusy_ff;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0) 
			rbusy_ff <= 1'b0;
		else begin
			rbusy_ff <= rbusy;
		end
	end

	reg mem_write_ff;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0) 
			mem_write_ff <= 1'b0;
		else
			mem_write_ff <= mem_write_enable_DEC && !rbusy_ff;
	end

	reg mem_read_ff;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0) 
			mem_read_ff <= 1'b0;
		else
			mem_read_ff <= mem_read_enable_DEC && !rbusy_ff;
	end

	// Valor que sera salvo na nossa memoria e a condicional de escrita
	assign data_memory = instruction_decoder_RISCV_C[`C_SW_POS] ? src2_data : 16'bX;
	
	// // Escrita alinhada na memoria
	assign byte_enable = 2'b11;  // lw/sw

endmodule 