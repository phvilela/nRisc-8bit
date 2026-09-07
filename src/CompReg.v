module comp(clock, in, hab, c1);
  
  input clock, in, hab;
  output reg c1;

  always @(negedge clock) begin
    if (hab) begin
      if (in)
        c1 = 1;
      else
        c1 = 0;
    end
  end

endmodule
