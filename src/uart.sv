`default_nettype none

module uart #(parameter FREQ = 27000000) (
    input clk_i,
    input rstn_i,

    output logic uart_tx_o,
    input uart_rx_i,
    
    input logic       enable_i,
    input logic [3:0] wstrb_i,
    input logic [31:0] addr_i,
    input logic [31:0] addr_prev_i,
    input logic [31:0] wvalue_i,
    output logic [31:0] rvalue_o
);
    localparam CLK_PER_BIT = FREQ / 115200;

    logic [9:0] cnt_tx;
    logic [9:0] cnt_rx;

    logic [10:0] out_shift;
    logic [8:0] rx_in;
    logic [3:0] rx_stat;
    logic rx_ff;

    initial begin
      out_shift = {11{1'b1}};
    end

    always_ff @(posedge clk_i) begin
        if(~rstn_i) begin
            cnt_tx <= 0;
            out_shift <= {11{1'b1}};
            uart_tx_o <= 1;
            rx_in[8] <= 0;
        end else begin
            if(cnt_tx == 10'(CLK_PER_BIT) - 1) begin
              out_shift <= {1'b1, out_shift[10:1]};
              cnt_tx <= 0;
            end else begin
              cnt_tx <= cnt_tx + 1;
            end;

            if(enable_i & wstrb_i[0] & addr_i[3:2] == 2'b0) begin
              out_shift <= {1'b1, wvalue_i[7:0], 2'b01};
            end

            if(cnt_rx == '0) begin
              if (rx_stat == 0) begin
                if(rx_ff == '0) begin
                  cnt_rx <= 10'((CLK_PER_BIT * 3 / 2) - 1);
                  rx_stat <= 9;
                  rx_in[8] <= 0;
                end
              end else begin 
                rx_in[9 - rx_stat] <= rx_ff;
                cnt_rx <= 10'(CLK_PER_BIT - 1);
                rx_stat <= rx_stat - 1;
              end
            end else begin
              cnt_rx <= cnt_rx - 1;
            end
        end;

        uart_tx_o <= out_shift[0];
        if(addr_i[2] == '0) begin
          rvalue_o <= {{21{out_shift[10]}}, out_shift[10:0]};
        end else begin
          rvalue_o <= {{23{rx_in[8]}}, rx_in[8:0]};
          if(enable_i && rx_in[8]) 
            rx_in[8] <= 0;
        end
        rx_ff <= uart_rx_i;
    end
endmodule
