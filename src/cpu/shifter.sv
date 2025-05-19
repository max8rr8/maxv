`default_nettype none

module cpu_shifter (
  input wire clk_i,
  input wire [31:0] src_a_i,
  input wire [31:0] src_b_i,
  input wire [31:0] src_imm,
  input wire use_imm_i,

  input wire right_i,
  input wire signed_i,

  input wire start_i,
  
  output wire done_o,
  output wire [31:0] res_o
);
  wire[4:0] src_sh = use_imm_i ? src_imm[4:0] : src_b_i[4:0];

  logic[4:0] reg_sh;
  logic[31:0] reg_res;

  always_ff @( posedge clk_i ) begin 
    if(start_i) begin
      reg_sh <= src_sh;
      reg_res <= src_a_i;
    end else if(reg_sh != 0) begin
      reg_sh <= reg_sh - 1;

      if(!right_i)
        reg_res <= reg_res << 1;
      else if (signed_i)
        reg_res <= {reg_res[31], reg_res[31:1]};
      else
        reg_res <= {1'b0, reg_res[31:1]};

    end
  end

  assign done_o = !start_i && reg_sh == 0;
  assign res_o = reg_res;
endmodule