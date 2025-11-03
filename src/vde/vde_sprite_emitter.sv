`default_nettype none

module vde_sprite_emitter #(
    localparam MAP_WIDTH  = 80,
    localparam MAP_HEIGHT = 60
) (
    input clk_i,
    input rstn_i,

    input logic frame_start,

    output logic sprite_ready_o,
    input logic sprite_valid_i,
    input logic [8:0] sprite_data_i,
    input logic [3:0] sprite_row_i,

    input logic color_ready_i,
    output logic color_valid_o,
    output logic [7:0] color_a_o,
    output logic [7:0] color_b_o,
    output logic [7:0] color_c_o,
    output logic [7:0] color_d_o,

    output logic [10:0] sprite_mem_addr_o,
    input  logic [31:0] sprite_mem_data_i
);
  logic [4:0] cx;

  logic [3:0] sprite_row_ff;
  logic [8:0] sprite_data_ff;

  typedef enum logic [3:0] {
    RESET,
    WAIT_SPRITE,
    FETCH_INFO,
    EMIT_MONO_0,
    EMIT_MONO_1,
    EMIT_COLOR_0,
    EMIT_COLOR_1
  } fsm_state;

  fsm_state state;
  fsm_state next_state;

  logic [7:0] color_mono_zero;
  logic [7:0] color_mono_one;

  initial begin
    state = RESET;
  end

  always_ff @(posedge clk_i) begin
    if (~rstn_i) begin
      state <= RESET;
    end else begin
      state <= next_state;
    end
  end

  always_comb begin
    next_state = state;

    color_valid_o = 0;
    sprite_ready_o = 0;

    case (state)
      RESET: next_state = WAIT_SPRITE;

      WAIT_SPRITE: begin
        sprite_ready_o = 1;
        if (sprite_ready_o & sprite_valid_i) next_state = FETCH_INFO;
      end

      FETCH_INFO: begin
        next_state = sprite_mem_data_i[7:0] == 8'b10000000 ? EMIT_MONO_0 : EMIT_COLOR_0;
      end

      EMIT_MONO_0: begin
        color_valid_o = 1;

        if (color_ready_i & color_valid_o) next_state = EMIT_MONO_1;
      end

      EMIT_MONO_1: begin
        color_valid_o = 1;

        if (color_ready_i & color_valid_o) next_state = WAIT_SPRITE;
      end

      EMIT_COLOR_0: begin
        color_valid_o = 1;

        if (color_ready_i & color_valid_o) next_state = EMIT_COLOR_1;
      end

      EMIT_COLOR_1: begin
        color_valid_o = 1;

        if (color_ready_i & color_valid_o) next_state = WAIT_SPRITE;
      end

      default: next_state = RESET;
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (sprite_ready_o & sprite_valid_i) begin
      sprite_row_ff  <= sprite_row_i;
      sprite_data_ff <= sprite_data_i;
    end
  end

  always_ff @(posedge clk_i) begin
    if (state == FETCH_INFO) begin
      color_mono_zero <= sprite_mem_data_i[15:8];
      color_mono_one  <= sprite_mem_data_i[23:16];
    end
  end

  always_comb begin
    case (state)
      WAIT_SPRITE: sprite_mem_addr_o = {sprite_data_i, 2'b11};
      EMIT_COLOR_0,
      EMIT_COLOR_1: sprite_mem_addr_o = {sprite_data_ff, sprite_row_ff[2:1]};
      
      default: sprite_mem_addr_o = {sprite_data_ff, 1'b0, sprite_row_ff[2]};
    endcase
  end

  logic [3:0] mono_bits;
  
  assign mono_bits = {
    sprite_mem_data_i[{sprite_row_ff[1:0], state == EMIT_MONO_0, 2'b00}],
    sprite_mem_data_i[{sprite_row_ff[1:0], state == EMIT_MONO_0, 2'b01}],
    sprite_mem_data_i[{sprite_row_ff[1:0], state == EMIT_MONO_0, 2'b10}],
    sprite_mem_data_i[{sprite_row_ff[1:0], state == EMIT_MONO_0, 2'b11}]
  };

  always_comb begin
    case (state)
      EMIT_COLOR_0: begin
        color_a_o = sprite_mem_data_i[7:0];
        color_b_o = sprite_mem_data_i[7:0];
        color_c_o = sprite_mem_data_i[15:8];
        color_d_o = sprite_mem_data_i[15:8];
      end
      
      EMIT_COLOR_1: begin
        color_a_o = sprite_mem_data_i[23:16];
        color_b_o = sprite_mem_data_i[23:16];
        color_c_o = sprite_mem_data_i[31:24];
        color_d_o = sprite_mem_data_i[31:24];
      end
      
      /* EMIT_MONO_1, */
      default: begin
        color_a_o = mono_bits[0] ? color_mono_one : color_mono_zero;
        color_b_o = mono_bits[1] ? color_mono_one : color_mono_zero;
        color_c_o = mono_bits[2] ? color_mono_one : color_mono_zero;
        color_d_o = mono_bits[3] ? color_mono_one : color_mono_zero;
      end
    endcase
  end

endmodule
