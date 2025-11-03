`default_nettype none

module top #(
    parameter FREQ = 27000000
) (
    input clk_i,
    input rstn_i,
    output reg [5:0] led_o,
    output uart_tx_o,
    input uart_rx_i
);
  soc #(
      .FREQ(25175000)
  ) soc (
      .clk_i(display_clk),
      .rstn_i(rstn_i),
      .led_o(led_o),
      .uart_tx_o(uart_tx_o),
      .uart_rx_i(uart_rx_i)
  );
endmodule
