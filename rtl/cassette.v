
module cassette(

  input clk,
  input play,
  input rewind,

  output reg [24:0] sdram_addr,
  input [7:0] sdram_data,
  output reg sdram_rd,

  output data

);

reg en;
reg play_latch;

reg [23:0] seq;
reg [7:0] ibyte;
reg [3:0] state;
reg [7:0] length;
reg sq_start;
wire done;

parameter
  IDLE      = 4'h0,
  START     = 4'h1,
  NEXT      = 4'h2,
  LEAD1     = 4'h3,
  LEAD2     = 4'h4,
  LEAD3     = 4'h5,
  READ_DAT1 = 4'h6,
  READ_DAT2 = 4'h7,
  READ_DAT3 = 4'h8,
  READ_DAT4 = 4'h9;

always @(posedge clk) begin

  play_latch <= play;

  if (play_latch ^ play) state <= state == IDLE ? START : IDLE;

  case (state)
    START: begin
      length <= 8'h7f;
      state <= LEAD1;
    end

    NEXT: begin

      state <= READ_DAT1;
      if (seq)
        case (seq)
          24'h553c00: begin // name block
            state <= READ_DAT1;
            length <= sdram_data;
            sdram_addr <= sdram_addr + 25'd1;
          end
          default: begin
            state <= IDLE;
          end
        endcase
      else
        length <= 8'd3;

    end

    LEAD1: begin
      ibyte <= 8'h55;
      sq_start <= 1'b1;
      state <= LEAD2;
    end
    LEAD2: begin
      sq_start <= 1'b0;
      state <= done ? LEAD3 : LEAD2;
    end
    LEAD3: begin
      if (length != 0) begin
        length <= length - 8'd1;
        state <= LEAD1;
      end
      else begin
        seq <= 24'd0;
        state <= NEXT;
      end
    end

    READ_DAT1: begin
      sdram_rd <= 1'b1;
      state <= READ_DAT2;
    end
    READ_DAT2: begin
      sdram_rd <= 1'b0;
      sdram_addr <= sdram_addr + 25'd1;
      seq <= { seq[15:0], sdram_data };
      state <= READ_DAT3;
      sq_start <= 1'b1;
    end
    READ_DAT3: begin
      ibyte <= sdram_data;
      sq_start <= 1'b0;
      state <= done ? READ_DAT4 : READ_DAT3;
    end
    READ_DAT4: begin
      if (length != 0) begin
        length <= length - 8'd1;
        state <= READ_DAT1;
      end
      else
        state <= NEXT;
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