module meminst(clock,pc,out);
  input clock;
  input [7:0]pc;
  output reg[7:0] out;
  
  reg [7:0] mem [0:255];
  
  always @(posedge clock) begin
    out <= mem[pc];
  end
endmodule
