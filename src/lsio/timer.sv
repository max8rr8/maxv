module lsio_timer #(
    parameter FREQ = 27000000
) (
    input clk_i,
    input rstn_i,

    output logic [31:0] time_o,
    output one_ms_event_o
);
  logic [16:0] ms_counter;
  
  initial begin
    ms_counter = 0;
  end

  assign one_ms_event_o = ms_counter == 17'((FREQ / 1000) - 1);

  always_ff @(posedge clk_i) begin
    if(~rstn_i) begin
      ms_counter <= 0;
      time_o <= 0;
    end else begin
      if(one_ms_event_o) begin
        ms_counter <= 0;
        time_o <= time_o + 1;
      end else begin
        ms_counter <= ms_counter + 1;
      end
    end
  end

endmodule