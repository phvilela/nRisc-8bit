module RegMem(
  input clock,
  input escreve,
  input [7:0] dado,
  input [1:0] destino,
  input [1:0] in1,
  input [1:0] in2,
  output reg [7:0] out1,
  output reg [7:0] out2
);

  reg [7:0] mem [0:3];
  
  initial begin
    mem[0] = 8'b01100100;
    mem[1] = 8'b00000000;
    mem[2] = 8'b00000000;
    mem[3] = 8'b00000000;
  end

  always @(posedge clock) begin
    out1 = mem[in1];
    out2 = mem[in2];
  end

  always @(negedge clock) begin
    if (escreve) begin
      mem[destino] = dado;
    end
  end

endmodule








