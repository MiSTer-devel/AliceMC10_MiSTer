
module x74245(
  input [7:0] Ai,
  input [7:0] Bi,
  output [7:0] Ao,
  output [7:0] Bo,
  input dir,
  input G
);

assign Ao = ~G & ~dir ? Bi : 8'd0;
assign Bo = ~G & dir ? Ai : 8'd0;

endmodule
