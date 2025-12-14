module lsio_err (
    input clk_i,
    input rstn_i,

    input one_ms_event_i,

    input [11:0] new_watchdog_val,
    input set_watchdog_i,

    input [3:0] err_hw_code_i,
    input err_hw_i,
    input [3:0] err_sw_code_i,
    input err_sw_i,


    output [4:0] err_read_o,
    input err_clear_i,

    output logic req_reset_o
);
  logic [ 4:0] err_saved;
  logic [11:0] watchdog_cnt;

  initial begin
    err_saved = 0;
    watchdog_cnt = 12'hfff;
  end

  always_ff @(posedge clk_i) begin
    if (~rstn_i) begin
      req_reset_o <= 0;
      watchdog_cnt <= 12'hfff;
    end else begin
      if (err_hw_i) begin
        err_saved   <= {1'b0, err_hw_code_i};
        req_reset_o <= 1;
      end else if (err_sw_i) begin
        err_saved   <= {1'b1, err_sw_code_i};
        req_reset_o <= 1;
      end else if (watchdog_cnt == 0) begin
        err_saved   <= 5'b1;
        req_reset_o <= 1;
      end

      if (set_watchdog_i) begin
        watchdog_cnt <= new_watchdog_val;
      end else if (one_ms_event_i) begin
        watchdog_cnt <= watchdog_cnt - 1;
      end
    end
  end

  assign err_read_o = err_saved;
endmodule
