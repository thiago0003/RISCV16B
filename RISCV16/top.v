`timescale 1ns/1ps

`include "RISCV16/defs.vh"

module top (
    input clk, 
	
	//`ifndef DEBUG_MODE
	//	rst,
	//`endif

	input 	flashMiso,
	output 	flashMosi,
	output 	flashClk,
    output 	flashCs,
	output  tx
   );

	wire [15:0]  pc;
	wire [15:0]	 write_reg, src1, src2;
	wire [15:0]  data_read, write_data, alu_result;
	wire [15:0]  instruction;
	wire         mem_write, mem_read, reg_write, rbusy, flash_next_enable;
	wire [1:0]   byte_enable;
	wire [4:0]   RS1, RS2, RD;

    wire resetn;
	
	//`ifdef DEBUG_MODE
		wire reset;
		external_reset external_reset(clk, reset);
	//`endif
	
	// Lida com a entrada do reset
  	power_on_reset power_on_reset(clk, reset, resetn);

	// CPU
	riscv riscv(
		.clk(clk),
		.reset(resetn),
		.rbusy(rbusy),
		.data_read(data_read),
		.instruction(instruction),
		.flash_next_enable(flash_next_enable),
		.src1_data(src1),
		.src2_data(src2),
		.RS1_data(RS1),
		.RS2_data(RS2),
		.data_reg(write_reg),
		.alu_result(alu_result),
		.mem_write_enable(mem_write),
		.mem_read_enable(mem_read),
		.reg_write_enable(reg_write),
		.byte_enable(byte_enable),
		.addr_RD(RD),
		.pc_out(pc),
		.data_memory(write_data)
	);
	
	// Banco de registradores 
	register regs(
		.enable_reg_write(reg_write), 
		.reg_addr1(RS1), 
		.reg_addr2(RS2), 
		.addr_write(RD), 
		.write_data(write_reg), 
		.rd1_data(src1), 
		.rd2_data(src2), 
		.clk(clk),
		.reset(resetn)
	);

	dma dma(
		.clk(clk),
		.reset(resetn),
		.mem_pc(pc), 
		.mem_addr(alu_result), 
		.mem_scr(write_data), 
		.mem_write(mem_write), 
		.is_IO_SPI_next(flash_next_enable),
		.mem_read(mem_read), 
		.byte_enable(byte_enable), 
		.data_read(data_read), 
		.spi_clk(flashClk), 
		.spi_cs_n(flashCs), 
		.spi_mosi(flashMosi), 
		.spi_miso(flashMiso), 
		.instruction(instruction), 
		.SPIFlash_rbusy(rbusy),
		.tx(tx)
	);

endmodule
