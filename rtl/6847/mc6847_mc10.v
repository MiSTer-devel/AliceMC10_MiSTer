
module mc6847_mc10(
  input             clk,
  input             clk_ena,
  input             reset,
  output [12:0]     addr,
  input  [7:0]      dd,
  input             an_g,
  input             an_s,
  input             intn_ext,
  input  [2:0]      gm,
  input             css,
  input             inv,
  output [3:0]      red,
  output [3:0]      green,
  output [3:0]      blue,
  output            hsync,
  output            vsync,
  output            hblank,
  output            vblank,
  input ms
);

wire [12:0] videoaddr;
assign addr = ms ? videoaddr : 13'd0;

reg [7:0] data_latch;
reg an_s_latch, inv_latch;
always @(posedge clk)
  if (ms) begin
    data_latch <= dd;
    an_s_latch <= an_s;
    inv_latch <= inv;
  end

mc6847 vdg(
  .clk(clk),
  .clk_ena(clk_ena),
  .reset(reset),
  .da0(),
  .videoaddr(videoaddr),
  .dd(data_latch),
  .hs_n(),
  .fs_n(),
  .an_g(an_g),
  .an_s(an_s_latch),
  .intn_ext(intn_ext),
  .gm(gm),
  .css(css),
  .inv(inv_latch),
  .red(red),
  .green(green),
  .blue(blue),
  .hsync(hsync),
  .vsync(vsync),
  .hblank(hblank),
  .vblank(vblank),
  .artifact_en(1'b1),
  .artifact_set(1'b0),
  .artifact_phase(1'b1),
  .cvbs(),
  .black_backgnd(1'b1),
  .char_a(vdg_char_addr),
  .char_d_o(char_data)
);

wire [7:0] chr_dout;
wire [10:0] vdg_char_addr;
wire [8:0] char_rom_addr;
assign char_rom_addr[8:3] = vdg_char_addr[9:4];
assign char_rom_addr[2:0] = temp_vdg_char_addr[2:0];
wire [3:0] temp_vdg_char_addr = vdg_char_addr[3:0] - 2'b11;
wire [7:0] char_data = (vdg_char_addr[3:0] < 3 || vdg_char_addr[3:0] > 10) ? 8'h00 : chr_dout;

rom_char rom_char(
  .clk(clk),
  .addr(char_rom_addr),
  .dout(chr_dout)
);

endmodule