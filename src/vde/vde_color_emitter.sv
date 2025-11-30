module vde_color_emitter #(
  localparam MAP_WIDTH = 80,
  localparam MAP_HEIGHT = 60
)
(
    input clk_i,
    input rstn_i,

    input logic frame_start,
    
    output logic color_ready_i,
    input logic color_valid_o,
    input logic [7:0] color_data_i,

    input logic pixel_ready_i,
    output logic pixel_valid_o,
    output logic [23:0] pixel_data_o,

    output logic [7:0] pixel_mem_addr_o,
    input logic [23:0] pixel_mem_data_i
);
  logic mem_saved;
  logic ate_color;
  logic [7:0] saved_color;

  assign color_ready_i = pixel_ready_i;

  assign pixel_data_o = pixel_mem_data_i;
  assign pixel_mem_addr_o = pixel_ready_i ? color_data_i : saved_color;

  always_ff @(posedge clk_i) begin 
    if (~rstn_i) begin
      saved_color <= 0;
      pixel_valid_o <= 0;
    end else begin
      if(color_ready_i && color_valid_o)
        saved_color <= color_data_i;

      if (pixel_ready_i) begin
        pixel_valid_o <= color_valid_o;
      end
    end

  end

endmodule