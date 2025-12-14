module lsio_btn (
    input clk_i,
    input rstn_i,

    input one_ms_event_i,
    input btn_i,

    output logic was_pressed_o,
    output logic [4:0] longest_press_o,
    input logic clear_i,
    output logic reset_req_o
);
  logic was_pressed;
  logic [4:0] longest_press;
  logic [11:0] current_press;
  logic [11:0] current_press;

  initial begin
    longest_press_o = 0;
    current_press = 0;
    reset_req_o = 0;
  end

  always_ff @(posedge clk_i) begin
    if (~rstn_i) begin
      longest_press_o <= 0;
      was_pressed_o <= 0;
      was_pressed <= 0;
      longest_press <= 0;
      current_press <= 0;
      reset_req_o <= 0;
    end else begin
      if (clear_i) begin
        was_pressed_o   <= 0;
        longest_press_o <= 0;
        longest_press   <= 0;
      end

      if (btn_i) begin
        was_pressed <= 1;
        if (one_ms_event_i) begin
          if (~current_press[11]) current_press <= current_press + 1;

          if (longest_press < current_press[10:6]) longest_press <= current_press[10:6];
        end
      end else begin
        if (was_pressed) begin
          was_pressed_o <= was_pressed;
          longest_press_o <= longest_press;
          was_pressed <= 0;

          if (current_press[11]) reset_req_o <= 1;
        end

        current_press <= 0;
      end
    end
  end

endmodule
