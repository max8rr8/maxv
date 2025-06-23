`default_nettype none

module cpu_regfile (
    input clk_i,
    input rstn_i,
 
    input logic [4:0] raddr1_i,
    input logic [4:0] raddr2_i,
    input logic [4:0] waddr_i,
    input logic write_en_i,

    input logic [31:0] wdata_i,
    output logic [31:0] rdata1_o,
    output logic [31:0] rdata2_o
);
  logic [31:0] regs [0:31];

  assign rdata1_o = regs[raddr1_i];
  assign rdata2_o = regs[raddr2_i];

  always_ff @(posedge clk_i) begin
    if (~rstn_i) begin
      regs[0] <= 0;
    end else begin 
      if (write_en_i && (waddr_i != 0)) begin
        regs[waddr_i] <= wdata_i;
      end
    end
  end
endmodule
