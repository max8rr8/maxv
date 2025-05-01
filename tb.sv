`default_nettype none

module tb ();
  logic clk;
  logic rstn;

  initial begin
      $display("123");
    $dumpfile("./trace.vcd");
    clk = 0;
    
    forever begin
      #10ns
      clk = ~clk;
      $dumpvars(0);
    end
  end

  initial begin
    rstn = 0;
    #40ns;
    rstn = 1;
    #10000ns;
    $finish();
  end

  logic [5:0] leds;

  top #(.FREQ(10)) top (
    .clk_i(clk),
    .rstn_i(rstn),
    .led_o(leds)
  );

endmodule
