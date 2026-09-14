`timescale 1ns / 1ps

module testbench_processador;
    reg clock;
    
    processador uut (
        .clock(clock)
    );
    
    // 1. OBRIGATÓRIO: Oscilação periodica do clock
    always #5 clock = ~clock;
    
    initial begin
        // Força saída imediata no terminal para validar execução
        $display("=== INICIANDO SIMULACAO DO PROCESSADOR ===");
        $fflush();
        
        // $dumpfile("processador.vcd");
        // $dumpvars(0, testbench_processador);

        clock = 0;
        
        // Inicializacao dos registradores e memorias
        uut.PC_reg.PCout = 8'b00000000;
        uut.mem_dados.mem[0] = 8'd10;
        
        uut.mem_inst.mem[0]  = 8'b11110000;
        uut.mem_inst.mem[1]  = 8'b01111111;
        uut.mem_inst.mem[2]  = 8'b11010000;
        uut.mem_inst.mem[3]  = 8'b11100001;
        uut.mem_inst.mem[4]  = 8'b10111000;
        uut.mem_inst.mem[5]  = 8'b01000110;
        uut.mem_inst.mem[6]  = 8'b00001100;
        uut.mem_inst.mem[7]  = 8'b10001100;
        uut.mem_inst.mem[8]  = 8'b10010000;
        uut.mem_inst.mem[9]  = 8'b10111001;
        uut.mem_inst.mem[10] = 8'b10100010;
        uut.mem_inst.mem[11] = 8'b01011000;
        uut.mem_inst.mem[12] = 8'b11110001;
        uut.mem_inst.mem[13] = 8'b11111010;
        uut.mem_inst.mem[14] = 8'b01111110;
        uut.mem_inst.mem[15] = 8'b01111110;

        uut.mem_dados.mem[1] = 0;
        
        $monitor("Time=%0t PC=%h Inst=%h Op=%b Fn=%b R0=%h R1=%h R2=%h R3=%h ULA=%h Z=%b C1=%b Mem[1]=%d tst=%h",
                 $time, uut.PCatual, uut.instrucao, uut.opcode, uut.funct,
                 uut.registradores.mem[0], uut.registradores.mem[1], uut.registradores.mem[2], uut.registradores.mem[3],
                 uut.saida_ula, uut.zero, uut.c1, uut.mem_dados.mem[1], uut.mem_dados.mem[10]);
        
        #200;
        $display("=== SIMULACAO FINALIZADA ===");
        $finish;
    end
endmodule
