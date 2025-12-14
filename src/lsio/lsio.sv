`default_nettype none

`define LSIO_REG_UART_TX 6'h0
`define LSIO_REG_UART_RX 6'h4
`define LSIO_REG_TIMER_MS 6'h8
`define LSIO_REG_BTN 6'hc
`define LSIO_REG_WATCHDOG 6'h10
`define LSIO_REG_ERR 6'h14

module lsio #(
    parameter FREQ = 27000000
) (
    input clk_i,
    input rstn_i,

    output logic uart_tx_o,
    input uart_rx_i,

    input btn_r_i,
    input btn_l_i,

    output reset_req_o,

    input [3:0] err_code_i,
    input err_i,

    input  logic        enable_i,
    input  logic [ 3:0] wstrb_i,
    input  logic [31:0] addr_i,
    input  logic [31:0] addr_prev_i,
    input  logic [31:0] wvalue_i,
    output logic [31:0] rvalue_o
);
  logic reg_read;
  always_ff @(posedge clk_i) begin
    reg_read <= (wstrb_i == 4'h0) && enable_i;
  end
  wire reg_write = (wstrb_i == 4'hf) && enable_i;

  logic [5:0] reg_addr = addr_i[5:0];
  logic [5:0] prev_reg_addr = addr_prev_i[5:0];

  logic [10:0] uart_transmit_status;
  logic [7:0] uart_recieve;
  logic uart_recieve_valid;

  uart #(
      .FREQ(FREQ)
  ) uart (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .uart_tx_o(uart_tx_o),
      .uart_rx_i(uart_rx_i),

      .transmit_status_o(uart_transmit_status),
      .transmit_data_i  (wvalue_i[7:0]),
      .transmit_send_i  (reg_write && reg_addr == `LSIO_REG_UART_TX),

      .recieve_data_o (uart_recieve),
      .recieve_valid_o(uart_recieve_valid),
      .recieve_read_i (reg_read && prev_reg_addr == `LSIO_REG_UART_RX)
  );

  logic [31:0] timer_out;
  logic one_ms_event;
  lsio_timer #(
      .FREQ(FREQ)
  ) timer (
      .clk_i (clk_i),
      .rstn_i(rstn_i),

      .time_o(timer_out),
      .one_ms_event_o(one_ms_event)
  );

  logic btn_r_was_pressed;
  logic [4:0] btn_r_longest_press;
  logic btn_r_reset_req;

  lsio_btn btn_r (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .one_ms_event_i(one_ms_event),
      .btn_i(~btn_r_i),

      .was_pressed_o(btn_r_was_pressed),
      .longest_press_o(btn_r_longest_press),
      .clear_i(reg_read && prev_reg_addr == `LSIO_REG_BTN),
      .reset_req_o(btn_r_reset_req)
  );


  logic btn_l_was_pressed;
  logic [4:0] btn_l_longest_press;
  logic btn_l_reset_req;

  lsio_btn btn_l (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .one_ms_event_i(one_ms_event),
      .btn_i(~btn_l_i),

      .was_pressed_o(btn_l_was_pressed),
      .longest_press_o(btn_l_longest_press),
      .clear_i(reg_read && prev_reg_addr == `LSIO_REG_BTN),
      .reset_req_o(btn_l_reset_req)
  );

  logic [4:0] err_read;
  logic err_reset_req;

  lsio_err err (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .one_ms_event_i(one_ms_event),

    .new_watchdog_val(wvalue_i[11:0]),
    .set_watchdog_i(reg_write && reg_addr == `LSIO_REG_WATCHDOG),
    
    .err_hw_code_i(err_code_i),
    .err_hw_i(err_i),
    .err_sw_code_i(wvalue_i[3:0]),
    .err_sw_i(reg_write && reg_addr == `LSIO_REG_ERR),
    
    
    .err_read_o(err_read),
    .err_clear_i(reg_read && prev_reg_addr == `LSIO_REG_ERR),

    .req_reset_o(err_reset_req)
  );

  always_comb begin
    case (prev_reg_addr)
      `LSIO_REG_UART_TX: rvalue_o = {{21{uart_transmit_status[10]}}, uart_transmit_status};

      `LSIO_REG_UART_RX: rvalue_o = {{24{uart_recieve_valid}}, uart_recieve};

      `LSIO_REG_TIMER_MS: rvalue_o = timer_out;

      `LSIO_REG_BTN:
      rvalue_o = {
        18'b0, btn_l_was_pressed, btn_l_longest_press, 2'b0, btn_r_was_pressed, btn_r_longest_press
      };

      `LSIO_REG_ERR:
      rvalue_o = {27'b0, err_read};

      default: rvalue_o = 32'hdeadbeef;
    endcase
  end

  assign reset_req_o = btn_r_reset_req | btn_l_reset_req | err_reset_req;

endmodule
