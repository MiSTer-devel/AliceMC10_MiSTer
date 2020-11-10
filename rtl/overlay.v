
module overlay(
  input clk_vid,
  input [7:0] din,
  input sample,
  input [3:0] status,
  input hsync,
  input vsync,
  output [7:0] color,
  input en
);

assign color = en & status[2:0] != 0 & vcount > 480-db[7:1] ? 8'h80 : 0;

wire [6:0] idx = hcount[10:4] - 7'd11;
wire [7:0] db = seq >> { idx, 2'b0 };
reg [255:0] seq;
reg [9:0] vcount;
reg [12:0] hcount;

always @(posedge vsync)
  seq <= { seq[247:0], din };

always @(posedge clk_vid) begin
  hcount <= hcount + 10'd1;
  if (~hsync) hcount <= 10'd0;
end

always @(posedge hsync) begin
  vcount <= vcount + 10'd1;
  if (~vsync) vcount <= 10'd0;
end

endmodule
