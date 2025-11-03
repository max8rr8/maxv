`default_nettype none

import vde_init_mem::*;

module vde #(
) (
    input clk_i,
    input rstn_i,

    input logic pixel_ready_i,
    output logic pixel_valid_o,
    output logic [23:0] pixel_data_o,
    input logic frame_idx_i,

    input  logic        bus_enable_i,
    input  logic [ 3:0] bus_wstrb_i,
    input  logic [31:0] bus_addr_i,
    input  logic [31:0] bus_addr_prev_i,
    input  logic [31:0] bus_wvalue_i,
    output logic [31:0] bus_rvalue_o
);
  
  logic frame_idx_prev;

  wire  frame_start = frame_idx_i != frame_idx_prev;
  logic was_first_frame;

  logic [7:0] frame_count;

  initial begin
    was_first_frame = 0;
  end

  always_ff @(posedge clk_i) begin
    frame_idx_prev <= frame_idx_i;
  end

  always_ff @(posedge clk_i) begin
    if(~rstn_i) begin
      frame_count <= 0;
    end else if(frame_start) begin
      frame_count <= frame_count + 1;
    end
  end

  logic sprite_ready;
  logic sprite_valid;
  logic [8:0] sprite_data;
  logic [3:0] sprite_row;

  logic color_queue_ready;
  logic color_queue_valid;
  logic [7:0] color_queue_a;
  logic [7:0] color_queue_b;
  logic [7:0] color_queue_c;
  logic [7:0] color_queue_d;

  logic color_ready;
  logic color_valid;
  logic [7:0] color_data;

  logic [12:0] map_mem_addr;
  logic map_mem_fetch;
  logic [8:0] map_mem_data;
  logic map_mem_done;

  logic [7:0] pixel_mem_addr;
  logic [23:0] pixel_mem_data;

  logic [10:0] sprite_mem_addr;
  logic [31:0] sprite_mem_data;

  wire bus_is_sprite_mem = bus_addr_i[16];
  wire bus_was_sprite_mem = bus_addr_prev_i[16];
  logic [31:0] regmap_wvalue;
  logic regmap_upd_color;
  logic regmap_upd_map;
  logic [31:0] sprite_rvalue;

  vde_map_mem #(
      .INIT_MAP(MEM_MAP_INIT)
  ) vde_map_mem (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      
      .map_mem_addr_i(map_mem_addr),
      .map_mem_fetch_i(map_mem_fetch),
      .map_mem_data_o(map_mem_data),
      .map_mem_done_o(map_mem_done),

      .pixel_mem_data_o(pixel_mem_data),
      .pixel_mem_addr_i(pixel_mem_addr),

      .update_color_idx_i(regmap_wvalue[31:24]),
      .update_color_val_i(regmap_wvalue[23:0]),
      .update_color_upd_i(regmap_upd_color),

      .update_map_x_i(regmap_wvalue[21:15]),
      .update_map_y_i(regmap_wvalue[14:9]),
      .update_map_val_i(regmap_wvalue[8:0]),
      .update_map_upd_i(regmap_upd_map)
  );

  vde_sprite_mem #(
      .INIT_SPRITE(MEM_SPRITE_INIT)
  ) vde_sprite_mem (
    .clk_i (clk_i),
    .rstn_i(rstn_i),

    .sprite_mem_addr_i(sprite_mem_addr),
    .sprite_mem_data_o(sprite_mem_data),
    
    .bus_mem_enable_i(bus_enable_i & bus_is_sprite_mem), 
    .bus_mem_wstrb_i(bus_wstrb_i),
    .bus_mem_addr_i(bus_addr_i[12:2]),
    .bus_mem_wvalue_i(bus_wvalue_i),
    .bus_mem_rvalue_o(sprite_rvalue)
  );

  vde_map_emitter vde_map_emitter (
      .clk_i (clk_i),
      .rstn_i(rstn_i),

      .frame_start(frame_start),

      .sprite_ready_i(sprite_ready),
      .sprite_valid_o(sprite_valid),
      .sprite_data_o (sprite_data),
      .sprite_row_o  (sprite_row),

      .map_mem_addr_o (map_mem_addr),
      .map_mem_fetch_o(map_mem_fetch),
      .map_mem_data_i (map_mem_data),
      .map_mem_done_i (map_mem_done)
  );

  vde_sprite_emitter vde_sprite_emitter (
      .clk_i (clk_i),
      .rstn_i(rstn_i),

      .frame_start(frame_start),

      .sprite_ready_o(sprite_ready),
      .sprite_valid_i(sprite_valid),
      .sprite_data_i (sprite_data),
      .sprite_row_i  (sprite_row),

      .color_ready_i(color_queue_ready),
      .color_valid_o(color_queue_valid),
      .color_a_o (color_queue_a),
      .color_b_o (color_queue_b),
      .color_c_o (color_queue_c),
      .color_d_o (color_queue_d),

      .sprite_mem_addr_o(sprite_mem_addr),
      .sprite_mem_data_i(sprite_mem_data)
  );

  vde_2x1_fifo vde_color_queue (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
    
      .data_in_ready_o(color_queue_ready),
      .data_in_valid_i(color_queue_valid),
      .data_in_a_i(color_queue_a),
      .data_in_b_i(color_queue_b),
      .data_in_c_i(color_queue_c),
      .data_in_d_i(color_queue_d),
      
      .data_out_ready_i(color_ready),
      .data_out_valid_o(color_valid),
      .data_out_data_o(color_data)
  );

  vde_color_emitter vde_color_emitter (
      .clk_i (clk_i),
      .rstn_i(rstn_i),

      .frame_start(frame_start),

      .color_ready_i(color_ready),
      .color_valid_o(color_valid),
      .color_data_i (color_data),

      .pixel_ready_i(pixel_ready_i),
      .pixel_valid_o(pixel_valid_o),
      .pixel_data_o (pixel_data_o),

      .pixel_mem_data_i(pixel_mem_data),
      .pixel_mem_addr_o(pixel_mem_addr)
  );

  always_comb begin
    if(bus_was_sprite_mem) 
      bus_rvalue_o = sprite_rvalue;
    else
      bus_rvalue_o = {24'b0, frame_count};
  end

  wire is_regmap_wr = bus_enable_i && bus_wstrb_i == 4'b1111 && ~bus_is_sprite_mem;

  always_ff @(posedge clk_i) begin
    regmap_wvalue <= bus_wvalue_i;
    regmap_upd_color <= is_regmap_wr && bus_addr_i[14:0] == 15'h4;
    regmap_upd_map <= is_regmap_wr && bus_addr_i[14:0] == 15'h8;
  end
endmodule
