`timescale 1ns/1ps

module riscv( 
		input  		  clk, reset, rbusy, receiving_data_spi,
    	input  [15:0] instruction,
        input  [15:0] data_read, 
        input  [15:0] src1_data, src2_data,
		output [4:0]  RS1_data, RS2_data, 
		output [15:0] data_reg, 
    	output 	      mem_write_enable, mem_read_enable, reg_write_enable, flash_next_enable,
		output [1:0]  byte_enable,
		output [4:0]  addr_RD,
		output [15:0] pc_out, pc_ff,
		output [15:0] data_memory, alu_result
	);

	reg rbusy_ff;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0) 
			rbusy_ff <= 1'b0;
		else begin
			rbusy_ff <= rbusy;
		end
	end
	
	//------------------------------------------------- FETCH ------------------------------------------------- //
	wire is_conditional_jump_DEC;
	wire [15:0] imm, jump_add_DEC, pc_ff;

	fetch_RISCV fetch_RISCV(
		.clk(clk),
		.reset(reset),
		.jump_add(jump_add_DEC),
		.rbusy(rbusy),
		.receiving_data_spi(receiving_data_spi),
		.is_conditional_jump(is_conditional_jump_DEC),
		.enable_pc(flash_next_enable),
		.pc_out(pc_out),
		.pc_out_ff(pc_ff)
	);

	//------------------------------------------------- DECODE -------------------------------------------------//
	wire mem_write_enable_DEC;
	wire mem_read_enable_DEC;
	wire reg_write_enable_DEC;
	wire [4:0] rs1_address_C, rs2_address_C, rd_address_C;
	wire [18:0] instruction_decoder_RISCV_C;

	decode_RISCV_C decode_RISCV_C(
		.clk(clk),
		.reset(reset),
		.rbusy(rbusy),
		.receiving_data_spi(receiving_data_spi),
		.instruction(instruction),
		.imm(imm),
		.pc_out(pc_out),
		.src1_data(src1_data),
		.src2_data(src2_data),
		.jump_add(jump_add_DEC),
		.is_conditional_jump(is_conditional_jump_DEC),
		.mem_write_enable(mem_write_enable_DEC),
		.mem_read_enable(mem_read_enable_DEC),
		.reg_write_enable(reg_write_enable_DEC),
		.rs1_address(rs1_address_C),
		.rs2_address(rs2_address_C),
		.rd_address(rd_address_C),
		.instruction_decoder(instruction_decoder_RISCV_C)
	);

	assign RS1_data = rs1_address_C;
	assign RS2_data = rs2_address_C;
	assign addr_RD  = rd_address_C;

	//------------------------------------------------- EXEC -------------------------------------------------//

	exec_RISCV_C exec_RISCV_C(
		.clk(clk),
		.reset(reset),
		.src1_data(src1_data), 
		.src2_data(src2_data), 
		.pc_ff(pc_ff), 
		.imm(imm),
		.instruction_decoder_RISCV_C(instruction_decoder_RISCV_C),
		.alu_result(alu_result)
	);

	//----------------------------------------------- MEMORY -------------------------------------------------//

	wire [15:0] load_data_MEM;

	memory_RISCV memory_RISCV(
		.clk(clk),
		.reset(reset),
		.rbusy(rbusy_ff),
		.mem_read_enable_DEC(mem_read_enable_DEC),
		.mem_write_enable_DEC(mem_write_enable_DEC),	
    	.alu_result(alu_result), 
		.src2_data(src2_data), 
		.data_read(data_read), 
    	.instruction_decoder_RISCV_C(instruction_decoder_RISCV_C),
    	.mem_write_enable(mem_write_enable), 
		.mem_read_enable(mem_read_enable),
    	.byte_enable(byte_enable),
		.load_data(load_data_MEM), 
		.data_memory(data_memory)
	);

	//----------------------------------------------- WRITE BACK -------------------------------------------------//

	reg enable;
	always @(*) begin
		enable <= 1'b1;
		
		if(reg_write_enable_DEC) begin
			enable <= 1'b0;
		end
	end

	assign reg_write_enable = !(reg_write_enable_DEC && !enable);
	assign data_reg = mem_read_enable_DEC ? load_data_MEM : alu_result;
endmodule
