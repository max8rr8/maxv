`default_nettype none

module cpu_mult (
    input clk_i,
    input rstn_i,

    input wire [31:0] cur_src_a,
    input wire [31:0] cur_src_b,
    input wire [4:0] src_imm,

    input wire [1:0] mc_mul_extend,
    input wire mc_mul_shifter,
    input wire mc_alu_use_imm,
    input wire mult_high,
    input wire shift_arithmetic,

    output logic [71:0] mult_res_o
);

  wire mult_a_extend = cur_src_a[31] & (mc_mul_extend[0] | (mc_mul_shifter & shift_arithmetic));
  wire mult_b_extend = cur_src_b[31] & mc_mul_extend[1];

  wire [4:0] shift_amount_source = mc_alu_use_imm ? src_imm : cur_src_b[4:0];
  wire [4:0] shift_amount = mult_high ? -shift_amount_source : shift_amount_source;

  // Optimal (for LUT4) one-hot-encoding & mux with mult
  wire [15:0] shift_groups;
  generate
    for (genvar i = 0; i < 16; i = i + 1) begin
      assign shift_groups[i] = shift_amount[4:1] == i;
    end
  endgenerate

  wire [32:0] mult_shift_val;
  assign mult_shift_val[0] = mc_mul_shifter ? (mult_high ? 0 : shift_amount == 5'd0) : cur_src_b[0];
  generate
    for (genvar i = 1; i < 32; i = i + 1) begin
      assign mult_shift_val[i] = mc_mul_shifter ? (shift_groups[i >> 1] & shift_amount[0] == i[0]) : cur_src_b[i] ;
    end
  endgenerate
  assign mult_shift_val[32] = mc_mul_shifter ? (mult_high ? shift_amount == 5'd0 : 0) : mult_b_extend;

  MULT36X36 #(
      .AREG(1'b0),
      .BREG(1'b0),
      .OUT0_REG(1'b0),
      .OUT1_REG(1'b0),
      .PIPE_REG(1'b1),
      .ASIGN_REG(1'b0),
      .BSIGN_REG(1'b0),
      .MULT_RESET_MODE("SYNC")
  ) mul_0 (
      .A({{4{mult_a_extend}}, cur_src_a}),
      .B({{3{mult_b_extend}}, mult_shift_val}),
      .ASIGN(mult_a_extend),
      .BSIGN(mult_b_extend),
      .CE(1'b1),
      .CLK(clk_i),
      .RESET(~rstn_i),
      .DOUT(mult_res_o)
  );


endmodule
