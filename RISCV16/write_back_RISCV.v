module write_back_RISCV(
    input clk, reset,
    input [31:0] alu_result, load_data_MEM,
    input reg_write_enable_DEC, mem_read_enable_DEC,
    output reg_write_enable,
    output [31:0] data_reg
);

	reg reg_write_enable_ff; // Flip-flop para armazenar o sinal

	always @(*) begin
		if (!reset) begin
			reg_write_enable_ff <= 1'b0; // Reset o flip-flop
		end else begin
			reg_write_enable_ff <= reg_write_enable_DEC;
		end
	end

	assign reg_write_enable = reg_write_enable_DEC && !reg_write_enable_ff;
	assign data_reg = mem_read_enable_DEC ? load_data_MEM : alu_result;

endmodule