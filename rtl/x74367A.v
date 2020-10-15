
module x74367A(A, Y, G);
  input  [5:0] A;
  output [5:0] Y;
  input G;
  assign Y = G ? 6'b0 : A;
endmodule
