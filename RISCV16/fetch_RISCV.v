module fetch_RISCV(
    input         clk, reset, is_conditional_jump, rbusy, receiving_data_spi,
    input  [15:0] jump_add,
    output        enable_pc,
    output [15:0] pc_out, pc_out_ff
);

	assign pc_out_ff = !rbusy ? pc_ff : (is_conditional_jump ? pc_ff - 16'd2 - jump_add : pc_ff - 16'd2); // 
	assign enable_pc = !rbusy;

	reg [15:0] pc_ff;
	always @(posedge clk, negedge reset)
    begin
        if(reset == 1'b0) begin
            pc_ff <= 16'b0;
        end
        else begin
			if(!rbusy) begin 				
				pc_ff <= pc_out;
			end
			else begin
				pc_ff <= pc_ff;
			end
        end
    end

	reg [15:0] pc;
	always @(negedge reset, negedge rbusy or posedge is_conditional_jump) 
	begin
		if (reset == 1'b0) begin
			pc <= 16'b0;
		end
		else if (is_conditional_jump) begin
			pc <= jump_add;
		end
		else begin
			pc <= pc_ff + 16'd2; 
		end
	end

	assign pc_out = pc;
endmodule