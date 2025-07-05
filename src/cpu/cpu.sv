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
    EXECUTE
  } CPU_STATE;

  CPU_STATE cpu_state;
  logic start_exec;

  logic [31:0] reg_pc;
  logic [31:0] code_out;

  logic [31:0] cur_ins;

  wire mc_will_write;
  wire [2:0] mc_write_mux;
  wire mc_alu_use_imm;
  wire mc_alu_compare_unsigned;
  wire [1:0] mc_pc_mode;
  wire mc_is_store;
  wire mc_is_load;

  microcode_data microcode_data (
    .clk_i(clk_i),
    .rst_i(~rstn_i),
    .decode_en_i(cpu_state == FETCH),
    .mc_addr_i({rvalue_i[14:12], rvalue_i[6:2], 2'b00}),

    .mc_will_write_o(mc_will_write),
    .mc_write_mux_o(mc_write_mux),
    .mc_alu_use_imm_o(mc_alu_use_imm),
    .mc_alu_compare_unsigned_o(mc_alu_compare_unsigned),
    .mc_pc_mode_o(mc_pc_mode),
    .mc_is_load_o(mc_is_load),
    .mc_is_store_o(mc_is_store)
  );

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

  logic regfile_write_en;
  logic [31:0] regfile_wdata;

  cpu_regfile regfile(
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .raddr1_i(ins_rs1),
    .raddr2_i(ins_rs2),
    .waddr_i(ins_rd),
    .write_en_i(regfile_write_en),
    .wdata_i(regfile_wdata),
    .rdata1_o(cur_src_a),
    .rdata2_o(cur_src_b)
  );

  wire alu_compare_eq_o;
  wire alu_compare_lt_o;
  wire [31:0] alu_res_o;

  cpu_alu alu (
    .src_a_i(cur_src_a),
    .src_b_i(cur_src_b),
    .src_imm(ins_i_imm),

    .use_imm_i(mc_alu_use_imm),
    .op_i(cur_ins[14:12]),
    .do_sub_i(cur_ins[6:0] == 7'b0110011 & cur_ins[30]),
    .res_o(alu_res_o),

    .compare_unsigned_i(mc_alu_compare_unsigned),
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
    .use_imm_i(mc_alu_use_imm),
    
    .right_i(cur_ins[14]),
    .signed_i(cur_ins[30]),

    .start_i(start_exec),
    .done_o(shifter_done_o),
    .res_o(shifter_res_o)
  );

  wire should_branch = cur_ins[12] ^ (cur_ins[14] ? alu_compare_lt_o : alu_compare_eq_o);

  always_ff @(posedge clk_i) begin
    start_exec <= 0;

    if(~rstn_i) begin
      reg_pc <= 0;
      cpu_state <= ST_FE;
      cur_res <= 0;
    end else begin
      case (cpu_state)
        ST_FE: begin 
          cpu_state <= FETCH;
        end
        FETCH: begin 
          cur_ins <= rvalue_i;
          cpu_state <= EXECUTE;
          start_exec <= 1;
        end

        EXECUTE: begin
          cpu_state <= ST_FE;

          reg_pc <= reg_pc + 4;
          if(mc_pc_mode == 2'b10) begin
            reg_pc <= reg_pc + ins_j_imm;
          end else if(mc_pc_mode == 2'b11) begin
            reg_pc <= cur_src_a + ins_i_imm;
          end else if(mc_pc_mode == 2'b01 && should_branch) begin
            reg_pc <= reg_pc + ins_b_imm;
          end

          if(shifter_done_o == 1'b0 & mc_write_mux == 3'b011) begin
            cpu_state <= EXECUTE;
            reg_pc <= reg_pc;
          end

          if(start_exec & mc_is_load) begin
            cpu_state <= EXECUTE;
            reg_pc <= reg_pc;
          end;
        end
      endcase
    end
  end

  // Memory logic
  logic [31:0] memory_out;

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
        if(mc_is_load) begin
          addr_o = cur_src_a + ins_i_imm;
          enable_o = start_exec;
        end

        if(mc_is_store) begin
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

    case (cur_ins[14:12])
      3'b000: memory_out = {{24{rvalue_i[7]}}, rvalue_i[7:0]}; // lb
      3'b100: memory_out = {{24{1'b0}}, rvalue_i[7:0]}; // lbu

      3'b001: memory_out = {{16{rvalue_i[15]}}, rvalue_i[15:0]}; // lh
      3'b101: memory_out = {{16{1'b0}}, rvalue_i[15:0]}; // lhu

      default: memory_out = rvalue_i; // lw
    endcase
  end

  // Register writeback logic
  always_comb begin
    case(mc_write_mux)
      3'b000: regfile_wdata = { cur_ins[31:12], 12'd0 };
      3'b001: regfile_wdata = reg_pc + { cur_ins[31:12], 12'd0 };
      3'b010: regfile_wdata = alu_res_o;
      3'b011: regfile_wdata = shifter_res_o;
      3'b100: regfile_wdata = reg_pc + 4;
      3'b101: regfile_wdata = memory_out;

      default: regfile_wdata = 0;
    endcase

    regfile_write_en = cpu_state == EXECUTE && mc_will_write;
  end

  assign wvalue_o = cur_src_b;
endmodule
