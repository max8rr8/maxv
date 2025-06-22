`default_nettype none

import "DPI-C" function int access_memory(int address, int wvalue, int wstrb);

module dut (
    input clk_i,
    input rstn_i
);
  wire bus_enable;
  wire [3:0] bus_wstrb;
  wire [31:0] bus_wvalue;
  wire [31:0] bus_addr;
  logic [31:0] bus_rvalue;

  always_ff @(posedge clk_i or negedge rstn_i) begin
    if(bus_enable) begin
      bus_rvalue <= access_memory(bus_addr, bus_wvalue, {28'h0, bus_wstrb});
    end else begin
      bus_rvalue <= 32'h0;
    end
  end

  cpu cpu(
    .clk_i(clk_i),
    .rstn_i(rstn_i),

    .enable_o(bus_enable),
    .wstrb_o(bus_wstrb),
    .addr_o(bus_addr),
    .wvalue_o(bus_wvalue),
    .rvalue_i(bus_rvalue)
  );
endmodule
