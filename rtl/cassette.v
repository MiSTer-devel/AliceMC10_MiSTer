
module cassette(

  input clk,
  input play,
  input rewind,

  output reg [24:0] sdram_addr,
  input [7:0] sdram_data,
  output reg sdram_rd,

  output data

);

reg ffplay;
reg ffrewind;

reg [23:0] seq;
reg [7:0] ibyte;
reg [2:0] state;
reg sq_start;
reg [1:0] eof;
wire done;

parameter
  IDLE      = 3'h0,
  START     = 3'h1,
  NEXT      = 3'h2,
  READ1     = 3'h3,
  READ2     = 3'h4,
  READ3     = 3'h5,
  READ4     = 3'h6;


always @(posedge clk) begin

  ffplay <= play;
  ffrewind <= rewind;

  if (ffplay ^ play) state <= state == IDLE ? START : IDLE;
  if (ffrewind ^ rewind) begin
    seq <= 24'd0;
    sdram_addr <= 25'd0;
    state <= IDLE;
    eof <= 2'd0;
  end

  case (state)
    START: begin
      seq <= 24'd0;
      state <= NEXT;
    end
    NEXT: begin
      state <= READ1;
      sdram_rd <= 1'b0;
      eof <= 2'd0;
      if (seq == 24'h553cff) eof <= 2'd1;
      if (seq == 24'h00ff55 && eof == 2'd1) eof <= 2'd2;
    end
    READ1: begin
      sdram_rd <= 1'b1;
      state <= READ2;
    end
    READ2: begin
      ibyte <= sdram_data;
      sdram_rd <= 1'b0;
      state <= READ3;
      sq_start <= 1'b1;
    end
    READ3: begin
      sq_start <= 1'b0;
      state <= done ? READ4 : READ3;
    end
    READ4: begin
      seq <= { seq[15:0], sdram_data };
      sdram_addr <= sdram_addr + 25'd1;
      state <= eof == 2'd2 ? IDLE : NEXT;
    end
  endcase

end

square_gen sq(
  .clk(clk),
  .start(sq_start),
  .din(ibyte),
  .done(done),
  .dout(data)
);


endmodule
