
module overlay(
  input clk_vid,
  input [3:0] status,
  input hsync,
  input vsync,
  output [7:0] color,
  input en
);

assign color = en & status[2:0] != 0 & count < 40 & active ? 8'hff : 0;

reg [9:0] count;
reg active;

always @(posedge vsync)
  active <= status[3];

always @(posedge hsync) begin
  count <= count + 10'd1;
  if (~vsync) count <= 10'd0;
end

endmodule