`timescale 1ns/1ps

`include "RISCV16/defs.vh"

module dma(
        input         clk, 
        input         reset,
        input  [15:0] mem_pc, 
        input  [15:0] mem_addr,
        input  [15:0] mem_scr,
        input         mem_write, mem_read, is_IO_SPI_next,
        input  [1:0]  byte_enable,
        output [15:0] data_read,
        output        spi_clk, spi_cs_n,

        input  spi_miso,
        output spi_mosi,

        output [15:0] instruction,
        output        SPIFlash_rbusy,
        output        tx
);  

    assign data_read = read_data_RAM;  

    //------------------------------------- Instruction SPI -------------------------------------------------//
    
    wire is_IO_SPI  = reset && is_IO_SPI_next;

    wire [31:0] instruction_;
    assign instruction = mem_pc[1] ? instruction_[31:16] : instruction_[15:0];

    flash flash(
        .clk(clk), 
        .reset(reset),
        .rstrb(is_IO_SPI), 
        .CLK(spi_clk), 
        .MISO(spi_miso), 
        .MOSI(spi_mosi), 
        .CS_N(spi_cs_n), 
        .word_address({16'd0, mem_pc}), 
        .rbusy(SPIFlash_rbusy), 
        .rdata(instruction_)
    );

    //------------------------------------- RAM -------------------------------------------------//
    wire [15:0] read_data_RAM;
    wire        mem_write_RAM = mem_write;

    wire [7:0] memo_output;
    wire [9:0] vaddr;

  	blockram blockram
    (
        .clk(clk), 
        .reset(reset),
        .write_enable(mem_write_RAM), 
        .byte_enable(byte_enable), 
        .addr(mem_addr[`BLOCK_RAM_SIZE -1:0]), 
        .data_in(mem_scr), 
        .data_out(read_data_RAM)
    );

    //------------------------------------- UART -------------------------------------------------//

    wire is_IO = !mem_addr[15] && !(|mem_addr[14:10]) && mem_write;

    wire [7:0] dout;
    wire rd_en, full, empty;

    fifo uart_fifo(
        .clk(clk),              //i 
        .rst_n(reset),          //i
        .wr_en(is_IO),          //i
        .rd_en(rd_en),          //i
        .din(mem_scr[7:0]),     //i
        .dout(dout),            //o
        .full(full),            //o   
        .empty(empty)           //o    
    );

    wire UART_TX_ready;
    wire uart_enable = UART_TX_ready && empty;

    uart_tx uart_tx( 
        .clk(clk), 
        .reset(reset),                  // i
        .uart_enable(uart_enable),      // i
        .data(dout),                    // i
        .DELAY_FRAMES(mem_addr[9:0]),   // i
        .UART_TX_ready(UART_TX_ready),  //o 
        .uart_tx(tx)               //o
    );


endmodule
