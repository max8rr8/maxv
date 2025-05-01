`default_nettype none

module uart #(parameter FREQ = 27000000) (
    input clk_i,
    input rstn_i,
    input write_i,
    input [7:0] val_i,

    output uart_tx_o
);
    localparam RESET_CNT = FREQ / 115200;

    logic [23:0] cnt;
    logic [9:0] out_shift;

    initial begin
      out_shift = {10{1'b1}};
    end

    always_ff @(posedge clk_i) begin
        if(~rstn_i) begin
            cnt <= RESET_CNT;
            out_shift <= {10{1'b1}};
        end else begin
            if(write_i) begin
              out_shift <= {1'b0, val_i, 1'b1};
              cnt <= RESET_CNT;
            end else if(cnt == 0) begin
              out_shift <= {out_shift[8:0], 1'b1};
              cnt <= RESET_CNT;
            end else begin
              cnt <= cnt - 1;
            end;
        end;
    end

    assign uart_tx_o = out_shift[9];
endmodule
