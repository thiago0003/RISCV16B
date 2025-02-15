module fetch_RISCV(
    input         clk, reset, is_conditional_jump, rbusy,
    input  [15:0] jump_add,
    output        enable_pc,
    output [15:0] pc_out, pc_out_ff
);
    assign pc_out = pc;
	assign pc_out_ff = is_conditional_jump ? pc_before_jump : pc_ff;

	wire [15:0] next_pc = (is_conditional_jump && !is_conditional_jump_ff)	? jump_add : pc + 16'd2;	

	assign enable_pc = !rbusy && !(is_conditional_jump && !is_conditional_jump_ff);

	reg is_conditional_jump_ff;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0)
			is_conditional_jump_ff <= 1'b0;
		else
			if(is_conditional_jump && !rbusy)
				is_conditional_jump_ff <= 1'b1;
			else if (is_conditional_jump)
				is_conditional_jump_ff <= is_conditional_jump_ff; 
			else
				is_conditional_jump_ff <= 1'b0;

	end

	reg [15:0] pc_before_jump;
	always @(posedge clk, negedge reset)
    begin
        if(reset == 1'b0) begin
            pc_before_jump <= 16'b0;
        end
        else begin
			if(is_conditional_jump)
				pc_before_jump <= pc_ff;
			else
				pc_before_jump <= pc_before_jump;
		end
	end

	reg [15:0] pc_ff;
	always @(posedge clk, negedge reset)
    begin
        if(reset == 1'b0) begin
            pc_ff <= 16'b0;
        end
        else begin 
            if(pc_ff != pc && !rbusy) begin
				pc_ff <= pc;
            end
            else begin
                pc_ff <= pc_ff;
            end
        end
    end

	reg enable_next_pc;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0) 
			enable_next_pc <= 1'b0;
		else begin
			if(!rbusy) begin
				if(!enable_next_pc)
					enable_next_pc <= 1'b1;
				else	
					enable_next_pc <= enable_next_pc;
			end else
				enable_next_pc <= 1'b0;
		end
	end

	reg enable_next_pc_ff;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0)
			enable_next_pc_ff <= 1'b0;
		else begin
			if(!rbusy) begin
				if(enable_next_pc)
					enable_next_pc_ff <= enable_next_pc;
				else
					enable_next_pc_ff <= enable_next_pc_ff;
			end else
				enable_next_pc_ff <= 1'b0;
		end
	end

    reg [15:0] pc;
	always @(posedge clk, negedge reset) begin
		if(reset == 1'b0)
			pc <= 32'h00000000;
		else begin
			if ((enable_next_pc && !enable_next_pc_ff) || (is_conditional_jump && !is_conditional_jump_ff) && !rbusy)
				pc <= next_pc;
			else
				pc <= pc;	
		end
	end
endmodule