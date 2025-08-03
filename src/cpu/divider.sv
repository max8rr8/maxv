`default_nettype none

module cpu_divider (
    input wire clk_i,
    input wire [31:0] src_a_i,
    input wire [31:0] src_b_i,

    input wire div_mux,

    input wire start_i,

    output wire done_o,
    output wire [31:0] res_o
);
  logic [31:0] reg_remainder;
  logic [63:0] reg_divider;
  logic [31:0] reg_div_res;

  logic [5:0] reg_cnt;

  logic [32:0] sub_res;
  logic can_sub;

  always_comb begin
    sub_res = {1'b0, reg_remainder} - {1'b0, reg_divider[31:0]};
    can_sub = (~sub_res[32]) & ~(|reg_divider[63:32]);
  end

  always_ff @(posedge clk_i) begin
    if (start_i) begin
      reg_cnt <= 33;
      reg_remainder <= src_a_i;
      reg_divider <= {src_b_i, 32'b0};
    end else if (reg_cnt != 0) begin
      reg_cnt <= reg_cnt - 1;
      if (can_sub) begin
        reg_remainder <= sub_res[31:0];
      end
      reg_div_res <= {reg_div_res[30:0], can_sub};
      reg_divider <= {1'b0, reg_divider[63:1]};
    end
  end

  assign done_o = !start_i && reg_cnt == 0;
  assign res_o  = div_mux ? reg_div_res : reg_remainder;
endmodule
