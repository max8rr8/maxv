`default_nettype none

module led (
    input clk_i,
    input rstn_i,
    input write_i,
    input [5:0] val_i,

    output logic [5:0] led_o
);
    always_ff @(posedge clk_i) begin
        if(~rstn_i) begin
            led_o <= 0;
        end else begin
            if(write_i)
                led_o <= val_i;
        end;
    end
endmodule
