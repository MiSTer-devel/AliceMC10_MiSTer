
module x7474(

  input clk1,
  input p1,
  input c1,
  input d1,
  output reg q1,
  output reg qn1,

  input clk2,
  input p2,
  input c2,
  input d2,
  output reg q2,
  output reg qn2

);

reg qt1, qnt1;
always @(posedge clk1)
  { qt1, qnt1 } <= { d1, ~d1 };

reg qt2, qnt2;
always @(posedge clk2)
  { qt2, qnt2 } <= { d2, ~d2 };

always @*
  case ({ p1, c1 })
    2'b00: { q1, qn1 } = 2'b11;
    2'b01: { q1, qn1 } = 2'b10;
    2'b10: { q1, qn1 } = 2'b01;
    2'b11: { q1, qn1 } = { qt1, qnt1 };
  endcase

always @*
  case ({ p2, c2 })
    2'b00: { q2, qn2 } = 2'b11;
    2'b01: { q2, qn2 } = 2'b10;
    2'b10: { q2, qn2 } = 2'b01;
    2'b11: { q2, qn2 } = { qt2, ~qnt2 };
  endcase


endmodule
