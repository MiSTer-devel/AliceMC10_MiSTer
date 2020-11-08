//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	output  [7:0] VIDEO_ARX,
	output  [7:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,

	/*
	// Use framebuffer from DDRAM (USE_FB=1 in qsf)
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of 16 bytes.
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
	*/

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;

assign VGA_SL = 0;
assign VGA_F1 = 0;

assign AUDIO_S = 0;
assign AUDIO_MIX = 0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

//////////////////////////////////////////////////////////////////

assign VIDEO_ARX = status[1] ? 8'd16 : 8'd4;
assign VIDEO_ARY = status[1] ? 8'd9  : 8'd3;

//       exp on/off  Tape rewind   Tape play                    reset
// V ...     C             B           A      9 8 7 6 5 4 3 2 1   0
`include "build_id.v"
localparam CONF_STR = {
	"AliceMC10;;",
	"-;",
	"O1,Aspect ratio,4:3,16:9;",
	"OC,16k expansion,Off,On;",
	"-;",
	"F1,c10,Tape Load;",
	"TA,Tape Play/Pause;",
	"TB,Tape Rewind;",
	"OD,Show tape stream,Off,On;",
	"OE,Enable tape audio,Off,On;",
	"-;",
	"T0,Reset;",
	"R0,Reset and close OSD;",
	"J1,Button;",
	"V,v",`BUILD_DATE
};

wire forced_scandoubler;
wire  [1:0] buttons;
wire [31:0] status;
wire [10:0] ps2_key;

wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire        ioctl_download;
wire  [7:0] ioctl_index;
wire		ioctl_wait;

wire [31:0] joy0, joy1;
wire rs1 = joy0[4] | joy0[1];
wire rs2 = joy0[4] | joy0[0];

hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),
	.gamma_bus(),

	.conf_str(CONF_STR),
	.forced_scandoubler(forced_scandoubler),

	.buttons(buttons),
	.status(status),
	.status_menumask({status[5]}),

	.ps2_key(ps2_key),

	.ioctl_download(ioctl_download),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_wait(ioctl_wait),
	.ioctl_index(ioctl_index),

	.joystick_0(joy0),
	.joystick_1(joy1)

);


///////////////////////   CLOCKS   ///////////////////////////////

wire locked;
wire clk_sys;
wire clk_4; // 4MHz
wire clk_vid;

pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),
	.outclk_1(clk_4),
	.outclk_2(clk_vid),
	.locked(locked)
);


wire reset = RESET | status[0] | buttons[1];

//////////////////////////////////////////////////////////////////

wire hblank;
wire vblank;
wire hsync;
wire vsync;
wire audio;
reg ce_pix;

wire [15:0] exp_addr;
wire [7:0] exp_ram_dout;
wire [7:0] exp_dout;
wire exp_rw;
wire exp_sel = status[12] && (exp_addr[15:12]  > 4 && exp_addr[15:12] < 9);
wire [7:0] joy_dout;
wire [2:0] tape_status;
wire [7:0] mc10_red, ov_red;
wire tape_audio = status[14] ? k7_dout : 1'b0;

mc10 mc10
(
	.reset(reset),
	.clk_sys(clk_sys),
	.clk_4(clk_4),
	.clk_vid(clk_vid),

	.ps2_key(ps2_key),

	.exp_din((exp_sel ? exp_ram_dout : 8'd0) | joy_dout),
	.exp_sel(exp_sel),
	.exp_nmi(),
	.exp_dout(exp_dout),
	.exp_rw(exp_rw),
	.exp_addr(exp_addr),
	.exp_reset(),
	.exp_e(),

	.rs232_a(~rs1),
	.rs232_b(~rs2),

	.red(mc10_red),
	.green(VGA_G),
	.blue(VGA_B),

	.hsync(hsync),
	.vsync(vsync),
	.hblank(hblank),
	.vblank(vblank),

	.audio(audio),

	.cin(k7_dout & tape_status)
);

assign AUDIO_L = { audio, audio, 6'd0, tape_audio, 7'd0 };
assign AUDIO_R = { audio, audio, 6'd0, tape_audio, 7'd0 };
assign CE_PIXEL = ce_pix;
assign CLK_VIDEO = clk_sys;
assign VGA_DE = ~(hblank | vblank);
assign VGA_HS = hsync;
assign VGA_VS = vsync;
assign VGA_R = mc10_red | ov_red;

always @(posedge clk_sys) ce_pix = ~ce_pix;

wire [24:0] sdram_addr;
wire [7:0] sdram_data;
wire sdram_rd;

sdram sdram
(
	.*,
	.init(~locked),
	.clk(clk_sys),
	.addr(ioctl_download ? ioctl_addr : sdram_addr),
	.wtbt(0),
	.dout(sdram_data),
	.din(ioctl_dout),
	.rd(sdram_rd),
	.we(ioctl_wr),
	.ready()
);

wire k7_dout;

cassette cassette(
  .clk(clk_4),
  .play(status[10]),
  .rewind(status[11]),

  .sdram_addr(sdram_addr),
  .sdram_data(sdram_data),
  .sdram_rd(sdram_rd),

  .data(k7_dout),
  .status(tape_status)
);

// it shows tape status
overlay ov(
  .clk_vid(clk_sys),
  .din(sdram_data),
  .sample(sdram_rd),
  .vsync(vsync),
  .hsync(hsync),
  .status({ k7_dout, tape_status }),
  .color(ov_red),
  .en(status[13])
);

joysticks joysticks(
  .joy1(joy0),
  .joy2(joy1),
  .addr(exp_addr),
  .dout(joy_dout)
);

spram exp_ram(
  .clock(clk_sys),
  .address(exp_addr[14:0]),
  .data(exp_dout),
  .wren(~exp_rw & exp_sel),
  .q(exp_ram_dout)
);

endmodule
