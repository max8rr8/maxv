
`default_nettype none

import "DPI-C" function longint code_get(longint addr);

module code (
    input clk_i,
    input [31:0] addr_i,
    output logic [31:0] instr_o
);
  always_ff @(posedge clk_i)
    instr_o <= code_get({32'b0, addr_i})[31:0];
endmodule
