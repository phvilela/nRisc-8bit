module DadosMem(
  input clock,
  input MemWrite,
  input MemRead,
  input [7:0] endereco,
  input [7:0] dado,
  output [7:0] saida
);

  reg [7:0] mem [0:255];

  assign saida = MemRead ? mem[endereco] : 8'b0;

  always @(negedge clock) begin
    if (MemWrite) begin
      mem[endereco] <= dado;
    end
  end

endmodule
