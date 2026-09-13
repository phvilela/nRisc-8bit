`timescale 1ns / 1ps

module tb_ULA;

    reg [7:0] reg1;
    reg [7:0] reg2;
    reg [1:0] ULAop;

    wire [7:0] out;
    wire zero;

    ULA uut (
        .reg1(reg1),
        .reg2(reg2),
        .ULAop(ULAop),
        .out(out),
        .zero(zero)
    );

    initial begin
        $display("Tempo | reg1 | reg2 | ULAop | out | zero");
        $monitor("%4dns |  %3d |  %3d |  %2b   | %3d |  %1b", $time, reg1, reg2, ULAop, out, zero);

        reg1 = 8'd10;
        reg2 = 8'd10;
        ULAop = 2'b00;
        #10;

        reg1 = 8'd20;
        reg2 = 8'd10;
        ULAop = 2'b00;
        #10;

        reg1 = 8'd15;
        reg2 = 8'd25;
        ULAop = 2'b01;
        #10;

        reg1 = 8'd5;
        reg2 = 8'd3;
        ULAop = 2'b10;
        #10;

        $finish;
    end

endmodule
