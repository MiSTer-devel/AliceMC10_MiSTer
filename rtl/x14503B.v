
module x14503B(
  input [5:0] in,
  output [5:0] out,
  input A,
  input B
);

assign out = { B ? 2'b00 : in[5:4], A ? 4'b00 : in[3:0] };

endmodule
