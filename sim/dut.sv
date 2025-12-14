`default_nettype none

import "DPI-C" function int display_send_pixel(int pixel);
import "DPI-C" function int display_get_frame_idx();
import "DPI-C" function int button_get();

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

module button_interface (
    input wire clk_i,

    output logic        btn_r_o,
    output logic        btn_l_o
);
  logic [1:0] btn;

  always_ff @(posedge clk_i) begin
    btn <= button_get()[1:0];
  end

  assign btn_r_o = ~btn[0];
  assign btn_l_o = ~btn[1];
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
  logic btn_l;
  logic btn_r;

  localparam FREQ = 115200 * 64;

  logic [5:0] leds;

  logic rstn_soc;

  soc #(
      .FREQ(FREQ)
  ) soc (
      .clk_i(clk_i),
      .rstn_o(rstn_soc),

      .led_o(leds),
      .btn_r_i(btn_r),
      .btn_l_i(btn_l),

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

  button_interface button_interface (
    .clk_i(clk_i),

    .btn_l_o(btn_l),
    .btn_r_o(btn_r)
  );
endmodule
