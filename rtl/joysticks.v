
module joysticks(
  input [15:0] joy1,
  input [15:0] joy2,
  input [15:0] addr,
  output [7:0] dout
);

wire sel = addr[15:4] == 12'hbf3;
wire [15:0] joy = addr[2] ? ~joy2 : ~joy1;
wire [7:0] ejoy = { 3'd7, joy[4], joy[0], joy[1], joy[2], joy[3] };

assign dout = sel ? ejoy : 8'd0;

endmodule