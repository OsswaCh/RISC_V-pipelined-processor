/*******************************************************************
*
* Module: NbitALU
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: alu that performs the arithmatic and logical operations for the processor
*
* Change history: created in lab 3
added the new instructions
fixed the output flags
*
**********************************************************************/
`include "defines.v"
`include "RCA.v"


module NbitALU #(parameter N=32)(
input [N-1:0] A,
input [N-1:0] B,
input [4:0]alu_control,
output reg [N-1:0] ALUout,
output Z,
output V,
output C,
output S
);
    wire [N-1:0] summed;
    wire [N-1:0] subbed;
  wire [N-1:0] op_b;
    reg [(N+N-1):0] mul;
    wire ERR1, ERR2;
    wire cout;
  
    
  assign op_b = (~B);  
  assign {C, summed} = alu_control[0] ? (A + op_b + 1'b1) : (A + B); // add or sub  
  assign Z = (summed == 0);
  assign S = summed[N-1];
  assign V = (A[N-1] ^ (op_b[N-1]) ^ summed[N-1] ^ C);


  
  
  RCA #(.N(32))  RCA1(.A(A),.B(B),.sum(summed),.cout(cout),.err(ERR1));
  RCA #(.N(32))  RCA2(.A(A),.B(~B+1'b1),.sum(subbed),.cout(cout),.err(ERR2));
  
    
    
  
  always@(*)
    begin
        //choosing output
        case(alu_control)
        
            `ALU_ADD: // add
                ALUout = summed;

            `ALU_SUB: // sub
                ALUout = subbed;

            `ALU_AND: // and
                ALUout = A&B;

            `ALU_OR:  // or
                ALUout = A|B;
                
            `ALU_XOR: // xor
                ALUout = A^B;

            `ALU_SRL: // shift right logical
                ALUout = A>>B;

            `ALU_SRA: // shift right arithmetical
                ALUout = $signed(A)>>>B;

            `ALU_SRAI:
                ALUout = $signed(A)>>>B[5:0];

            `ALU_SLL: // shift left
                ALUout = A<<B;

            `ALU_SLT: // set less than unsigned 
                begin 
                    ALUout = ($signed(A) < $signed(B));

                end

            `ALU_SLTU: // set on less than unsigned  
                begin
                  if(A>B)
                        ALUout = {31'b0,1'b1};
                    else
                        ALUout = 32'b0;
                end

          `ALU_MUL: // rs1*rs2 (result [31:0] in rd)
                ALUout = $signed(A)*$signed(B);

          `ALU_MULH: //signed rs1*rs2 (result upper 32 in rd)
                ALUout = ($signed(A) * $signed(B)) >>> 32;

            `ALU_MULHSU: begin // multiplies signed operand rs1 and unsigned r operands2 and stores the upper 32 bits in rd.
                mul = ($signed(A) * $signed({1'b0, B}));
              ALUout =  mul[(N+N-1):N];
             end

            `ALU_MULHU: // multiplies 2 unsigned operands rs1 and rs2 and stores the upper 32 bits in rd.
                ALUout = (A * B) >> 32;

            `ALU_DIV:  // divides two signed operands while taking into account the exceptions
                begin
                    if(B == 32'b0)
                        ALUout = -32'd1;
                    else    
                        begin
                            if(A == -32'd2147483648 && B == -32'd1)
                                ALUout = -32'd2147483648;
                            else
                                ALUout = $signed(A) / $signed(B);
                        end
                end
            `ALU_DIVU: // divides two unsigned operands while taking into account the exceptions
                begin
                    if(B == 32'b0)
                        ALUout = 32'd4294967295;
                    else
                        ALUout = A / B;
                end
            `ALU_REM: // remainder
                begin
                    if(B == 32'b0)
                        ALUout = A;
                    else
                        begin
                            if(A == -32'd2147483648 && B == -32'd1)
                                ALUout = 32'b0;
                            else 
                                ALUout = $signed(A) % $signed(B);
                        end
                end
            `ALU_REMU: // gets the remainder of two unsigned operands while taking into account the exceptions
                begin
                    if(B == 32'b0)
                        ALUout = A;
                    else
                        ALUout = A % B;
                end
        endcase
    end
    

endmodule
