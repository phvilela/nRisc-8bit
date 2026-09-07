module PC(input [7:0] PCin, input clock, output reg [7:0] PCout);
  always @(posedge clock) begin
    PCout <= PCin;
  end
endmodule