module test_UniControle;

    reg [2:0] OpCode;
    reg [2:0] funct;
    wire memOut, memWrite, memRead;
    wire [1:0] Opc1;
    wire WriteC1;wire [1:0] RegDst;
    wire inA;
    wire [1:0] inB;
    wire atribui;
    wire [1:0] ULAop;
    wire regWrite;
    wire desvio;
    
    // Instancia o módulo
    UniControle uut (
        .OpCode(OpCode),
        .funct(funct),
        .memOut(memOut),
        .memWrite(memWrite),
        .memRead(memRead),
        .Opc1(Opc1),
        .WriteC1(WriteC1),
        .RegDst(RegDst),
        .inA(inA),
        .inB(inB),
        .atribui(atribui),
        .ULAop(ULAop),
        .regWrite(regWrite),
        .desvio(desvio)
    );
    
    initial begin
        $display("Teste da Unidade de Controle");
        $display("OpCode Funct | memOut memWrite memRead Opc1 WriteC1 RegDst inA inB atribui ULAop regWrite desvio");
        // Testes
        OpCode = 3'b000; funct = 3'b000; #1; // add - soma
        print_outputs();
        OpCode = 3'b000; funct = 3'b001; #1; // sub - subtração
        print_outputs();
        OpCode = 3'b010; funct = 3'b000; #1; // jc - jump condicional
        print_outputs();
        OpCode = 3'b011; funct = 3'b000; #1; // sw - store
        print_outputs();
        OpCode = 3'b011; funct = 3'b001; #1; // lw - load
        print_outputs();
        OpCode = 3'b100; funct = 3'b000; #1; // atr - atribui
        print_outputs();
        OpCode = 3'b101; funct = 3'b000; #1; // cmp0 - compara com 0
        print_outputs();
        OpCode = 3'b101; funct = 3'b001; #1; // sub1 - subtrai 1
        print_outputs();
        OpCode = 3'b101; funct = 3'b010; #1; // setc1 - define flag $c0 para 1
        print_outputs();
        OpCode = 3'b110; funct = 3'b000; #1; // set - define imediato
        print_outputs();
        $finish;
    end
    task print_outputs;
        begin
            $display("%b\t%b  | %b\t%b\t%b\t%b\t%b\t%b %b   %b\t%b\t%b\t%b\t%b",
            OpCode, funct,
            memOut, memWrite, memRead, Opc1, WriteC1, RegDst,
            inA, inB, atribui, ULAop, regWrite, desvio);
        end
    endtask
endmodule
