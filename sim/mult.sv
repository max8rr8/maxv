
module MULT36X36
#(
  parameter        AREG            = 0,
  parameter        ASIGN_REG       = 0,
  parameter        BREG            = 0,
  parameter        BSIGN_REG       = 0,
  parameter string MULT_RESET_MODE = "SYNC",
  parameter        OUT0_REG        = 0,
  parameter        OUT1_REG        = 0,
  parameter        PIPE_REG        = 0
)
(
  input [35:0]      A,
  input             ASIGN,
  input [35:0]      B,
  input             BSIGN,
  input             CE,
  input             CLK,
  output reg [71:0] DOUT,
  input             RESET
);

  always @(posedge CLK or negedge RESET) begin
    if (RESET) begin
      DOUT <= 0;
    end else if (CE) begin
      DOUT <= $signed({ASIGN, A}) * $signed({BSIGN, B});
    end
  end

endmodule