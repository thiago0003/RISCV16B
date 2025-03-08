module fifo #(parameter DATA_WIDTH = 8, parameter FIFO_DEPTH = 256)(
    input wire clk, 
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] din, 
    output reg [DATA_WIDTH-1:0] dout,
    output wire full, empty         
);

    assign empty = (~rst_n) ? 0 : (fifo_count == 0);
    assign full = (~rst_n) ? 0 : (fifo_count == FIFO_DEPTH);

    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1]; 
    reg [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;    
    reg [FIFO_DEPTH-1:0] fifo_count;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            wr_ptr <= 0;
        end else begin
            wr_ptr <= wr_ptr + (wr_en && !full);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            rd_ptr <= 0;
        end else begin
            rd_ptr <= rd_ptr + (rd_en && !empty);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            fifo_count <= 0;
        end else begin
            fifo_count <= fifo_count + (wr_en && !full) -(rd_en && !empty);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            dout <= 0;
        end else begin
            if (rd_en && !empty) begin
                dout <= fifo_mem[rd_ptr];
            end
        end
    end
endmodule
