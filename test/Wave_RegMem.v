module test_RegMem;

  reg clock;
  reg escreve;
  reg [7:0] dado;
  reg [1:0] destino;
  reg [1:0] in1;
  reg [1:0] in2;
  wire [7:0] out1;
  wire [7:0] out2;

  BancoReg alfa(
    .clock(clock),
    .escreve(escreve),
    .dado(dado),
    .destino(destino),
    .in1(in1),
    .in2(in2),
    .out1(out1),
    .out2(out2)
  );

  // Geracao do Clock (periodo de 10 unidades de tempo)
  always #5 clock = ~clock;

  initial begin
    // INSTRUÇOES PARA O GTKWAVE:
    $dumpfile("ondas.vcd");    // Nome do arquivo gerado
    $dumpvars(0, test_RegMem); // Salva as variáveis deste módulo e submódulos

    // Valores Iniciais
    clock = 0;
    escreve = 0;
    dado = 8'h00;
    destino = 2'b00;
    in1 = 2'b00;
    in2 = 2'b00;

    $display("Tempo | Clk | esc | dest | dado | in1 | in2 || out1 | out2");
    $monitor("%4t   %b     %b     %b     %h     %b    %b  || %h     %h",
              $time, clock, escreve, destino, dado, in1, in2, out1, out2);
    
    // Teste 2: Ler registradores 2 e 1
    #30 
    in1 = 2'b10;
    in2 = 2'b01;
    
    // Teste 1: Escrever 0xAA no registrador 2
    #5 
    escreve = 1;
    dado = 8'hAA;
    destino = 2'b10;
    
    #10 
    escreve = 0;

    // Finalizar
    #20 $finish;
  end

endmodule