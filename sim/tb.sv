`default_nettype none

module tb ();
  logic clk;
  logic rstn;
  logic uart;

  localparam FREQ = 115200 * 4;

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
    #1000000ns;
    $finish();
  end

  logic [5:0] leds;

  top #(.FREQ(FREQ)) top (
    .clk_i(clk),
    .rstn_i(rstn),
    .led_o(leds),
    .uart_tx_o(uart)
  );

  sim_uart #(.FREQ(FREQ)) sim_uart (
    .clk_i(clk),
    .rstn_i(rstn),
    .uart_tx_i(uart)
  );

endmodule
