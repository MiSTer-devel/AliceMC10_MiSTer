
module joysticks(
  input [15:0] joy1,
  input [15:0] joy2,
  input [15:0] addr,
  output [7:0] dout
);

// 1011_111?_?0?1_0???
// BE10-7, BE30-7, BE90-7, BEB0-7, BF10-7, <BF30-7>, BF90-7, BFB0-7

wire s1 = addr[15:9]  == 7'b1011111;
wire s2 = addr[6] == 0;
wire s3 = addr[4:3] == 2'b10;

wire sel = s1 & s2 & s3;
wire [15:0] joy = addr[2] ? ~joy2 : ~joy1;
wire [7:0] ejoy = { 3'd7, joy[4], joy[0], joy[1], joy[2], joy[3] };

assign dout = sel ? ejoy : 8'd0;

endmodule