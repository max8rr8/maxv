`default_nettype none

module cross_clk_synchroniser  #(
  parameter DATA_WIDTH = 1
)  (
  input wire in_clk_i,
  input wire[DATA_WIDTH - 1: 0] in_data_i,

  input wire out_clk_i,
  output wire[DATA_WIDTH - 1: 0] out_data_o
);

  reg [DATA_WIDTH - 1: 0] sync_reg1;
  reg [DATA_WIDTH - 1: 0] sync_reg2;

  always_ff @(posedge in_clk_i) begin
    sync_reg1 <= in_data_i;
  end

  always_ff @(posedge out_clk_i) begin
    sync_reg2 <= sync_reg1;
  end

  assign out_data_o = sync_reg2;
endmodule

  module async_fifo
  (
    input wire in_clk_i,
    input wire out_clk_i,
    input wire rstn_i,

    input wire [31:0] in_data_i,
    input wire in_valid_i,
    output wire in_ready_o,

    output wire [31:0] out_data_o,
    output wire out_valid_o,
    input wire out_ready_i
  );
    logic [6:0] read_ptr;
    logic [6:0] write_ptr;

    logic [6:0] next_read_ptr;
    logic [6:0] next_write_ptr;
  
    assign next_read_ptr = read_ptr + 1;
    assign next_write_ptr = write_ptr + 1;

    logic [6:0] gray_read_ptr;
    logic [6:0] gray_write_ptr;
    
    assign gray_read_ptr = read_ptr ^ (read_ptr >> 1);
    assign gray_write_ptr = write_ptr ^ (write_ptr >> 1);

    logic [6:0] cdc_read_ptr;
    logic [6:0] cdc_write_ptr;

    cross_clk_synchroniser #(.DATA_WIDTH(7)) in_to_out (
      .in_clk_i(in_clk_i),
      .in_data_i(gray_write_ptr),

      .out_clk_i(out_clk_i),
      .out_data_o(cdc_write_ptr)
    );

    cross_clk_synchroniser #(.DATA_WIDTH(7)) out_to_in (
      .in_clk_i(out_clk_i),
      .in_data_i(gray_read_ptr),

      .out_clk_i(in_clk_i),
      .out_data_o(cdc_read_ptr)
    );

    always_ff @(posedge out_clk_i) begin
      if(~rstn_i) begin
        read_ptr <= 0;
      end else begin
        if(out_valid_o && out_ready_i) begin
          read_ptr <= next_read_ptr;
        end
      end
    end

    // assign out_valid_o = gray_read_ptr != cdc_write_ptr;

    always_ff @(posedge in_clk_i) begin
      if(~rstn_i) begin
        write_ptr <= 0;
      end else begin
        if(in_valid_i && in_ready_o) begin
          write_ptr <= next_write_ptr;
        end
      end
    end

    logic [6:0] next_gray_write_ptr;
    assign next_gray_write_ptr = next_write_ptr ^ (next_write_ptr >> 1); 

    // assign in_ready_o = next_gray_write_ptr != cdc_read_ptr;
    assign in_ready_o          = next_write_ptr != read_ptr;
    assign out_valid_o         = read_ptr != write_ptr;

    logic [6:0] memory_read_addr;
    assign memory_read_addr = (out_valid_o && out_ready_i) ? next_read_ptr : read_ptr;

    SDPB #(
        .BIT_WIDTH_0(32),
        .BIT_WIDTH_1(32),
        .BLK_SEL_0  (3'b000),
        .BLK_SEL_1  (3'b000),
        .READ_MODE (1'b0),
        .RESET_MODE ("SYNC")
    ) dpx9b_inst (
      .ADA({2'b00, write_ptr, 5'b01111}),
      .ADB({2'b00, memory_read_addr, 5'b01111}),
      .BLKSELA(3'b000),
      .BLKSELB(3'b000),
      .CEA(1'b1),
      .CEB(1'b1),
      .CLKA(in_clk_i),
      .CLKB(out_clk_i),
      .DI(in_data_i),
      .DO(out_data_o),
      .OCE(1'b1),
      .RESETA(~rstn_i),
      .RESETB(~rstn_i)
    );
  endmodule