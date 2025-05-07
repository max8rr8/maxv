`default_nettype none

module top #(parameter FREQ = 27000000) (
    input clk_i,
    input rstn_i,
    output reg [5:0] led_o,
    output uart_tx_o,
    input uart_rx_i
);
  // logic led_write;
  // logic [5:0] led_val;

  wire bus_enable;
  wire [3:0] bus_wstrb;
  wire [31:0] bus_wvalue;
  wire [31:0] bus_addr;
  logic [31:0] bus_prev_addr;

  wire [31:0] instr_rvalue;
  wire [31:0] bsmem_rvalue;
  wire [31:0] bus_rvalue = bus_prev_addr[31:29] == 3'b001 ? bsmem_rvalue : instr_rvalue;

  always_ff @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
      bus_prev_addr <= 0;
    end else begin
      bus_prev_addr <= bus_addr;
    end
  end

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

    .enable_o(bus_enable),
    .wstrb_o(bus_wstrb),
    .addr_o(bus_addr),
    .wvalue_o(bus_wvalue),
    .rvalue_i(bus_rvalue)
  );

  code code(
    .clk_i(clk_i),
    .addr_i(bus_addr),
    .instr_o(instr_rvalue)
  );

  bsmem bsmem(
    .clk_i(clk_i),
    .enable_i(bus_enable && bus_addr[31:29] == 3'b001),
    .wstrb_i(bus_wstrb),
    .addr_i(bus_addr),
    .addr_prev_i(bus_prev_addr),
    .wvalue_i(bus_wvalue),
    .rvalue_o(bsmem_rvalue)
  );

  logic uart_tx_loc;

  uart #(.FREQ(FREQ)) uart (
     .clk_i(clk_i),
     .rstn_i(rstn_i),
     .uart_tx_o(uart_tx_loc),
    
     .write_i(bus_enable && bus_addr == 32'h1234),
     .val_i(bus_wvalue[7:0])
  );
  assign uart_tx_o = rstn_i ? uart_tx_loc : uart_rx_i;
endmodule
