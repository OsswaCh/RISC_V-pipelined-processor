
module alu_ctrl(
  input [1:0] aluop, input [2:0] inst1,input inst2, lui,
output reg [3:0] alusel
    );
  
  
  always @(*) begin
       
    case({aluop,lui})
         3'b000: begin
           alusel = 4'b0010;
         end
         3'b010: begin
           alusel = 4'b0110;
         end
         3'b100: begin
           case({inst1,inst2})
             4'b0000: begin
               alusel = 4'b0010;
             end
             4'b0001: begin
               alusel = 4'b0110;
             end
             4'b1110: begin /*and*/
               alusel = 4'b0000;
             end
             4'b1100: begin /*or*/
               alusel = 4'b0001;
             end
             4'b0010: begin
               alusel = 4'b0011;
             end
              4'b0100: begin
               alusel = 4'b0111;
             end
             4'b0110: begin
               alusel = 4'b1111;
             end
             4'b1010: begin
               alusel = 4'b1000;
             end
             4'b1011: begin
               alusel = 4'b1100;
             end
             4'b1000: begin /*xor*/
               alusel = 4'b1001; 
             end
             default: begin
               alusel = 4'b0010;
             end
           endcase
         end
         
         3'b110: begin
           case (inst1)
             3'b000: begin
             	alusel = 4'b0010;/*addi*/
             end
             3'b010: begin
               alusel = 4'b0111; /* slti*/
             end
             3'b100: begin /*xori*/
               alusel = 4'b1001; 
             end
             3'b110: begin /*ori*/
               alusel = 4'b0001;
             end
             3'b111: begin /*andi*/
               alusel = 4'b0000;
             end
             3'b001: begin /*shift left i */
               alusel = 4'b0100;
             end
             3'b101: begin /*shift left i instructions*/
               alusel = 4'b0101;
             end
             
           endcase
           
         end
      
      	3'b111: begin //for auipc
          alusel = 4'b0010;
        end
         
         default: begin
           alusel = 4'b0001;
         end
       endcase

    end
endmodule