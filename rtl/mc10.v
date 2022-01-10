
module mc10 (
  input reset,
  input clk_sys,
  input clk_video,
  input clk_4,
  input [10:0] ps2_key,

  // expansion connector
  input [7:0] exp_din,
  input exp_sel,
  input exp_nmi,
  output [7:0] exp_dout,
  output exp_rw,
  output [15:0] exp_addr,
  output exp_reset,
  output exp_e,

  input rs232_a,
  input rs232_b,

  output [7:0] red,
  output [7:0] green,
  output [7:0] blue,
  output hsync,
  output vsync,
  output hblank,
  output vblank,
  output ce_pix,

  output audio,
  input cin
);

wire [15:0] cpu_addr;
wire E_CLK;
wire cpu_rw;
wire [3:0] U4_Y1, U4_Y2;
wire [12:0] vdg_addr;
wire [7:0] cpu_dout, rom_dout, ram_dout, ram_dout_b;
wire [3:0] r4, g4, b4;
wire [7:0] KR, kb_rows;
wire [5:0] U14_out;
wire shift = kb_rows[6];
reg [5:0] U8;

assign audio = U8[5];

assign exp_addr = cpu_addr;
assign exp_rw = cpu_rw;
assign exp_dout = cpu_dout;
assign exp_reset = reset;
assign exp_e = E_CLK;

reg [1:0] clk_div;
always @(posedge clk_4)
  clk_div <= clk_div + 2'd1;

wire clk_cpu = clk_div[1];

reg [7:0] data_bus;
always @(posedge clk_sys)
  data_bus <= rom_dout | (U4_Y1[1] ? 8'd0 : ram_dout) | U14_out | exp_din;

MC6803_gen2 U1(
  .clk(clk_cpu),
  .RST(reset),
  .hold(0),
  .halt(0),
  .irq(0),
  .nmi(exp_nmi),
  .PORT_A_IN(),
  .PORT_B_IN({ cin, rs232_a, rs232_b|reset, shift, reset }),
  .DATA_IN(data_bus),
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
  .C(2'b01),
  .G({ exp_sel | cpu_addr[12], exp_sel }),
  .A(cpu_addr[14]),
  .B(cpu_addr[15]),
  .Y1(U4_Y1),
  .Y2(U4_Y2)
);

wire U8_clock = ~(cpu_rw | U4_Y1[2]);

always @(posedge clk_sys)
  if (reset) U8 <= 6'd0;
  else if (U8_clock) U8 <= cpu_dout[7:2];

dpram u9_u10(
  .clock_a(clk_sys),

  .address_a(cpu_addr[11:0]),
  .data_a(cpu_dout),
  .wren_a(~(cpu_rw|U4_Y1[1]|U4_Y2[1])),
  .q_a(ram_dout),

  .clock_b(clk_video),
  .address_b(vdg_addr[11:0]),
  .q_b(ram_dout_b)
);

/*
reg [3:0] clk_vid;
always @(posedge clk_video)
  clk_vid <= clk_vid + 4'd1;
*/
  
reg clk_14M318_ena ;
reg [1:0] count;


always @(posedge clk_video)
begin
	if (reset)
		count<=0;
	else
	begin
		clk_14M318_ena <= 0;
		if (count == 'd2)
		begin
		  clk_14M318_ena <= 1;
        count <= 0;
		end
		else
		begin
			count<=count+1;
		end
	end
end  
  
mc6847 U11(
  //.clk(clk_vid[1]),
  //.clk_ena(clk_vid[2]),
  .clk(clk_video),
  .clk_ena(clk_14M318_ena),
  .reset(reset),
  .da0(),
  .videoaddr(vdg_addr),
  .dd(ram_dout_b),
  .an_g(U8[3]),
  .an_s(ram_dout_b[7]),
  .intn_ext(U8[0]),
  .gm({ U8[0], U8[1], U8[2] }),
  .css(U8[4]),
  .inv(ram_dout_b[6]),
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
  .pixel_clk(ce_pix)
);

x14503B U14(
  .in(~kb_rows),
  .out(U14_out),
  .A(U4_Y1[2] | ~cpu_rw),
  .B(U4_Y1[2] | ~cpu_rw)
);

keyboard keyboard(
  .clk_sys(clk_sys),
  .reset(reset),
  .ps2_key(ps2_key),
  .addr(KR),
  .kb_rows(kb_rows),
  .kblayout(1'b0)
);

endmodule