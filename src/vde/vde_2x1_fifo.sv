`default_nettype none

module vde_2x1_fifo #(
  localparam WIDTH = 8
) (
    input clk_i,
    input rstn_i,
  
    output logic data_in_ready_o,
    input logic data_in_valid_i,
    input logic [WIDTH - 1:0] data_in_a_i,
    input logic [WIDTH - 1:0] data_in_b_i,
    input logic [WIDTH - 1:0] data_in_c_i,
    input logic [WIDTH - 1:0] data_in_d_i,

    input logic data_out_ready_i,
    output logic data_out_valid_o,
    output logic [WIDTH - 1:0] data_out_data_o
);
  logic [WIDTH - 1:0] mem_a [0:15];
  logic [WIDTH - 1:0] mem_b [0:15];
  logic [WIDTH - 1:0] mem_c [0:15];
  logic [WIDTH - 1:0] mem_d [0:15];
 
  logic [3:0] wr_pos;
  logic [3:0] rd_pos;
  logic [1:0] rd_chan;

  wire[3:0] next_wr_pos;
  wire[3:0] next_rd_pos;

  assign next_wr_pos = wr_pos + 1;
  assign next_rd_pos = rd_pos + 1;

  always_ff @(posedge clk_i) begin
    if(~rstn_i) begin
      wr_pos <= 0;
      rd_pos <= 0;
      rd_chan <= 0;
    end else begin
      if (data_out_valid_o && data_out_ready_i) begin
        if(rd_chan == 3) begin
          rd_pos <= next_rd_pos;
          rd_chan <= 0;
        end else begin
          rd_chan <= rd_chan + 1;
        end
      end

      if(data_in_ready_o && data_in_valid_i) begin
        mem_a[wr_pos] <= data_in_a_i;
        mem_b[wr_pos] <= data_in_b_i;
        mem_c[wr_pos] <= data_in_c_i;
        mem_d[wr_pos] <= data_in_d_i;
        wr_pos <= next_wr_pos;
      end
    end
  end

  assign data_in_ready_o = next_wr_pos != rd_pos;

  assign data_out_valid_o = wr_pos != rd_pos;
  
  always_comb begin
    case (rd_chan)
      2'b00: data_out_data_o = mem_a[rd_pos];
      2'b01: data_out_data_o = mem_b[rd_pos];
      2'b10: data_out_data_o = mem_c[rd_pos];
      2'b11: data_out_data_o = mem_d[rd_pos];
    endcase
  end
endmodule