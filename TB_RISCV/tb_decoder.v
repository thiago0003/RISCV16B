`timescale 1ns / 1ps

module decode_RISCV_C_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [15:0] instruction;
    reg [15:0] pc_out;
    wire [31:0] src1_data;
    wire [31:0] src2_data;

    // Outputs
    wire is_conditional_jump;
    wire mem_write_enable;
    wire mem_read_enable;
    wire reg_write_enable;
    wire [4:0] rs1_address;
    wire [4:0] rs2_address;
    wire [4:0] rd_address;
    wire [15:0] imm;
    wire [15:0] jump_add;
    wire [13:0] instruction_decoder;

    // Instantiate the Unit Under Test (UUT)
    decode_RISCV_C uut (
        .clk(clk), 
        .reset(reset), 
        .instruction(instruction), 
        .pc_out(pc_out), 
        .src1_data(src1_data[15:0]), 
        .src2_data(src2_data[15:0]), 
        .is_conditional_jump(is_conditional_jump), 
        .mem_write_enable(mem_write_enable), 
        .mem_read_enable(mem_read_enable), 
        .reg_write_enable(reg_write_enable), 
        .rs1_address(rs1_address), 
        .rs2_address(rs2_address), 
        .rd_address(rd_address), 
        .imm(imm), 
        .jump_add(jump_add), 
        .instruction_decoder(instruction_decoder)
    );

	wire [15:0] alu_result_C;
    wire [15:0] pc_ff;

	exec_RISCV_C exec_RISCV_C(
		.clk(clk),
		.reset(reset),
		.src1_data(src1_data[15:0]), 
		.src2_data(src2_data[15:0]), 
		.pc_ff(pc_ff), 
		.imm(imm),
		.instruction_decoder_RISCV_C(instruction_decoder),
		.alu_result(alu_result_C)
	);

    register regs(
		.enable_reg_write(reg_write_enable), 
		.reg_addr1(rs1_address), 
		.reg_addr2(rs2_address), 
		.addr_write(rd_address), 
		.write_data({16'b0, alu_result_C}), 
		.rd1_data(src1_data), 
		.rd2_data(src2_data), 
		.clk(clk),
		.reset(reset)
	);

    initial begin
        $dumpfile("decoder.vcd"); // Define o nome do arquivo VCD
      	$dumpvars(0, decode_RISCV_C_tb); // Grava todas as variáveis

        // Initialize Inputs
        clk = 0;
        reset = 0;
        instruction = 0;
        pc_out = 0;

        regs.rf[4] = 32'b111111111;
        regs.rf[20] = 32'b0;

        // Wait for global reset
        #100;
        reset = 1;

        // Test C.ADDI
        instruction = 16'b0000101000010001;
        #20;

        // Test C.ANDI
        instruction = 16'b1000101000010001;
        #20;

        // Test C.XOR
        instruction = 16'b1000111100100001;
        #20;

        // Test C.SUB
        instruction = 16'b1000111100000001;
        #20;

        // Test C.OR
        instruction = 16'b1000111101000001;
        #20;

        // Test C.AND
        instruction = 16'b1000110011100001;
        #20;

        // Test C.JAL
        instruction = 16'b0010000000000001;
        #20;

        // Test C.LI
        instruction = 16'b0100000000000001;
        #20;

        // Test C.LUI
        instruction = 16'b0110000000000001;
        #20;

        // Test C.SRLI
        instruction = 16'b1000000000000001;
        #20;

        // Test C.SRAI
        instruction = 16'b1000010000000001;
        #20;

        // Test C.J
        instruction = 16'b1010000000000001;
        #20;

        // Test C.BEQZ
        instruction = 16'b1100000000000001;
        #20;

        // Test C.BNEZ
        instruction = 16'b1110000000000001;
        #20;

        // Finish simulation
        $finish;
    end
    
    // Clock generation
    always #10 clk = ~clk;
    
endmodule