`timescale 1ns/1ps
module uart_tx( input clk, reset,
                input uart_enable,
                input [7:0] data,
                input [9:0] DELAY_FRAMES,
                output UART_TX_ready, uart_tx
);

localparam TX_STATE_IDLE = 0;
localparam TX_STATE_START_BIT = 1;
localparam TX_STATE_WRITE = 2;
localparam TX_STATE_STOP_BIT = 3;

reg [3:0] txState;
reg [24:0] txCounter;
reg txPinRegister, uart_ready;
reg [2:0] txBitNumber;
reg [7:0] data_valid;

assign uart_tx = txPinRegister;
assign UART_TX_ready = uart_ready;

always @(posedge clk, negedge reset) begin
    if(reset == 1'b0)
        txState <= 4'b0;
    else begin
        case (txState)
            TX_STATE_IDLE: begin
                if (uart_enable == 1'b1) 
                    txState <= TX_STATE_START_BIT;
                else 
                    txState <= txState;
            end 

            TX_STATE_START_BIT: begin
                if ((txCounter + 1'd1) == DELAY_FRAMES)
                    txState <= TX_STATE_WRITE;
                else 
                    txState <= txState;
            end

            TX_STATE_WRITE: begin
                if ((txCounter + 1'd1) == DELAY_FRAMES) begin
                    if (txBitNumber == 3'b111) 
                        txState <= TX_STATE_STOP_BIT;
                    else 
                        txState <= TX_STATE_WRITE;
                end else 
                    txState <= txState;
            end
            
            TX_STATE_STOP_BIT: begin
                if ((txCounter + 1'd1) == DELAY_FRAMES)
                    txState <= TX_STATE_IDLE;
                else 
                    txState <= txState; 
            end
            
            default: 
                txState <= txState;

        endcase      
    end
end

always @(posedge clk, negedge reset) begin
    if(reset == 1'b0)
        txCounter <= 25'b0;
    else begin
        case (txState)
            TX_STATE_IDLE: begin
                if (uart_enable == 1'b1)
                    txCounter <= 25'b0;
                else 
                    txCounter <= txCounter;
            end 

            TX_STATE_START_BIT: begin
                if ((txCounter + 1'd1) == DELAY_FRAMES)
                    txCounter <= 25'b0;
                else 
                    txCounter <= txCounter + 1'd1;
            end
            
            TX_STATE_WRITE: begin
                if ((txCounter + 1'd1) == DELAY_FRAMES)
                    txCounter <= 25'b0;
                else 
                    txCounter <= txCounter + 1'd1;
            end
            
            TX_STATE_STOP_BIT: begin
                if ((txCounter + 1'd1) == DELAY_FRAMES) 
                    txCounter <= 25'b0;
                else 
                    txCounter <= txCounter + 1'd1;
            end
            
            default:
                txCounter <= txCounter;
        endcase      
    end
end

always @(posedge clk, negedge reset) begin
    if(reset == 1'b0)
        txPinRegister <= 1'b1;
    else begin
        case (txState)
            TX_STATE_IDLE: begin
                if (uart_enable == 1'b0)
                    txPinRegister <= 1'b1;
                else 
                    txPinRegister <= txPinRegister;
            end 

            TX_STATE_START_BIT:
                txPinRegister <= 1'b0;

            TX_STATE_WRITE: 
                txPinRegister <= data_valid[txBitNumber];

            TX_STATE_STOP_BIT:
                txPinRegister <= 1'b1;
            
            default: 
                txPinRegister <= txPinRegister; 

        endcase      
    end
end

always @(posedge clk, negedge reset) begin
    if(reset == 1'b0)
        txBitNumber <= 3'b0;
    else begin
        case (txState)

            TX_STATE_START_BIT: begin
                if ((txCounter + 1'd1) == DELAY_FRAMES)
                    txBitNumber <= 3'b0;
                else 
                    txBitNumber <= txBitNumber;
            end

            TX_STATE_WRITE: begin
                if ((txCounter + 1'b1) == DELAY_FRAMES) begin
                    if (txBitNumber != 3'b111)
                        txBitNumber <= txBitNumber + 1'd1;
                    else
                        txBitNumber <= txBitNumber;
                end else
                    txBitNumber <= txBitNumber; 
            end

            default: 
                txBitNumber <= txBitNumber;
        
        endcase      
    end
end

always @(posedge clk, negedge reset) begin
    if(reset == 1'b0)
        data_valid <= 8'b0;
    else begin
        if(txState == TX_STATE_IDLE) begin
            if (uart_enable == 1'b1) 
                data_valid <= data;
            else 
                data_valid <= data_valid;
        end      
    end
end

always @(posedge clk, negedge reset) begin
    if(reset == 1'b0) 
        uart_ready <= 1'b0;
    else begin
        if(txState == TX_STATE_IDLE) begin
            if (uart_enable == 1'b1)
                uart_ready <= 1'b0;
            else
                uart_ready <= 1'b1;
        end
    end
end


endmodule