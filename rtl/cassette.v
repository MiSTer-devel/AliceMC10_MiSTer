
module cassette(

  input clk,
  input play,
  input rewind,

  output reg [24:0] sdram_addr,
  input [7:0] sdram_data,
  output reg sdram_rd,

  output data

);

assign data = square;

reg started;
reg activated;
reg play_latch;
reg square_latch;

reg reset;
reg [2:0] nbit;
reg [6:0] leader;
reg [39:0] seq;
reg [7:0] nbyte;
reg sclk;
wire done = (square_latch ^ square) & square;

// 00 namefile, 01 data, ff = end of file
// 55 3c 00 0f 47 41 4c...

always @(posedge clk)
  sclk <= ~sclk;

always @(posedge sclk) begin

  play_latch <= play;
  square_latch <= square;

  // play signal changed
  if (play_latch ^ play) begin
    started <= ~started;
    // if it's a new load, then output leader section
    if (~started & sdram_addr == 25'd0) leader <= 7'h7f;
  end

  // pause if end of file block
  if (seq == 40'h3cff00ff55) begin
    activated <= 1'b0;
    reset <= 1'b1;
  end

  if (nbit == 0 & started & activated) begin
    // did we already asked for a read?
    if (~sdram_rd) begin // no
      reset <= 1'b1;
      activated <= 1'b1;
      sdram_rd <= 1'b1;
    end
    else begin // yes
      reset <= 1'b0;
      sdram_rd <= 1'b0;
      if (leader == 7'd0) begin // output normal sdram byte
        sdram_addr <= sdram_addr + 25'd1;
        nbyte <= sdram_data;
      end
      else begin // output leader byte $55
        nbyte <= 8'h55;
        leader <= leader - 7'd1;
      end
      // push byte to sequence
      seq <= { seq[31:0], sdram_data };
    end
  end

  // fetch next byte from sdram
  if (nbit == 7) sdram_rd <= 1'b1;

  // if bit is done (square goes high), do next one
  if (~reset & done & activated) begin
    nbit <= nbit + 1'b1;
    nbyte <= { 1'b0, nbyte[7:1] };
  end

  // rewind
  if (rewind) begin
    sdram_addr <= 25'd0;
    activated <= 1'b0;
    leader <= 7'h7f;
  end

  // pause the square wave
  if (!started) reset <= 1'b1;
end

wire square;
wire freq = nbyte[0];

square_gen sq(
  .reset(reset),
  .clk(clk),
  .freq(freq),
  .s(square)
);


endmodule