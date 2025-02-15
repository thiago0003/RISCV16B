module fifo #(parameter DATA_WIDTH = 8, parameter FIFO_DEPTH = 256)(
    input wire clk, 
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] din, 
    output reg [DATA_WIDTH-1:0] dout,
    output reg full,        
    output reg empty         
);

    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1]; 
    reg [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;    
    reg [FIFO_DEPTH-1:0] fifo_count;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            fifo_count <= 0;
            full <= 0;
            empty <= 1;
            dout <= 0;
        end else begin
            if (wr_en && !full) begin
                fifo_mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
                fifo_count <= fifo_count + 1;
            end

            if (rd_en && !empty) begin
                dout <= fifo_mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                fifo_count <= fifo_count - 1;
            end

            full <= (fifo_count == FIFO_DEPTH);
            empty <= (fifo_count == 0);
        end
    end
endmodule
