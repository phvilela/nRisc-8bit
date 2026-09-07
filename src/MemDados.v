module DadosMem(
  input clock,
  input MemWrite,
  input MemRead,
  input [7:0] endereco,
  input [7:0] dado,
  output reg [7:0] saida
);

  reg [7:0] mem [0:255];

  always @(posedge clock) begin
    if (MemRead) begin
      saida <= mem[endereco];
    end
  end

  always @(negedge clock) begin
    if (MemWrite) begin
      mem[endereco] <= dado;
    end
  end

endmodule