
module square_gen(
  input reset,
  input clk,
  input freq,
  output s
);

assign s = square;

parameter
  SLOW = 24'd402,
  FAST = 24'd1610;

reg [23:0] div;
wire [23:0] stp = freq ? FAST : SLOW;

reg pulse;
reg square;

always @(posedge clk or posedge reset)
  if (reset) div <= 24'd0;
  else { pulse, div } <= div + stp;

always @(posedge pulse or posedge reset)
  if (reset) square <= 1'b1;
  else square <= ~square;

endmodule