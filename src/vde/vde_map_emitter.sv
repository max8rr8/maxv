module vde_map_emitter #(
  localparam MAP_WIDTH = 80,
  localparam MAP_HEIGHT = 60
)
(
    input clk_i,
    input rstn_i,

    input logic frame_start,
    
    input logic sprite_ready_i,
    output logic sprite_valid_o,
    output logic [8:0] sprite_data_o,
    output logic [3:0] sprite_row_o,

    output logic [12:0] map_mem_addr_o,
    output logic map_mem_fetch_o,
    input logic [8:0] map_mem_data_i, 
    input logic map_mem_done_i
);
  logic [6:0] map_x;
  logic [5:0] map_y;

  logic [3:0] cy;

  always_ff @(posedge clk_i) begin
    if (~rstn_i) begin
      map_x <= 0;
      map_y <= 0;
      cy <= 0;
      sprite_valid_o <= 0;
    end if (frame_start) begin
      map_x <= 0;
      map_y <= 0;
      cy <= 0;
      map_mem_fetch_o <= 1;
    end else begin 
      if (sprite_ready_i && sprite_valid_o) begin
        map_mem_fetch_o <= 1;
        sprite_valid_o <= 0;

        map_x <= map_x + 1;
        if(map_x == MAP_WIDTH - 1) begin
          map_x <= 0;
          cy <= cy + 1;
          if(cy == 7) begin
            cy <= 0;
            map_y <= map_y + 1;
            if(map_y == MAP_HEIGHT - 1) begin
              map_mem_fetch_o <= 0;
            end
          end
        end
      end

      if(map_mem_done_i & map_mem_fetch_o) begin
        sprite_valid_o <= 1;
        sprite_data_o <= map_mem_data_i;
        sprite_row_o <= cy;
        map_mem_fetch_o <= 0;
      end
    end
  end
  
  assign map_mem_addr_o = {map_x, map_y};
  // assign sprite_data_o = map_mem_data;
endmodule