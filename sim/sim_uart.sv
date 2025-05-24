`default_nettype none

module sim_uart #(parameter FREQ) (
  input clk_i,
  input rstn_i,
  input uart_tx_i
);
  localparam CLK_PER_BIT = FREQ / 115200;
  
  int countdown = 0;
  int left = 0;
  
  logic [7:0] char;

  always_ff @(posedge clk_i) begin
    if(!rstn_i) begin
    end else begin
      if(countdown == 0) begin
        if (left == 0) begin
          if (uart_tx_i == 1'b0) begin
            countdown = (CLK_PER_BIT * 3 / 2) - 1;
            left = 8;
          end
        end else begin
          char[8 - left] = uart_tx_i;
          countdown = CLK_PER_BIT - 1;
          left = left - 1;
          if(left == 0) begin
            $write("%c", char);
          end
        end
      end else begin
        countdown = countdown - 1;
      end
    end

  end

endmodule