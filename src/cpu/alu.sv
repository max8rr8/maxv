`default_nettype none

module cpu_alu (
  input wire [31:0] src_a_i,
  input wire [31:0] src_b_i,
  input wire [31:0] src_imm,
  
  input wire use_imm_i,
  // RISC-V encoded op
  // ADD(000) SLTI(01x) XOR(100) OR(110) AND(111)
  input wire [2:0] op_i,
  input wire do_sub_i,
  output logic [31:0] res_o,

  
  input wire compare_unsigned_i,
  
  output wire compare_eq_o,
  output wire compare_lt_o
);
  wire [31:0] src_sec = use_imm_i ? src_imm : src_b_i;

  assign compare_eq_o = src_a_i == src_sec;
  assign compare_lt_o = src_a_i[31] == src_sec[31] ?
      (src_a_i[30:0] < src_sec[30:0]) : 
      (compare_unsigned_i ? src_sec[31] : src_a_i[31]);  

  always_comb begin
    case (op_i)
      3'b000: res_o = do_sub_i ? (src_a_i - src_sec) : (src_a_i + src_sec);
      3'b010: res_o = {31'b0, compare_lt_o};
      3'b011: res_o = {31'b0, compare_lt_o};
      3'b100: res_o = src_a_i ^ src_sec;
      3'b110: res_o = src_a_i | src_sec;
      3'b111: res_o = src_a_i & src_sec;
      default: res_o = 32'd0;
    endcase
  end
endmodule