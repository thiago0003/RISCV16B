`timescale 1ns/1ps
module flash( 
    input wire 	       clk, reset,   // system clock
    input wire 	       rstrb,        // read strobe		
    input wire [31:0]  word_address, // address of the word to be read

    output wire [31:0] rdata,        // data read
    output wire        rbusy,        // asserted if busy receiving data			    

		             // SPI flash pins
    output wire        CLK,  // clock
    output reg         CS_N, // chip select negated (active low)		
    output wire        MOSI, // master out slave in (data to be sent to flash)
    input  wire        MISO  // master in slave out (data received from flash)
);

  reg [5:0]  snd_bitcount;
  reg [31:0] cmd_addr;
  reg [5:0]  rcv_bitcount;
  reg [31:0] rcv_data;
  wire       sending   = (snd_bitcount != 0) && reset;
  wire       receiving = (rcv_bitcount != 0) && reset;
  wire       busy = sending | receiving;
  assign     rbusy = !CS_N; 
  
  assign  MOSI  = cmd_addr[31];
  assign  CLK   = !CS_N && !clk && reset; // CLK needs to be inverted (sample on posedge, shift of negedge) 
                                  // and needs to be disabled when not sending/receiving (&& !CS_N).

  // since least significant bytes are read first, we need to swizzle...
  assign rdata = {rcv_data[7:0],rcv_data[15:8],rcv_data[23:16],rcv_data[31:24]};

  always @(posedge clk, negedge reset) begin
    if(reset == 1'b0)
      CS_N <= 1'b0;
    else begin
      if(rstrb)
        CS_N <= 1'b0;
      else if(!busy)
        CS_N <= 1'b1;
      else
        CS_N <= CS_N;
    end
  end

  always @(posedge clk, negedge reset) begin
    if(reset == 1'b0)
      snd_bitcount <= 6'd32;
    else begin
      if(rstrb)
        snd_bitcount <= 6'd32;
      else if(sending)
        snd_bitcount <= snd_bitcount - 6'd1;
      else 
        snd_bitcount <= snd_bitcount;
    end
  end

  always @(posedge clk, negedge reset) begin
    if(reset == 1'b0)
      cmd_addr <= 32'd0;
    else begin
      if(rstrb)
        cmd_addr <= {8'h03, word_address[23:0]};
      else if(sending)
        cmd_addr <= {cmd_addr[30:0],1'b1};
      else
        cmd_addr <= cmd_addr;
    end
  end

  always @(posedge clk, negedge reset) begin
    if(reset == 1'b0)
      rcv_bitcount <= 6'd0;
    else begin
      if((sending) && (!rstrb)) begin

        if(snd_bitcount == 6'd1)
          rcv_bitcount <= 6'd32;
        else 
          rcv_bitcount <= rcv_bitcount;
      end
      else if((receiving) && (!rstrb))
        rcv_bitcount <= rcv_bitcount - 6'd1;
      else 
        rcv_bitcount <= rcv_bitcount;
    end
  end

  always @(posedge clk) begin
    if(receiving)
      rcv_data <= {rcv_data[30:0],MISO};
    else
      rcv_data <= rcv_data;
  end
endmodule
