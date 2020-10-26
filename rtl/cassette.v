
module cassette(

  input clk,
  input play,
  input rewind,

  output reg [24:0] sdram_addr,
  input [7:0] sdram_data,
  output reg sdram_rd,

  output data

);

reg started;
reg activated;
reg play_latch;
reg square_latch;

reg reset;
reg [2:0] bit;
reg [6:0] leader;
reg [39:0] seq;
reg [7:0] byte;
reg sclk;
wire done = (square_latch ^ square) & square;

always @(posedge clk)
  sclk <= ~sclk;

always @(posedge sclk) begin
  play_latch <= play;
  square_latch <= square;
  if (play_latch ^ play) started <= ~started;
  if (seq == 40'h3cff00ff55) started <= 1'b0;

  if (bit == 0 & started & ~activated) begin
    reset <= 1'b1;
    activated <= 1'b1;
    sdram_rd <= 1'b1;
  end
  if (bit == 0 & started & activated & sdram_rd == 1) begin
    reset <= 1'b0;
    sdram_rd <= 1'b0;
    byte <= sdram_data;
    sdram_addr <= sdram_addr + 25'd1;
    seq <= { seq[31:0], sdram_data };
  end
  if (bit == 7) sdram_rd <= 1'b1;

  if (rewind) activated <= 1'b0;

  if (~reset & done) begin
    bit <= bit + 1'b1;
    byte <= { 1'b0, byte[7:1] };
  end

  if (rewind) sdram_addr <= 25'd0;
end

wire square;
wire freq = byte[0];

square_gen sq(
  .reset(reset),
  .clk(clk),
  .freq(freq),
  .s(square)
);


endmodule