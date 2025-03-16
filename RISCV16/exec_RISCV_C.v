`timescale 1ns/1ps

`include "RISCV16/decoder_position.vh"
`include "RISCV16/decoder.vh"

module exec_RISCV_C(
	input 		  clk, reset,
    input  [15:0] src1_data, src2_data, imm,
	input  [15:0] pc_ff,
    input  [18:0] instruction_decoder_RISCV_C,
    output [15:0] alu_result
);

	wire [15:0] srai_tmp;
	assign srai_tmp = $signed(src1_data) >>> imm[4:0];

	assign alu_result = instruction_decoder_RISCV_C[`C_ADDI_POS]	? $signed(src1_data) + $signed(imm):
						instruction_decoder_RISCV_C[`C_SUB_POS]		? $signed(src1_data) - $signed(src2_data):
						instruction_decoder_RISCV_C[`C_ANDI_POS]	? $signed(src1_data) & $signed(imm):
						instruction_decoder_RISCV_C[`C_AND_POS]		? $signed(src1_data) & $signed(src2_data):
						instruction_decoder_RISCV_C[`C_OR_POS]		? $signed(src1_data) | $signed(src2_data):
						instruction_decoder_RISCV_C[`C_SRLI_POS]	? $signed(src1_data) >> $signed(imm[4:0]):
						instruction_decoder_RISCV_C[`C_LUI_POS]		? imm:
						instruction_decoder_RISCV_C[`C_LI_POS] 		? imm:
						instruction_decoder_RISCV_C[`C_XOR_POS]		? $signed(src1_data) ^ $signed(src2_data):
						instruction_decoder_RISCV_C[`C_SRAI_POS]    ? srai_tmp: 
                        instruction_decoder_RISCV_C[`C_SLLI_POS]    ? $signed(src1_data) << $signed(imm[4:0]):
                        instruction_decoder_RISCV_C[`C_JALR_POS]    ? pc_ff + 32'd2:
						instruction_decoder_RISCV_C[`C_JAL_POS]     ? pc_ff + 32'd2:
                        instruction_decoder_RISCV_C[`C_ADD_POS]     ? $signed(src1_data) + $signed(src2_data):
						instruction_decoder_RISCV_C[`C_LW_POS]	    ? $signed(src1_data) + $signed(imm):
						instruction_decoder_RISCV_C[`C_SW_POS]	    ? $signed(src1_data) + $signed(imm):
						16'b0;

endmodule 