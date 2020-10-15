
module ram (
  input clk,
  input [10:0] addr,
  input [7:0] din,
  output reg [7:0] dout,
  input we,
  input cs
);

reg [7:0] memory[1023:0];

always @(posedge clk) begin
  if (~cs & ~we) memory[addr] <= din;
  dout <= ~cs ? memory[addr] : 8'd0;
end

endmodule
