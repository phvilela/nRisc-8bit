module processador(input clock);
  wire [7:0] instrucao;
  wire [2:0] opcode = instrucao[7:5];
  wire [2:0] funct  = instrucao[2:0];

  wire [1:0] reg1_sel = instrucao[4:3];
  wire [1:0] reg2_sel = instrucao[2:1];
  wire [1:0] destino_sel;
  wire [7:0] imediato_ext = {4'b0, instrucao[3:0]};
  wire [7:0] dado_escrever;

  wire [7:0] dado1, dado2, saida_ula, saida_mem, proxPC, PCatual,imediatoULA;
  wire [1:0] ulaOp, inB_sel, RegDst, Opc1;
  wire inA, memOut, memWrite, memRead, atribui, regWrite, WriteC1, desvio;

  wire c1, hab_comp, zero, in_comp;

  assign proxPC = (c1 && desvio) ?
                   (instrucao[4] ? (PCatual - imediato_ext) : (PCatual + imediato_ext)) :
                   (PCatual + 8'd1);

  PC PC_reg(.PCin(proxPC), .clock(clock), .PCout(PCatual));

  meminst mem_inst(.clock(clock), .pc(PCatual), .out(instrucao));

  UniControle controle(
    .OpCode(opcode),
    .funct(funct),
    .memOut(memOut),
    .memWrite(memWrite),
    .memRead(memRead),
    .Opc1(Opc1),
    .WriteC1(WriteC1),
    .RegDst(RegDst),
    .inA(inA),
    .inB(inB_sel),
    .atribui(atribui),
    .ULAop(ulaOp),
    .regWrite(regWrite),
    .desvio(desvio)
  );

assign destino_sel = (RegDst == 2'b00) ? instrucao[2:1] :
                       (RegDst == 2'b01) ? instrucao[4:3] :
                       2'b00;


  	RegMem regs(
    .clock(clock),
    .escreve(regWrite),
    .dado(dado_escrever),
    .destino(destino_sel),
    .in1(instrucao[4:3]),
    .in2(instrucao[2:1]),
    .out1(dado1),
    .out2(dado2)
  );

  assign imediatoULA = {2'b00,instrucao[5:0]};

  wire [7:0] operando_a = (inA == 0) ? (atribui ? dado2 : dado1):
  						  imediatoULA;

  wire [7:0] operando_b = (inB_sel == 2'b00) ? dado2 :
                        (inB_sel == 2'b01) ? 8'b0 :
                        (inB_sel == 2'b10) ? 8'b00000001 :
                        8'b0;

  ULA ula(
    .reg1(operando_a),
    .reg2(operando_b),
    .ULAop(ulaOp),
    .out(saida_ula),
    .zero(zero)
  );

  assign hab_comp = WriteC1;

  assign in_comp = (Opc1 == 2'b00) ? zero :
    			   (Opc1 ==2'b01) ? (saida_ula[7] || zero):
    			   (Opc1 == 2'b10) ? 1 :
    			   0;

  comp comp_unit(
    .clock(clock),
    .in(in_comp),
    .hab(hab_comp),
    .c1(c1)
  );

  DadosMem mem_dados(
    .clock(clock),
    .MemWrite(memWrite),
    .MemRead(memRead),
    .endereco(dado2),
    .dado(dado1),
    .saida(saida_mem)
  );

  assign dado_escrever = memOut ? saida_mem :
                         saida_ula;

endmodule
