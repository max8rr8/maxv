module bsmem(
    input clk_i,

    input logic enable_i,
    input logic [3:0] wstrb_i,
    input logic [31:0] addr_i,
    input logic [31:0] addr_prev_i,
    input logic [31:0] wvalue_i,

    output logic [31:0] rvalue_o
);
  logic [7:0] mem0 [0:2047];
  logic [7:0] mem1 [0:2047];
  logic [7:0] mem2 [0:2047];
  logic [7:0] mem3 [0:2047];

  wire [10:0] addr = addr_i[12:2];
  wire [10:0] addr_next = addr + 1;
  
  wire [10:0] addr0 = addr_i[1:0] >= 2'b01 ? addr_next : addr;
  wire [10:0] addr1 = addr_i[1:0] >= 2'b10 ? addr_next : addr;
  wire [10:0] addr2 = addr_i[1:0] >= 2'b11 ? addr_next : addr;
  wire [10:0] addr3 = addr;

  logic [31:0] rvalue_loc;
  logic [31:0] wvalue_loc;
  logic [3:0] wstrb_loc;

  always_comb begin
    case(addr_i[1:0])
      2'b00: wvalue_loc = wvalue_i;
      2'b01: wvalue_loc = {wvalue_i[23:0], wvalue_i[31:24]};
      2'b10: wvalue_loc = {wvalue_i[15:0], wvalue_i[31:16]};
      2'b11: wvalue_loc = {wvalue_i[7:0], wvalue_i[31:8]};
    endcase
  end


  always_comb begin
    case(addr_i[1:0])
      2'b00: wstrb_loc = wstrb_i;
      2'b01: wstrb_loc = {wstrb_i[2], wstrb_i[1], wstrb_i[0], wstrb_i[3]};
      2'b10: wstrb_loc = {wstrb_i[1], wstrb_i[0], wstrb_i[3], wstrb_i[2]};
      2'b11: wstrb_loc = {wstrb_i[0], wstrb_i[3], wstrb_i[2], wstrb_i[1]};
    endcase
  end

  always @(posedge clk_i) begin
    if (enable_i & wstrb_loc[0])
      mem0[addr0] <= wvalue_loc[7:0];
    else
      rvalue_loc[7:0] <= mem0[addr0];

    if (enable_i & wstrb_loc[1])
      mem1[addr1] <= wvalue_loc[15:8];
    else
      rvalue_loc[15:8] <= mem1[addr1];

    if (enable_i & wstrb_loc[2])
      mem2[addr2] <= wvalue_loc[23:16];
    else
      rvalue_loc[23:16] <= mem2[addr2];

    if (enable_i & wstrb_loc[3])
      mem3[addr3] <= wvalue_loc[31:24];
    else
      rvalue_loc[31:24] <= mem3[addr3];
  end

  always_comb begin
    case(addr_prev_i[1:0])
      2'b00: rvalue_o = rvalue_loc;
      2'b01: rvalue_o = {rvalue_loc[7:0], rvalue_loc[31:8]};
      2'b10: rvalue_o = {rvalue_loc[15:0], rvalue_loc[31:16]};
      2'b11: rvalue_o = {rvalue_loc[23:0], rvalue_loc[31:24]};
    endcase
  end
endmodule