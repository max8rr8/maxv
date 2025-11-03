`default_nettype none

module dut (
    input clk_i,
    input rstn_i
);
  logic uart;
  logic uart_p;

  logic pixel_ready;
  logic pixel_valid;
  logic [23:0] pixel_data;
  logic frame_idx;


  localparam FREQ = 115200 * 4;

  logic [5:0] leds;

  soc #(
      .FREQ(FREQ)
  ) sco (
      .clk_i(clk_i),
      .rstn_i(rstn_i),

      .led_o(leds),

      .uart_tx_o(uart),
      .uart_rx_i(uart_p),

      .pixel_ready_i(pixel_ready),
      .pixel_valid_o(pixel_valid),
      .pixel_data_o (pixel_data),
      .frame_idx_i  (frame_idx)
  );

  always_ff @(posedge clk_i) begin
    uart_p <= !rstn_i ? 1 : uart;
  end

  sim_uart #(
      .FREQ(FREQ)
  ) sim_uart (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .uart_tx_i(uart)
  );
endmodule
