`timescale 1ns/1ps

`include "RISCV16/decoder_position.vh"
`include "RISCV16/decoder.vh"

module decode_RISCV_C(
    input clk, reset,
    input [15:0] instruction, // Compressed instruction is 16 bits
    input [15:0] pc_out, 
    input [15:0] src1_data, src2_data,
    output is_conditional_jump, 
    output mem_write_enable, mem_read_enable, reg_write_enable,
    output [4:0] rs1_address, rs2_address, rd_address,
    output [15:0] imm, 
    output [15:0] jump_add,
    output [18:0] instruction_decoder
);

    wire [1:0] opcode = instruction[1:0];
    wire [2:0] funct3 = instruction[15:13];

    wire [1:0] funct2 = instruction[11:10];
    wire [1:0] rfunct2 = (funct2 == 2'b11) ? instruction[6:5] : 2'bx;

    wire [4:0] rd_rs1 = (funct3 == 3'b100) ? {2'b0, instruction[9:7]} : instruction[11:7]; // For compressed instructions, use rd/rs1 as rs1
    wire [4:0] rs2 = {2'b0, instruction[4:2]}; // For compressed instructions, use rs2
    
    // Immediate value assignment for compressed instructions
    assign imm = (opcode == 2'b01 && funct3 == 3'b000) ? {10'b0, instruction[12], instruction[6:2]} : // C.ADDI
                 (opcode == 2'b01 && funct3 == 3'b010) ? {11'b0, instruction[12], instruction[6:2]} : // C.LI
                 (opcode == 2'b01 && funct3 == 3'b011) ? { 9'b0, instruction[12], instruction[6:2], 12'b0} : // C.LUI
                 (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b00) ? {10'b0, instruction[12], instruction[6:2]} : // C.SRLI
                 (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b01) ? {10'b0, instruction[12], instruction[6:2]} : // C.SRAI
                 (opcode == 2'b01 && funct3 == 3'b100 && funct2 == 2'b10) ? {10'b0, instruction[12], instruction[6:2]} : // C.ANDI
                 
                
                // Montagem da instrucao J e JAL de acordo com a Doc 20240411
                    // imm[11]  = instruction[12]
                    // imm[10]  = instruction[8]
                    // imm[9:8] = instruction[10:9]
                    // imm[7]   = instruction[6]
                    // imm[6]   = instruction[7]
                    // imm[5]   = instruction[2]
                    // imm[4]   = instruction[11]
                    // imm[3:1] = instruction[5:3]
                    // imm[0]   = 1'b0
                 (opcode == 2'b01 && funct3 == 3'b101) || (opcode == 2'b01 && funct3 == 3'b001) ? 
                    {instruction[12], instruction[8], instruction[10:9], instruction[6], instruction[7], 
                    instruction[2], instruction[11], instruction[5:3], 1'b0} : // C.J ou C.JAL
            
                 (opcode == 2'b01 && funct3 == 3'b110) ? {{25{instruction[12]}}, instruction[6:2]} : // C.BEQZ
                 (opcode == 2'b01 && funct3 == 3'b111) ? {{25{instruction[12]}}, instruction[6:2]} : // C.BNEZ

                 (opcode == 2'b10 && funct3 == 3'b000) ? {{25{instruction[12]}}, instruction[6:2]} : // C.SLLI
                 (opcode == 2'b10 && funct3 == 3'b100 && instruction[12] == 1'b1 && instruction[6:2] == 5'b00000) ? {{25{instruction[12]}}, instruction[6:2]} : // C.JALR
                 (opcode == 2'b10 && funct3 == 3'b100 && instruction[12] == 1'b1 && instruction[6:2] != 5'b00000) ? {{25{instruction[12]}}, instruction[6:2]} : // C.ADD


                // Montagem da instrucao LW acordo com a Doc 20240411
                    // imm[7]   = instruction[3]
                    // imm[6]   = instruction[2]
                    // imm[5]   = instruction[12]
                    // imm[4:2]   = instruction[6:4]
                    // imm[1:0]   = 2'b0
                  ((opcode == 2'b10 && funct3 == 3'b010 && instruction[11:7] != 5'b00000) || (opcode == 2'b10 && funct3 == 3'b110)) ? 
                    {instruction[3], instruction[12], instruction[6:4], 2'b0} : // C.LW

                // Montagem da instrucao SW acordo com a Doc 20240411
                    // imm[7:6]   = instruction[8:7]
                    // imm[5:2]   = instruction[12:9]
                    // imm[1:0]   = 2'b0
                 (opcode == 2'b10 && funct3 == 3'b110) ? {instruction[8:7], instruction[12:9], 2'b0} : // C.SW
                 32'b0;

    // Instruction decoder assignment for compressed instructions
    assign instruction_decoder = {`C_SW, `C_LW, `C_ADD, `C_JALR, `C_SLLI, `C_BNEZ, `C_BEQZ, `C_J, `C_AND, `C_OR, `C_XOR, `C_SUB, `C_ANDI, `C_SRAI, `C_SRLI, `C_LUI, `C_LI, `C_JAL, `C_ADDI};

    // Address assignments for compressed instructions
    assign rs2_address = (funct3 == 3'b100 && (funct2 == 2'b11 ||  instruction[12] == 1'b1) && (|opcode)) ? rs2 : 
                         (funct3 == 3'b110) ? {2'b0, instruction[6:2]} : 
                         5'b0;

    assign rd_address = rd_rs1;
    assign rs1_address = ( `C_SW || `C_LW ) ? 16'd1 : rd_rs1;

    // Control signal assignments for compressed instructions
    assign mem_write_enable = `C_SW; 
    assign mem_read_enable = `C_LW; 
    assign reg_write_enable = !is_conditional_jump && rd_address != 5'b0;

    // Jump address calculation for compressed instructions
    wire [15:0] jump_addr = instruction_decoder[`C_J_POS] ? (pc_out - 16'd2) + $signed(imm) :
                           (instruction_decoder[`C_JAL_POS] && ($signed(src1_data) == $signed(src2_data))) ? (pc_out - 16'd2) + $signed(imm) :
                           pc_out;


    wire is_conditional_jump_internal = (`C_J || `C_JAL || `C_BEQZ || `C_BNEZ);
    assign is_conditional_jump = enable_next_jump;

	reg enable_next_jump;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0)
			enable_next_jump <= 1'b0;
		else begin
			if(is_conditional_jump_internal && !enable_next_jump)
				enable_next_jump <= is_conditional_jump_internal;
			else
				enable_next_jump <= 1'b0;
		end
	end

	reg enable_next_jump_ff;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0)
			enable_next_jump_ff <= 1'b0;
		else begin
			enable_next_jump_ff <= enable_next_jump;
		end
	end

	reg [15:0] jump;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0)
			jump <= 16'b0;
		else
			if (is_conditional_jump_internal && !enable_next_jump_ff && !enable_next_jump)
				jump <= jump_addr;
			else
				jump <= jump;
	end

	assign jump_add = jump;

endmodule