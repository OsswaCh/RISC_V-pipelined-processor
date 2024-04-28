module Branch_Unit(
  input [2:0]inst,
  input cf, zf, vf, sf,Branch,
  output reg flag);
  
  always @* begin
    case(inst)
    3'b000: begin
      flag = zf & Branch; // BEQ
    end
    3'b001: begin
      flag = ~(zf) & Branch; // BNE
    end
    3'b100: begin
      flag = (sf != vf) & Branch; // BLT
    end
    3'b101: begin
      flag = (sf == vf) & Branch; // BGE
    end
    3'b110: begin
      flag = ~cf & Branch; // BLTU
    end
    3'b111: begin
      flag = cf & Branch; // BGEU
    end
    default: begin
      flag = 1'b0; // Default case to handle unexpected values
    end
  endcase
end
  
endmodule