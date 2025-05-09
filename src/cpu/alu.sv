`default_nettype none

module cpu_alu (
  input wire [31:0] src_a_i,
  input wire [31:0] src_b_i,
  
  input wire compare_unsigned_i,
  
  output wire compare_eq_o,
  output wire compare_lt_o
);

  assign compare_eq_o = src_a_i == src_b_i;
  assign compare_lt_o = src_a_i[31] == src_b_i[31] ?
      (src_a_i[30:0] < src_b_i[30:0]) : 
      (compare_unsigned_i ? src_b_i[31] : src_a_i[31]);  
endmodule