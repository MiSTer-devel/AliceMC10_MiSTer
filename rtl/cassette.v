
module cassette(

  input clk_sys,
  input play,
  
  output reg [24:0] sdram_addr,
  input [7:0] sdram_data,
  output sdram_rd,
  
  output data
  
);

reg status;
always @(posedge play)
  status <= ~status;


endmodule