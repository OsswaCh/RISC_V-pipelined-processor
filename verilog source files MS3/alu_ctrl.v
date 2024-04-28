/*******************************************************************
*
* Module: alu_ctrl
* Project: RISC-V processor
* Author: ousswa chouchane 
* Description: takes in the the ALUop and function 3 and one bit from function 7 and output the appropriate selection for the alu operation 
* - updated to support all 40+ instructions of the ALU (I,S,R,M, and LUI and AUIPC)
*
* Change history: created in the lab
*
**********************************************************************/

`include "defines.v"


module alu_ctrl(
  input [2:0] ALUOp, 
  input [31:0] inst,
  output reg [4:0] ALU_selection
    );
  
  
      always @(*)
    begin
    case(ALUOp)

    3'b000: // ALL I and S format istructions
        begin
            case(inst[14:12])
                3'b000:
                    ALU_selection = `ALU_ADD;
                3'b001:
                if(inst[5:4]==2'b01)
                    ALU_selection = `ALU_SLL;
                else
                    ALU_selection = `ALU_ADD;
                   
                3'b010:
                begin
                    if(inst[5:4]==2'b01)
                        ALU_selection = `ALU_SLT;
                    else
                        ALU_selection = `ALU_ADD;
                end
                3'b011:
                    ALU_selection = `ALU_SLTU;
                3'b100:
                begin
                    if(inst[5:4]==2'b00)
                        ALU_selection = `ALU_ADD;
                    else
                        ALU_selection = `ALU_XOR;
                end
                3'b101:
                if(inst[5:4]==2'b00)
                    ALU_selection = `ALU_ADD;
                else if(inst[30]==0)
                    ALU_selection = `ALU_SRL;
                else
                    ALU_selection = `ALU_SRAI;

                3'b110:
                    ALU_selection = `ALU_OR;
                3'b111:
                    ALU_selection = `ALU_AND;
                default:
                    ALU_selection = 5'b00000;
        endcase
        end
    
    3'b001: // all branch and jal statements
        begin
            ALU_selection = `ALU_SUB;
        end   
    
    3'b010: // R-format functions
        begin
        case(inst[14:12])

            3'b000:
            begin
                if(inst[30] == 1)
                    ALU_selection = `ALU_SUB;
                else if(inst[30] == 0)
                    ALU_selection = `ALU_ADD;
            end

            3'b001:
                ALU_selection = `ALU_SLL;

            3'b010:
                ALU_selection = `ALU_SLT;

            3'b011:
                ALU_selection = `ALU_SLTU;

            3'b100:
                ALU_selection = `ALU_XOR;

            3'b101:
            begin
                if (inst[30])
                    ALU_selection = `ALU_SRA;
                else
                    ALU_selection = `ALU_SRL;
            end

            3'b110:
                ALU_selection = `ALU_OR;

            3'b111: 
                ALU_selection = `ALU_AND;
            default:
                    ALU_selection = 5'b00000;    
        endcase     
        end

    3'b011: // LUI and AUIPC
      ALU_selection = `ALU_PASS;
    3'b100: //M-type instructions (Division and Multiplication)
        begin
            case (inst[14:12])
                `F3_MUL: 
                    ALU_selection = `ALU_MUL;
                `F3_MULH: 
                    ALU_selection = `ALU_MULH;
                `F3_MULHSU: 
                    ALU_selection = `ALU_MULHSU;
                `F3_MULHU: 
                    ALU_selection = `ALU_MULHU;
                `F3_DIV: 
                    ALU_selection = `ALU_DIV;
                `F3_DIVU: 
                    ALU_selection = `ALU_DIVU;
                `F3_REM: 
                    ALU_selection = `ALU_REM;
                `F3_REMU: 
                    ALU_selection = `ALU_REMU;
                default:
                    ALU_selection = 5'b00000;
            endcase
        end
    default: ALU_selection = `ALU_ADD;
    endcase          
    end
  
  
  
endmodule