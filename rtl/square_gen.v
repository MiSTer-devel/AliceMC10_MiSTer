
module square_gen(
  input reset,
  input clk,
  input freq,
  output s
);

assign s = square;

// 50Mhz to 2400Hz
// 50/0.0048=10416, (2^24)/10416=1610
// 50/0.0024=20833, (2^24)/20833=805

parameter
  SLOW = 24'd805,
  FAST = 24'd1610;

/*
parameter
  SLOW = 24'd40200,
  FAST = 24'd161000;
*/

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