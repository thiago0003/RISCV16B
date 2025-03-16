
module tb_soc;

    parameter CLK_PERIOD = 100;

    wire flashMiso, flashClk, flashCs, flashMosi, uart_tx;

    reg clk;
    wire resetn;

    // Geração de clock
    always #((CLK_PERIOD / 2)) clk = ~clk;

    external_reset external_reset(clk, resetn);

    top soc(
      .clk(clk),
      //.reset(resetn),
      .flashMiso(flashMiso),
	    .flashMosi(flashMosi),
	    .flashClk(flashClk),
      .flashCs(flashCs),
      .tx(uart_tx)
    );

    flash_tb flash_tb(
      .clk(clk),
      .reset(resetn),
      .CLK(flashClk),
      .MISO(flashMiso),
      .CS_N(flashCs),
      .MOSI(flashMosi)
    );

    // integer i;

    initial begin
        $dumpfile("soc.vcd"); // Define o nome do arquivo VCD
      	$dumpvars(0, tb_soc); // Grava todas as variáveis
        
        // for(i = 0; i < 32; i++)
        //    $dumpvars(1, dut.regs.rf[i]);

        soc.regs.rf[4] = 16'b111111111;
        soc.regs.rf[20] = 16'b0;


        clk = 0;

        #((CLK_PERIOD) * 20000)
        $finish;
    end

endmodule

module flash_tb(   
  input  wire clk, reset, CLK, MOSI, CS_N,
  output wire MISO
);

  reg [31:0] ram[0:255];

always @(posedge clk, negedge reset) begin 
  if(reset == 1'b0) begin
    ram[0] <=  32'h00954081; 
    ram[1] <=  32'h8c894109; 
    ram[2] <=  32'h8cc98ca9; 
    ram[3] <=  32'h908a8ce9; 
    ram[4] <=  32'h4122d006; 
    ram[5] <=  32'h00002021; 
    ram[6] <=  32'h00000000;
    ram[9] <=  32'h00000000;
    ram[10] <= 32'h00000000;
    ram[11] <= 32'h00000000;
    ram[12] <= 32'h00000000;
    ram[13] <= 32'h00000000;
    ram[14] <= 32'h00000000;
    ram[15] <= 32'h00000000;
    ram[16] <= 32'h00000000;
    ram[17] <= 32'h00000000;
    ram[18] <= 32'h00000000;
    ram[19] <= 32'h00000000;
    ram[20] <= 32'h00000000;
    ram[21] <= 32'h00000000;
    ram[22] <= 32'h00000000;
    ram[23] <= 32'h00000000;
    ram[24] <= 32'h00000000;
    ram[25] <= 32'h00000000;
    ram[26] <= 32'h00000000;
    ram[27] <= 32'h00000000;
    ram[28] <= 32'h00954081;
    ram[29] <= 32'h00000000;
    ram[30] <= 32'h00000000;
    ram[31] <= 32'h00000000;
    ram[32] <= 32'h00000000;
    ram[33] <= 32'h00000000;
    ram[34] <= 32'h00000000;
    ram[35] <= 32'h00000000;
    ram[36] <= 32'h00000000;
    ram[37] <= 32'h00000000;
    ram[38] <= 32'h00000000;
    ram[39] <= 32'h00000000;
    ram[40] <= 32'h00000000;
    ram[41] <= 32'h00000000;
    ram[42] <= 32'h00000000;
    ram[43] <= 32'h00000000;
    ram[44] <= 32'h00000000;
    ram[45] <= 32'h00000000;
    ram[46] <= 32'h00000000;
    ram[47] <= 32'h00000000;
    ram[48] <= 32'h00000000;
    ram[49] <= 32'h00000000;
    ram[50] <= 32'h00000000;
    ram[51] <= 32'h00000000;
    ram[52] <= 32'h00000000;
    ram[53] <= 32'h00000000;
    ram[54] <= 32'h00000000;
    ram[55] <= 32'h00000000;
    ram[56] <= 32'h00000000;
    ram[57] <= 32'h00000000;
    ram[58] <= 32'h00000000;
    ram[59] <= 32'h00000000;
    ram[60] <= 32'h00000000;
	end
end

  assign MISO = send_data[31];

  reg [31:0] command;
  reg [31:0] send_data = 32'b0; 
  reg [5:0]  rcv_bitcount, snd_bitcount;

  wire command_reciving = (rcv_bitcount != 0);
  wire command_sending  = (snd_bitcount != 0);

  always @(negedge CS_N, negedge reset) begin
    if(reset == 1'b0)
      rcv_bitcount <= 6'd0;
    else  
      rcv_bitcount <= 6'd32;
  end

  always @(posedge CLK) begin
    if(reset == 1'b0) begin
      command <= 32'b0;
      snd_bitcount <= 6'd32;
    end
    else if(command_reciving) begin
        command <= {command[30:0], MOSI};
        rcv_bitcount <= rcv_bitcount - 6'd1;
    end

    if(rcv_bitcount == 6'd0) begin
      send_data <= {
          ram[{13'b0, command[20:2]}][7], 
          ram[{13'b0, command[20:2]}][6], 
          ram[{13'b0, command[20:2]}][5], 
          ram[{13'b0, command[20:2]}][4], 
          ram[{13'b0, command[20:2]}][3], 
          ram[{13'b0, command[20:2]}][2], 
          ram[{13'b0, command[20:2]}][1], 
          ram[{13'b0, command[20:2]}][0],

          ram[{13'b0, command[20:2]}][15], 
          ram[{13'b0, command[20:2]}][14], 
          ram[{13'b0, command[20:2]}][13], 
          ram[{13'b0, command[20:2]}][12], 
          ram[{13'b0, command[20:2]}][11], 
          ram[{13'b0, command[20:2]}][10], 
          ram[{13'b0, command[20:2]}][9], 
          ram[{13'b0, command[20:2]}][8],

          ram[{13'b0, command[20:2]}][23], 
          ram[{13'b0, command[20:2]}][22], 
          ram[{13'b0, command[20:2]}][21], 
          ram[{13'b0, command[20:2]}][20], 
          ram[{13'b0, command[20:2]}][19], 
          ram[{13'b0, command[20:2]}][18], 
          ram[{13'b0, command[20:2]}][17], 
          ram[{13'b0, command[20:2]}][16],

          ram[{13'b0, command[20:2]}][31], 
          ram[{13'b0, command[20:2]}][30], 
          ram[{13'b0, command[20:2]}][29], 
          ram[{13'b0, command[20:2]}][28], 
          ram[{13'b0, command[20:2]}][27], 
          ram[{13'b0, command[20:2]}][26], 
          ram[{13'b0, command[20:2]}][25], 
          ram[{13'b0, command[20:2]}][24]
        };

      snd_bitcount <= 6'd32;
    end

    if(command_sending) begin
      send_data <= {send_data[30:0], 1'b0};
      snd_bitcount <= snd_bitcount - 6'd1;
    end
  end
  
endmodule