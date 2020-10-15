
module x74155(
  input [1:0] C,
  input [1:0] G,
  input A,
  input B,
  output [3:0] Y1,
  output [3:0] Y2
);

assign Y1 = ~{
   B &  A & ~G[0] & C[0],
   B & ~A & ~G[0] & C[0],
  ~B &  A & ~G[0] & C[0],
  ~B & ~A & ~G[0] & C[0]
};

assign Y2 = ~{
   B &  A & ~G[1] & ~C[1],
   B & ~A & ~G[1] & ~C[1],
  ~B &  A & ~G[1] & ~C[1],
  ~B & ~A & ~G[1] & ~C[1]
};

endmodule
