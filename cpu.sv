`default_nettype none

module cpu (
    input clk_i,
    input rstn_i,
 
    output logic write_o,
    output logic [31:0] value_o
);
  typedef enum { 
    FETCH,
    DECODE,
    EXECUTE,
    WRITEBACK
  } CPU_STATE;

  CPU_STATE cpu_state;

  logic [31:0] reg_pc;
  logic [31:0] code_out;

  logic [31:0] regs [1:31];

  logic [31:0] cur_ins;

  wire ins_is_lui = cur_ins[5:0] == 6'b0110111;
  wire ins_is_addi = cur_ins[5:0] == 6'b0010011 & cur_ins[14:12] == 3'b000;
  wire ins_is_sb = cur_ins[5:0] == 6'b0100011 & cur_ins[14:12] == 3'b000;

  wire ins_will_write = ins_is_lui | ins_is_addi;

  wire [4:0] ins_rd = cur_ins[11:7];
  wire [4:0] ins_rs1 = cur_ins[19:15];
  wire [4:0] ins_rs2 = cur_ins[24:20];

  logic [31:0] cur_src_a;
  logic [31:0] cur_src_b;
  logic [31:0] cur_res;


  code code(
    .addr_i(reg_pc),
    .instr_o(code_out)
  );

  always_ff @(posedge clk_i) begin
    write_o <= 0;

    if(~rstn_i) begin
      reg_pc <= 0;
      cpu_state <= FETCH;
      for(int i = 0; i < 31; i++) begin
        regs[i] <= 0;
      end
      cur_src_a <= 0;
      cur_src_b <= 0;
      cur_res <= 0;
    end else begin
      case (cpu_state)
        FETCH: begin 
          cur_ins <= code_out;
          cpu_state <= DECODE;
        end

        DECODE: begin
          cpu_state <= EXECUTE;
          if(ins_is_addi | ins_is_sb) begin
            cur_src_a <= ins_rs1 == 0 ? 0 : regs[ins_rs1];
          end

          if(ins_is_sb) begin
            cur_src_b <= ins_rs2 == 0 ? 0 : regs[ins_rs2];
          end
        end

        EXECUTE: begin
          cpu_state <= WRITEBACK;
          if(ins_is_lui) begin
            cur_res <= { cur_ins[31:12], 12'd0 };
          end
          if(ins_is_addi) begin
            cur_res <= cur_src_a + {{20{cur_ins[31]}}, cur_ins[31:20]};
          end
          if(ins_is_sb) begin
            cur_res <= { 24'd0, cur_src_b[7:0] };
          end
        end

        WRITEBACK: begin
          reg_pc <= reg_pc + 4;
          cpu_state <= FETCH;

          if(ins_will_write) begin
            regs[ins_rd] <= cur_res;
          end

          if(ins_is_sb) begin
            value_o <= cur_res;
            write_o <= 1;
          end
        end
      endcase
    end
  end
endmodule
