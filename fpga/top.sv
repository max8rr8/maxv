`default_nettype none

module top #(
    parameter FREQ = 27000000
) (
    input clk_i,
    input rstn_i,
    output reg [5:0] led_o,
    output uart_tx_o,
    input uart_rx_i,

    output wire tmds_clk_n,
    output wire tmds_clk_p,
    output wire [2:0] tmds_d_n,
    output wire [2:0] tmds_d_p
);
  logic [24:0] pixel_data;
  logic pixel_ready;
  logic pixel_valid;

  logic [31:0] display_data;
  logic display_valid;
  logic display_ready;
  logic display_clk;

  logic frame_toggle;
  logic display_clk_frame_toggle;

  soc #(
      .FREQ(25175000)
  ) soc (
      .clk_i(display_clk),
      .rstn_i(rstn_i),
      .led_o(led_o),
      .uart_tx_o(uart_tx_o),
      .uart_rx_i(uart_rx_i),

      .pixel_ready_i(pixel_ready),
      .pixel_valid_o(pixel_valid),
      .pixel_data_o (pixel_data),
      .frame_idx_i  (display_clk_frame_toggle)
  );

  async_fifo async_fifo
  (
    .in_clk_i(display_clk),
    .out_clk_i(display_clk),
    .rstn_i(rstn_i),

    .in_data_i({8'b0, pixel_data}),
    .in_valid_i(pixel_valid),
    .in_ready_o(pixel_ready),

    .out_data_o(display_data),
    .out_valid_o(display_valid),
    .out_ready_i(display_ready)
  );

  dvi_pattern dvi_pattern (
      .clk_i (clk_i),
      .rstn_i(rstn_i),

      .display_data_i (display_data),
      .display_valid_i(display_valid),
      .display_ready_o(display_ready),
      .display_clk_o  (display_clk),

      .frame_toggle_o(display_clk_frame_toggle),

      .tmds_clk_n_o(tmds_clk_n),
      .tmds_clk_p_o(tmds_clk_p),
      .tmds_d_n_o  (tmds_d_n),
      .tmds_d_p_o  (tmds_d_p),
  );

endmodule
