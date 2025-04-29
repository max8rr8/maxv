`default_nettype none

module code (
    input [31:0] addr_i,
    output [31:0] instr_o
);
  // verilator lint_off ASCRANGE
  logic [0:3] [31:0] INSTR  = {
    32'h00001537,
    32'h23450513,
    32'h02a00293,
    32'h00550023
  };

  assign instr_o = addr_i < 16 ? INSTR[addr_i >> 2] : 32'h00000013;
endmodule
