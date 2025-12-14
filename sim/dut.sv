`default_nettype none

import "DPI-C" function int display_send_pixel(int pixel);
import "DPI-C" function int display_get_frame_idx();

module display_interface (
    input wire clk_i,

    input  logic        pixel_valid_i,
    output logic        pixel_ready_o,
    input  logic [23:0] pixel_data_i,

    output logic frame_idx_o
);
  always_ff @(posedge clk_i) begin
    pixel_ready_o <= display_send_pixel({{8{pixel_valid_i}}, pixel_data_i}) [0];
    frame_idx_o   <= display_get_frame_idx() [0];
  end
endmodule

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

  logic rstn_soc;

  soc #(
      .FREQ(FREQ)
  ) soc (
      .clk_i(clk_i),
      .rstn_o(rstn_soc),

      .led_o(leds),
      .btn_r_i(frame_idx),

      .uart_tx_o(uart),
      .uart_rx_i(uart_p),

      .pixel_ready_i(pixel_ready),
      .pixel_valid_o(pixel_valid),
      .pixel_data_o (pixel_data),
      .frame_idx_i  (frame_idx)
  );

  always_ff @(posedge clk_i) begin
    uart_p <= !rstn_soc ? 1 : uart;
  end

  sim_uart #(
      .FREQ(FREQ)
  ) sim_uart (
      .clk_i(clk_i),
      .rstn_i(rstn_soc),
      .uart_tx_i(uart)
  );
 
  display_interface display_interface (
      .clk_i(clk_i),

      .pixel_valid_i(pixel_valid),
      .pixel_ready_o(pixel_ready),
      .pixel_data_i (pixel_data),

      .frame_idx_o(frame_idx)
  );
endmodule
