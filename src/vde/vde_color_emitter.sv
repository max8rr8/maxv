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

  assign color_ready_i = pixel_ready_i;
  assign pixel_valid_o = color_valid_o;


  // logic [23:0] cp;
  assign pixel_data_o = pixel_mem_data_i;
  assign pixel_mem_addr_o = color_data_i;
  always_comb begin
    // case (color_data_i[4:0])
    //   5'b00000: pixel_data_o = 24'h000000;
    //   5'b00001: pixel_data_o = 24'hFF0000;
    //   5'b00010: pixel_data_o = 24'h00FF00;
    //   5'b00011: pixel_data_o = 24'h0000FF;
    //   5'b00100: pixel_data_o = 24'hFFFFFF;
    //   5'b00101: pixel_data_o = 24'h00FFFF;
    //   5'b00110: pixel_data_o = 24'hFF00FF;
    //   5'b00111: pixel_data_o = 24'hFFFF00;

    //   5'b01000: pixel_data_o = 24'h000000;
    //   5'b01001: pixel_data_o = 24'hAA0000;
    //   5'b01010: pixel_data_o = 24'h00AA00;
    //   5'b01011: pixel_data_o = 24'h0000AA;
    //   5'b01100: pixel_data_o = 24'hAAAAAA;
    //   5'b01101: pixel_data_o = 24'h00AAAA;
    //   5'b01110: pixel_data_o = 24'hAA00AA;
    //   5'b01111: pixel_data_o = 24'hAAAA00;

    //   5'b10000: pixel_data_o = 24'h000000;
    //   5'b10001: pixel_data_o = 24'h880000;
    //   5'b10010: pixel_data_o = 24'h008800;
    //   5'b10011: pixel_data_o = 24'h000088;
    //   5'b10100: pixel_data_o = 24'h888888;
    //   5'b10101: pixel_data_o = 24'h008888;
    //   5'b10110: pixel_data_o = 24'h880088;
    //   5'b10111: pixel_data_o = 24'h888800;

    //   5'b11000: pixel_data_o = 24'h000000;
    //   5'b11001: pixel_data_o = 24'h440000;
    //   5'b11010: pixel_data_o = 24'h004400;
    //   5'b11011: pixel_data_o = 24'h000044;
    //   5'b11100: pixel_data_o = 24'h444444;
    //   5'b11101: pixel_data_o = 24'h004444;
    //   5'b11110: pixel_data_o = 24'h440044;
    //   5'b11111: pixel_data_o = 24'h444400;
    // endcase
    // pixel_data_o = {color_data_i, color_data_i, color_data_i};
  end
endmodule