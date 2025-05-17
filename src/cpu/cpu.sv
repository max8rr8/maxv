`default_nettype none

module cpu (
    input clk_i,
    input rstn_i,
 
    output logic enable_o,
    output logic [3:0] wstrb_o,
    output logic [31:0] addr_o,
    output logic [31:0] wvalue_o,
    input logic [31:0] rvalue_i
);
  typedef enum { 
    ST_FE,
    FETCH,
    DECODE,
    EXECUTE,
    WRITEBACK
  } CPU_STATE;

  CPU_STATE cpu_state;
  logic start_exec;

  logic [31:0] reg_pc;
  logic [31:0] code_out;

  logic [31:0] regs [1:31];

  logic [31:0] cur_ins;

  wire ins_is_lui = cur_ins[6:0] == 7'b0110111;
  wire ins_is_auipc = cur_ins[6:0] == 7'b0010111;
  wire ins_is_alui = cur_ins[6:0] == 7'b0010011;
  wire ins_is_alu = cur_ins[6:0] == 7'b0110011;
  wire ins_is_shifti = ins_is_alui & cur_ins[13:12] == 2'b01;
  wire ins_is_store = cur_ins[6:0] == 7'b0100011;
  wire ins_is_load = cur_ins[6:0] == 7'b0000011;
  wire ins_is_jal = cur_ins[6:0] == 7'b1101111;
  wire ins_is_jalr = cur_ins[6:0] == 7'b1100111;
  wire ins_is_srli = cur_ins[6:0] == 7'b0010011 & cur_ins[14:12] == 3'b101;
  wire ins_is_branch = cur_ins[6:0] == 7'b1100011;

  wire ins_will_write = ins_is_lui | ins_is_auipc | ins_is_alui | ins_is_alu | ins_is_jal | ins_is_jalr | ins_is_srli;

  wire [4:0] ins_rd = cur_ins[11:7];
  wire [4:0] ins_rs1 = cur_ins[19:15];
  wire [4:0] ins_rs2 = cur_ins[24:20];
  wire [31:0] ins_i_imm = {{20{cur_ins[31]}}, cur_ins[31:20]};
  wire [31:0] ins_j_imm = {{12{cur_ins[31]}}, cur_ins[19:12], cur_ins[20], cur_ins[30:21], 1'd0};
  wire [31:0] ins_b_imm = {{20{cur_ins[31]}}, cur_ins[7], cur_ins[30:25], cur_ins[11:8], 1'd0};
  wire [31:0] ins_s_imm = {{21{cur_ins[31]}}, cur_ins[30:25], cur_ins[11:7]};

  logic [31:0] cur_src_a;
  logic [31:0] cur_src_b;
  logic [31:0] cur_res;

  wire alu_compare_eq_o;
  wire alu_compare_lt_o;
  wire [31:0] alu_res_o;

  cpu_alu alu (
    .src_a_i(cur_src_a),
    .src_b_i(cur_src_b),
    .src_imm(ins_i_imm),

    .use_imm_i(ins_is_alui),
    .op_i(cur_ins[14:12]),
    .do_sub_i(ins_is_alu & cur_ins[30]),
    .res_o(alu_res_o),

    .compare_unsigned_i(ins_is_branch ? cur_ins[13] : cur_ins[12]),
    .compare_eq_o(alu_compare_eq_o),
    .compare_lt_o(alu_compare_lt_o)
  );

  wire [31:0] shifter_res_o;
  wire shifter_done_o;

  cpu_shifter shifter (
    .clk_i(clk_i),
    .src_a_i(cur_src_a),
    .src_b_i(cur_src_b),
    .src_imm(ins_i_imm),
    .use_imm_i(ins_is_shifti),
    
    .right_i(cur_ins[14]),
    .signed_i(cur_ins[30]),

    .start_i(start_exec & ins_is_shifti),
    .done_o(shifter_done_o),
    .res_o(shifter_res_o)
  );

  wire should_branch = cur_ins[12] ^ (cur_ins[14] ? alu_compare_lt_o : alu_compare_eq_o);

  always_ff @(posedge clk_i) begin
    start_exec <= 0;

    if(~rstn_i) begin
      reg_pc <= 0;
      cpu_state <= ST_FE;
      for(int i = 0; i < 31; i++) begin
        regs[i] <= 0;
      end
      cur_src_a <= 0;
      cur_src_b <= 0;
      cur_res <= 0;
    end else begin
      case (cpu_state)
        ST_FE: begin 
          cpu_state <= FETCH;
        end
        FETCH: begin 
          cur_ins <= rvalue_i;
          cpu_state <= DECODE;
        end

        DECODE: begin
          cur_src_a <= ins_rs1 == 0 ? 0 : regs[ins_rs1];
          cur_src_b <= ins_rs2 == 0 ? 0 : regs[ins_rs2];
          
          cpu_state <= EXECUTE;
          start_exec <= 1;
        end

        EXECUTE: begin
          cpu_state <= WRITEBACK;

          if(ins_is_lui) begin
            cur_res <= { cur_ins[31:12], 12'd0 };
          end else if(ins_is_auipc) begin
            cur_res <= reg_pc + { cur_ins[31:12], 12'd0 };
          end else if(ins_is_shifti) begin
            $display("Shifter %d!", shifter_done_o, cpu_state, ins_is_shifti);
            cur_res <= shifter_res_o;
            if(shifter_done_o == 1'b0) begin
              cpu_state <= EXECUTE;
            end
          end else if(ins_is_alui | ins_is_alu) begin
            cur_res <= alu_res_o;
          end else if(ins_is_jal | ins_is_jalr) begin
            cur_res <= reg_pc + 4;
          end
        end

        WRITEBACK: begin
          reg_pc <= reg_pc + 4;
          cpu_state <= ST_FE;

          if(ins_will_write && ins_rd != 0) begin
            regs[ins_rd] <= cur_res;
          end else if(ins_is_load) begin
            case (cur_ins[14:12])
              3'b000: regs[ins_rd] <= {{24{rvalue_i[7]}}, rvalue_i[7:0]}; // lb
              3'b100: regs[ins_rd] <= {{24{1'b0}}, rvalue_i[7:0]}; // lbu

              3'b001: regs[ins_rd] <= {{16{rvalue_i[15]}}, rvalue_i[15:0]}; // lh
              3'b101: regs[ins_rd] <= {{16{1'b0}}, rvalue_i[15:0]}; // lhu

              3'b010: regs[ins_rd] <= rvalue_i; // lw
              default: assert(0);
            endcase
          end

          if(ins_is_jal) begin
            reg_pc <= reg_pc + ins_j_imm;
          end else if(ins_is_jalr) begin
            reg_pc <= cur_src_a + ins_i_imm;
          end else if(ins_is_branch && should_branch) begin
            reg_pc <= reg_pc + ins_b_imm;
          end
        end
      endcase
    end
  end

  always_comb begin
    enable_o = 0;
    addr_o = 0;
    wstrb_o = 0;

    case (cpu_state)
      ST_FE: begin 
        enable_o = 1;
        addr_o = reg_pc;
      end
      
      EXECUTE: begin
        if(ins_is_load) begin
          addr_o = cur_src_a + ins_i_imm;
          enable_o = 1;
        end
      end

      WRITEBACK: begin
        if(ins_is_store) begin
          case(cur_ins[14:12])
            3'b000: wstrb_o = 4'b0001;
            3'b001: wstrb_o = 4'b0011;
            3'b010: wstrb_o = 4'b1111;
            default: assert (0);
          endcase
          addr_o = cur_src_a + ins_s_imm;
          enable_o = 1;
        end
      end
    endcase
  end

  assign wvalue_o = cur_src_b;
endmodule
