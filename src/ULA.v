module ULA(
    input [7:0] reg1,
    input [7:0] reg2,
    input [1:0] ULAop,
    output reg [7:0] out,
    output reg zero
);
  
    always @(*) begin
        zero = 0;
        
        case (ULAop)
            2'b00: begin
                out = reg1 - reg2;
                if(out == 8'b0) begin 
                    zero = 1;
                end
            end
            2'b01: begin
                out = reg1 + reg2;
            end
            default: begin
                out = 8'b0;
            end
        endcase
    end
  
endmodule
