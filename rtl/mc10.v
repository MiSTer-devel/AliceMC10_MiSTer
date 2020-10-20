
module mc10 (
  input reset,
  input clk_sys,
  input clk_35,
  input [10:0] ps2_key,
  input [10:0] exp_in, // D7-D0, sel, reset, nmi
  output [17:0] exp_out, // R/W, A15-A0, E
  output [7:0] red,
  output [7:0] green,
  output [7:0] blue,
  output hsync,
  output vsync,
  output hblank,
  output vblank
);

wire [15:0] cpu_addr;
wire E_CLK;
wire cpu_rw;
wire [3:0] U4_Y1, U4_Y2;
wire [7:0] rom_dout;
wire [5:0] U5_Y, U6_Y;
wire [12:0] vdg_addr;
wire [11:0] addr_bus = { U5_Y, U6_Y } | vdg_addr[11:0];
wire [7:0] cpu_dout, ram1_dout, ram2_dout, U7_dout, ram_din;
wire [7:0] ram_data_bus = ram1_dout | ram2_dout;
wire [3:0] r4, g4, b4;
wire [7:0] KR;
wire [5:0] U14_out, kb_rows;
wire shift_key;
reg [5:0] U8;

assign red[7:4] = r4;
assign green[7:4] = g4;
assign blue[7:4] = b4;

wire RESET = reset | exp_in[1];

MC6803_gen2 U1(
  .clk(clk_35),
  .RST(RESET),
  .hold(0),
  .halt(0),
  .irq(0),
  .nmi(exp_in[2]),
  .PORT_A_IN(),
  .PORT_B_IN(),
  .DATA_IN(rom_dout | U7_dout | U14_out),
  .PORT_A_OUT(KR),
  .PORT_B_OUT(),
  .ADDRESS(cpu_addr),
  .DATA_OUT(cpu_dout),
  .E_CLK(E_CLK),
  .rw(cpu_rw)
);

rom_mc10 U3(
  .clk(clk_sys),
  .addr(cpu_addr),
  .dout(rom_dout),
  .cs(U4_Y1[3])
);

x74155 U4(
  .C({ U18_qn1, E_CLK }),
  .G({ exp_in[0] | cpu_addr[12], exp_in[0] }),
  .A(cpu_addr[14]),
  .B(cpu_addr[15]),
  .Y1(U4_Y1),
  .Y2(U4_Y2)
);

x74367A U5(
  .A(cpu_addr[11:6]),
  .Y(U5_Y),
  .G(U4_Y1[1])
);

x74367A U6(
  .A(cpu_addr[5:0]),
  .Y(U6_Y),
  .G(U4_Y1[1])
);

x74245 U7(
  .Ai(cpu_dout),
  .Bi(ram_data_bus),
  .Ao(U7_dout),
  .Bo(ram_din),
  .dir(~cpu_rw),
  .G(U4_Y1[1])
);

wire U8_clock = cpu_rw | U4_Y1[2];
always @(posedge U8_clock or posedge RESET)
  if (RESET) U8 <= 6'd0;
  else U8 <= cpu_dout[7:2];

bram u9(
  .address(addr_bus[10:0]),
  .clock(clk_sys),
  .data(ram_din),
  .q(ram1_dout),
  .wren(~(U4_Y2[1] | cpu_rw)),
  .rden(~addr_bus[11])
);

bram u10(
  .address(addr_bus[10:0]),
  .clock(clk_sys),
  .data(ram_din),
  .q(ram2_dout),
  .wren(~(U4_Y2[1] | cpu_rw)),
  .rden(addr_bus[11])
);

mc6847_mc10 U11(
  .clk(clk_35),
  .clk_ena(1'b1),
  .reset(RESET),
  .addr(vdg_addr),
  .dd(ram_data_bus),
  .an_g(U8[3]),
  .an_s(ram_data_bus[7]),
  .intn_ext(U8[0]),
  .gm({ U8[0], U8[1], U8[2] }),
  .css(U8[4]),
  .inv(ram_data_bus[6]),
  .red(r4),
  .green(g4),
  .blue(b4),
  .hsync(hsync),
  .vsync(vsync),
  .hblank(hblank),
  .vblank(vblank),
  .ms(U4_Y1[1])
);

x14503B U14(
  .in(kb_rows),
  .out(U14_out),
  .A(U4_Y1[2] | ~cpu_rw),
  .B(U4_Y1[2] | ~cpu_rw)
);

keyboard keyboard(
  .clk_sys(clk_sys),
  .reset(RESET),
  .ps2_key(ps2_key),
  .addr(KR),
  .kb_rows(kb_rows),
  .kblayout(1'b1),
  .Fn(),
  .modif(shift)
);

wire U18_qn1;
x7474 U18(
  .clk1(clk_35),
  .p1(1'b0),
  .c1(E_CLK),
  .d1(U18_qn1),
  .q1(),
  .qn1(U18_qn1)
);

endmodule