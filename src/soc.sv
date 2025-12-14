`default_nettype none

module soc #(
    parameter FREQ = 27000000
) (
    input  clk_i,
    output rstn_o,

    input btn_r_i,
    input btn_l_i,

    output reg [5:0] led_o,

    output uart_tx_o,
    input  uart_rx_i,

    input logic pixel_ready_i,
    output logic pixel_valid_o,
    output logic [23:0] pixel_data_o,
    input logic frame_idx_i
);
  logic [4:0] rstn_cnt;
  logic rstn;
  logic lsio_reset_req;
  assign rstn_o = rstn;

  initial begin
    rstn_cnt = 5'b11111;
    rstn = 1'b1;
  end

  always_ff @(posedge clk_i) begin
    if (rstn_cnt > 0) begin
      rstn_cnt <= rstn_cnt - 1;
      rstn <= 0;
    end else begin
      rstn <= 1;
      if (lsio_reset_req) begin
        rstn_cnt <= 5'b11111;
      end
    end
  end

  logic err_inv_ins;
  logic [3:0] err_code;
  logic err_trigger;
  logic bus_err;

  assign err_trigger = err_inv_ins | bus_err;
  always_comb begin
    if(err_inv_ins) begin
      err_code = 4'b010;
    end else if(bus_err) begin
      err_code = 4'b011;
    end else begin
      err_code = 4'b000;
    end
  end

  wire bus_enable;
  wire [3:0] bus_wstrb;
  wire [31:0] bus_wvalue;
  wire [31:0] bus_addr;
  logic [31:0] bus_prev_addr;

  wire [31:0] instr_rvalue;
  wire [31:0] bsmem_rvalue;
  wire [31:0] uart_rvalue;
  wire [31:0] vde_rvalue;
  logic [31:0] bus_rvalue;

  always_comb begin
    unique case (bus_prev_addr[31:29])
      3'b000:  bus_rvalue = instr_rvalue;
      3'b001:  bus_rvalue = bsmem_rvalue;
      3'b010:  bus_rvalue = uart_rvalue;
      3'b100:  bus_rvalue = vde_rvalue;
      default: bus_rvalue = 0;
    endcase
    
    unique case (bus_prev_addr[31:29])
      3'b000:  bus_err = 1'b0;
      3'b001:  bus_err = 1'b0;
      3'b010:  bus_err = 1'b0;
      3'b100:  bus_err = 1'b0;
      default: bus_err = 1'b1;
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (!rstn) begin
      bus_prev_addr <= 0;
    end else begin
      bus_prev_addr <= bus_addr;
    end
  end

  cpu cpu (
      .clk_i (clk_i),
      .rstn_i(rstn),

      .enable_o(bus_enable),
      .wstrb_o (bus_wstrb),
      .addr_o  (bus_addr),
      .wvalue_o(bus_wvalue),
      .rvalue_i(bus_rvalue),
      .err_inv_ins_o(err_inv_ins)
  );

  soc_code code (
      .clk_i(clk_i),
      .enable_i(bus_enable && bus_addr[31:29] == 3'b000),
      .wstrb_i(bus_wstrb),
      .addr_i(bus_addr),
      .addr_prev_i(bus_prev_addr),
      .wvalue_i(bus_wvalue),
      .rvalue_o(instr_rvalue)
  );

  bsmem bsmem (
      .clk_i(clk_i),
      .enable_i(bus_enable && bus_addr[31:29] == 3'b001),
      .wstrb_i(bus_wstrb),
      .addr_i(bus_addr),
      .addr_prev_i(bus_prev_addr),
      .wvalue_i(bus_wvalue),
      .rvalue_o(bsmem_rvalue)
  );

  logic uart_tx_loc;

  lsio #(
      .FREQ(FREQ)
  ) lsio (
      .clk_i (clk_i),
      .rstn_i(rstn),

      .uart_tx_o(uart_tx_loc),
      .uart_rx_i(uart_rx_i),
      .btn_r_i(btn_r_i),
      .btn_l_i(btn_l_i),
      .reset_req_o(lsio_reset_req),

      .err_code_i(err_code),
      .err_i(err_trigger),

      .enable_i(bus_enable && bus_addr[31:29] == 3'b010),
      .wstrb_i(bus_wstrb),
      .addr_i(bus_addr),
      .addr_prev_i(bus_prev_addr),
      .wvalue_i(bus_wvalue),
      .rvalue_o(uart_rvalue)
  );

  assign uart_tx_o = rstn ? uart_tx_loc : uart_rx_i;

  vde vde (
      .clk_i (clk_i),
      .rstn_i(rstn),

      .pixel_ready_i(pixel_ready_i),
      .pixel_valid_o(pixel_valid_o),
      .pixel_data_o (pixel_data_o),
      .frame_idx_i  (frame_idx_i),

      .bus_enable_i(bus_enable && bus_addr[31:29] == 3'b100),
      .bus_wstrb_i(bus_wstrb),
      .bus_addr_i(bus_addr),
      .bus_addr_prev_i(bus_prev_addr),
      .bus_wvalue_i(bus_wvalue),
      .bus_rvalue_o(vde_rvalue)
  );
endmodule
