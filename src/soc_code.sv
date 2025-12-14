module soc_code(
    input clk_i,

    input logic enable_i,
    input logic [3:0] wstrb_i,
    input logic [31:0] addr_i,
    input logic [31:0] addr_prev_i,
    input logic [31:0] wvalue_i,

    output logic [31:0] rvalue_o
);
  logic [31:0] instr_loc;
  code code (
      .clk_i  (clk_i),
      .addr_i (addr_i),
      .instr_o(instr_loc)
  );

  always_comb begin
    case(addr_prev_i[1:0])
      2'b00: rvalue_o = instr_loc;
      2'b01: rvalue_o = {instr_loc[7:0], instr_loc[31:8]};
      2'b10: rvalue_o = {instr_loc[15:0], instr_loc[31:16]};
      2'b11: rvalue_o = {instr_loc[23:0], instr_loc[31:24]};
    endcase
  end
endmodule