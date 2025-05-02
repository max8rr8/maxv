`default_nettype none

module uart #(parameter FREQ = 27000000) (
    input clk_i,
    input rstn_i,
    input write_i,
    input [7:0] val_i,

    output logic uart_tx_o
);
    localparam RESET_CNT = FREQ / 115200;

    logic [24:0] cnt;
    logic [10:0] out_shift;

    initial begin
      out_shift = {11{1'b1}};
    end

    always_ff @(posedge clk_i) begin
        if(~rstn_i) begin
            cnt <= 0;
            out_shift <= {11{1'b1}};
            uart_tx_o <= 1;
        end else begin            
            if(cnt == RESET_CNT - 1) begin
              out_shift <= {1'b1, out_shift[10:1]};
              cnt <= 0;
            end else begin
              cnt <= cnt + 1;
            end;

            if(write_i) begin
              out_shift <= {1'b1, val_i, 2'b01};
            end 
        end;
        uart_tx_o <= out_shift[0];
    end
endmodule
