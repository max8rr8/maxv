`default_nettype none

module top #(parameter FREQ = 27000000) (
    input clk_i,
    input rstn_i,
    output reg [5:0] led_o,
    output uart_tx_o
);
  // logic led_write;
  // logic [5:0] led_val;

  logic bus_write;
  logic [31:0] bus_value;

  // led led(
  //   .clk_i(clk_i),
  //   .rstn_i(rstn_i),
  //   .led_o(led_o),
    
  //   .write_i(bus_write),
  //   .val_i(bus_value[5:0])
  // );

  cpu cpu(
    .clk_i(clk_i),
    .rstn_i(rstn_i),

    .write_o(bus_write),
    .value_o(bus_value)
  );

  uart #(.FREQ(FREQ)) uart (
     .clk_i(clk_i),
     .rstn_i(rstn_i),
     .uart_tx_o(uart_tx_o),
    
     .write_i(bus_write),
     .val_i(bus_value[7:0])
  );

endmodule
