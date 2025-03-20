module fetch_RISCV(
    input         clk, reset, is_conditional_jump, rbusy, receiving_data_spi,
    input  [15:0] jump_add,
    output        enable_pc,
    output [15:0] pc_out, pc_out_ff
);

	assign pc_out_ff = !rbusy ? pc_ff : (is_conditional_jump_ff ? pc_ff: pc_ff - 16'd2); // 
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

	reg [15:0] is_conditional_jump_ff;
	always @(posedge clk, negedge reset)
    begin
        if(reset == 1'b0) begin
            is_conditional_jump_ff <= 16'b0;
        end
        else begin
			if(!rbusy) begin 				
				is_conditional_jump_ff <= is_conditional_jump;
			end
			else begin
				is_conditional_jump_ff <= is_conditional_jump_ff;
			end
        end
    end

	reg [15:0] pc;
	always @(negedge reset, negedge rbusy, negedge clk) 
	begin
		if (reset == 1'b0) begin
			pc <= 16'b0;
		end
		else if (is_conditional_jump) begin
			pc <= jump_add;
		end
		else if(!rbusy && !is_conditional_jump) begin
			pc <= pc_ff + 2'd2;
		end
		else begin
			pc <= pc_ff; 
		end
	end

	assign pc_out = pc;
endmodule