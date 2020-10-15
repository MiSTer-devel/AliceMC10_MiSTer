
module keyboard(
  input clk,
  input [10:0] ps2_key,
  input [7:0] KR,
  input shift,
  output [5:0] rows
);

// e = enter, s = space
// c = ctrl, b = break, f = shift
//
// @ A B C D E F G | 0 \
// H I J K L M N O | 1 |
// P Q R S T U V W | 2 |
// X Y Z       e s | 3 |
// 0 1 2 3 4 5 6 7 | 4 |
// 8 9 * + < = > ? | 5 /
// c   b         f | shift
// ----------------
// 0 1 2 3 4 5 6 7

reg [10:0] prev;
reg [5:0] cols[8:0];

assign rows = ~(
  (KR[0] ? 0 : cols[0]) |
  (KR[1] ? 0 : cols[1]) |
  (KR[2] ? 0 : cols[2]) |
  (KR[3] ? 0 : cols[3]) |
  (KR[4] ? 0 : cols[4]) |
  (KR[5] ? 0 : cols[5])
);

always @(posedge clk)
  prev <= ps2_key;

wire [7:0] key = ps2_key[9] ? ps2_key[7:0] : prev[7:0];
always @(posedge clk)
  if (prev != ps2_key)  
    case (key)
      8'h1c: cols[1][0] <= ps2_key[9]; // a
      8'h15: cols[1][2] <= ps2_key[9]; // q
      8'h5a: cols[6][3] <= ps2_key[9]; // enter
    endcase

endmodule
