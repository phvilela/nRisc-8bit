module UniControle(
    input [2:0] OpCode,
    input [2:0] funct,
    output reg memOut,
    output reg memWrite,
    output reg memRead,
    output reg [1:0] Opc1,
    output reg WriteC1,
    output reg [1:0]RegDst,
    output reg inA,
    output reg [1:0]inB,
    output reg atribui,
    output reg [1:0] ULAop,
    output reg regWrite,
    output reg desvio
);

    always @(*) begin

        // Valores padrao
        memOut   = 0;
        memWrite = 0;
        memRead  = 0;
        Opc1     = 2'b00;
        WriteC1  = 0;
        RegDst   = 2'b00;
        inA      = 0;
        inB      = 2'b00;
        atribui  = 0;
        ULAop    = 2'b00;
        regWrite = 0;
        desvio   = 0;

        casex (OpCode)
            //soma xx0 e sub xx1
            3'b000: begin
      			memOut = 1'b0;
    			memWrite = 1'b0;
    			memRead = 1'b0;
    			Opc1 = 2'b00;
    			WriteC1 = 1'b0;
                inA = 1'b0;
                inB = 2'b00;
                atribui = 1'b0;

                desvio = 1'b0;
    			RegDst = 2'b10;
    			regWrite = 1'b1;

              	casex (funct)
              	  3'bxx0: ULAop = 2'b01;
               	  3'bxx1: ULAop = 2'b00;
              	endcase
            end

            //menor que xx0 e igual que xx1
            3'b001: begin
                memOut = 1'b0;
    			memWrite = 1'b0;
    			memRead = 1'b0;

    			WriteC1 = 1'b1;
                inA = 1'b0;
                inB = 2'b00;
                atribui = 1'b0;
                ULAop = 2'b00;
                desvio = 1'b0;
    			RegDst = 2'b00;
    			regWrite = 1'b0;

              	casex (funct)
                	3'bxx0: Opc1 = 2'b01;
                	3'bxx1: Opc1 = 2'b00;
             	 endcase
            end

            //jump
            3'b010: begin
                memOut = 1'b0;
    			memWrite = 1'b0;
    			memRead = 1'b0;
    			Opc1 = 2'b00;
    			WriteC1 = 1'b0;
                inA = 1'b0;
                inB = 2'b00;
                atribui = 1'b0;
                ULAop = 2'b00;
                desvio = 1'b1;
    			RegDst = 2'b00;
    			regWrite = 1'b0;

            end

            //store xx0 e load xx1
        	3'b011: begin
    			Opc1 = 2'b00;
    			WriteC1 = 1'b0;
                ULAop = 2'b00;
                desvio = 1'b0;
                atribui = 1'b0;

              	casex (funct)
                    3'bxx0: begin
                        memOut = 1'b0;
                        memWrite = 1'b1;
                        memRead = 1'b0;
                        inA = 1'b0;
                        inB = 2'b00;
                        RegDst = 2'b00;
                        regWrite = 1'b0;
                    end
                   	3'bxx1: begin
                        memOut = 1'b1;
                        memWrite = 1'b0;
                        memRead = 1'b1;
                        inA = 1'b0;
                        inB = 2'b00;
                        RegDst = 2'b00;
                        regWrite = 1'b1;
                    end
                endcase
            end
            
            3'b100: begin
                casex (funct)
                	3'bxx0: begin
                        memOut = 1'b0;
                        memWrite = 1'b0;
                        memRead = 1'b0;
                        Opc1 = 2'b00;
                        WriteC1 = 1'b0;
                        inA = 1'b0;
                        inB = 2'b01;
                        atribui = 1'b1;
                        ULAop = 2'b01;
                        desvio = 1'b0;
                        RegDst = 2'b00;
                        regWrite = 1'b1;
                        end
                     endcase
            end

            3'b101: begin
                memOut = 1'b0;
    			memWrite = 1'b0;
    			memRead = 1'b0;
                desvio = 1'b0;
                atribui = 1'b0;

                case (funct)
                    //comp0
                	3'b000: begin
                        Opc1 = 2'b00;
                        WriteC1 = 1'b1;
                        inA = 1'b0;
                        inB = 2'b01;
                        ULAop = 2'b00;
                        RegDst = 2'b00;
                        regWrite = 1'b0;
                        end

                    //sub1
                	3'b001: begin
                        Opc1 = 2'b00;
                        WriteC1 = 1'b0;
                        inA = 1'b0;
                        inB = 2'b10;
                        ULAop = 2'b00;
                        RegDst = 2'b00;
                        regWrite = 1'b1;
                      end
                    3'b010: begin
                        Opc1 = 2'b10;
                        WriteC1 = 1'b1;
                        inA = 1'b0;
                        inB = 2'b00;
                        ULAop = 2'b00;
                        RegDst = 2'b00;
                        regWrite = 1'b0;
                      end
                endcase

            end

            3'b11x: begin
                memOut = 1'b0;
    			memWrite = 1'b0;
    			memRead = 1'b0;
                desvio = 1'b0;
                atribui = 1'b0;
                Opc1 = 2'b00;
                WriteC1 = 1'b0;
                inA = 1'b1;
                inB = 2'b01;
                ULAop = 2'b01;
                RegDst = 2'b01;
                regWrite = 1'b1;
            end

            default: begin

            end
        endcase
    end

endmodule
