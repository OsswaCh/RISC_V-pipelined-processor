/*******************************************************************
*
* Module: ctrl_unit
* Project: RISC-V processor
* Author: ousswa chouchane  
* Description: takes in the control signals and extracts the control signals
*
* Change history: created in the lab
*
**********************************************************************/

`include "defines.v"


//added reset
//made intruction 32 bits
//added jump and signed inst
//didnt add pc_en because we have stall
//alu op is now 3 bits


module ctrl_unit(
  input rst, 
  input [31:0] inst,
  output reg Branch,
  output reg jump,
  output reg MemRead ,
  output reg MemtoReg,
  output reg MemWrite,
  output reg ALUSrc,
  output reg RegWrite,
  output reg signed_inst,
  output reg PC_en,
  output reg [1:0] RF_MUX_sel, //what data to write back in the reg
  output reg [1:0] AU_inst_sel,  //determines the type of store and laod from the memory
  output reg [2:0] ALUOp
    );
  
  always @(*) begin
    
    if(rst) 
    begin
      Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; MemWrite = `ZERO; RegWrite = `ZERO;
      ALUSrc = `ZERO; 
      signed_inst = `ZERO; PC_en = `ZERO;
      AU_inst_sel = `ZERO; RF_MUX_sel = `ZERO; ALUOp = `ZERO; 
    end
    
    else
    if(inst != 32'b0)
        begin
            case(inst[6:2]) //inst[6:2]
                `OPCODE_Arith_R_M : //R and M types --> determined by function 7  
                    begin
                        PC_en = 1'b1;
                        if (inst[31:25] == `F7_M) //M-Type instructions
                            begin
                              case (inst[14:12]) //function 3
                                    `F3_MUL :
                                        begin
                                            Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b100; MemWrite = `ZERO; ALUSrc = `ZERO;
                                            RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_MULH :
                                        begin
                                            Branch = `ZERO;jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b100; MemWrite = `ZERO; ALUSrc = `ZERO;
                                            RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_MULHSU :
                                        begin
                                            Branch = `ZERO;jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b100; MemWrite = `ZERO; ALUSrc = `ZERO;
                                            RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_MULHU :
                                        begin
                                            Branch = `ZERO;jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b100; MemWrite = `ZERO; ALUSrc = `ZERO;
                                            RegWrite = `ONE; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_DIV :
                                        begin
                                            Branch = `ZERO;jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b100; MemWrite = `ZERO; ALUSrc = `ZERO;
                                            RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_DIVU :
                                        begin
                                            Branch = `ZERO;jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b100; MemWrite = `ZERO; ALUSrc = `ZERO;
                                            RegWrite = `ONE; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_REM :
                                        begin
                                            Branch = `ZERO;jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b100; MemWrite = `ZERO; ALUSrc = `ZERO;
                                            RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_REMU :
                                        begin
                                            Branch = `ZERO;jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b100; MemWrite = `ZERO; ALUSrc = `ZERO;
                                            RegWrite = `ONE; signed_inst = `ZERO; AU_inst_sel =`ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end                             
                                    default: 
                                        begin
                                            Branch = `ZERO;jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO;
                                            RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                endcase
                            end
                    
                      else //R instructions
                            begin
                              case(inst[14:12]) //function 3
                                    `F3_ADD_SUB : //they share the same f3
                                        begin
                                          case (inst[31:25]) //function 7
                                                `F7_ADD :
                                                    begin
                                                        Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                                        ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                                        RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                                        RF_MUX_sel = `ZERO;
                                                    end 
                                                `F7_SUB :
                                                    begin
                                                        Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                                        ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                                        RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                                        RF_MUX_sel = `ZERO;
                                                    end
                                                default : 
                                                    begin
                                                        Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                                        ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                                        RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                                        RF_MUX_sel = `ZERO;
                                                    end      
                                            endcase
                                        end
                                    `F3_SLL :
                                        begin
                                            Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                            RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end 
                                    `F3_SLT :
                                        begin
                                            Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                            RegWrite = `ONE; signed_inst = 1; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_SLTU :
                                        begin
                                            Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                            RegWrite = `ONE; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_XOR :
                                        begin
                                            Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                            RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_SRL_SRA : //Function 3 of SRL and SRA instructions is the same
                                        begin
                                            case (inst[31:25]) //Instuction[31:25]
                                                `F7_SRL : 
                                                    begin
                                                        Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                                        ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                                        RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                                        RF_MUX_sel = `ZERO;
                                                    end
                                                `F7_SRA : 
                                                    begin
                                                        Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                                        ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                                        RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                                        RF_MUX_sel = `ZERO;
                                                    end
                                                default : 
                                                    begin
                                                        Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                                        ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                                        RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                                        RF_MUX_sel = `ZERO;
                                                    end
                                            endcase
                                        end
                                    `F3_OR :
                                        begin
                                            Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                            RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    `F3_AND :
                                        begin
                                            Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                            RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                    default : 
                                        begin
                                            Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
											ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                            RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                        end
                                endcase
                            end
                    end
                   `OPCODE_Load : //loads
                    begin
                        PC_en = `ONE;
                      case(inst[14:12]) //funcgtion 3
                            `F3_LB :
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ONE; MemtoReg = `ONE; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = 2'b10;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_LH : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ONE; MemtoReg = `ONE; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ONE;     
                                    RF_MUX_sel = `ZERO;               
                                end
                            `F3_LW :
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ONE; MemtoReg = `ONE; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_LBU: 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ONE; MemtoReg = `ONE; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ZERO; AU_inst_sel = 2'b10;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_LHU :
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ONE; MemtoReg = `ONE; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ZERO; AU_inst_sel = `ONE;
                                    RF_MUX_sel = `ZERO;
                                end
                            default : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
									ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                    RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                        endcase
                    end
                      `OPCODE_Store : //stores
                    begin
                        PC_en = 1'b1;
                      case(inst[14:12]) //function 3
                            `F3_SB : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ONE; ALUSrc = `ONE; 
                                    RegWrite = `ZERO;  signed_inst = `ONE; AU_inst_sel = 2'b10;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_SH : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ONE; ALUSrc = `ONE; 
                                    RegWrite = `ZERO;  signed_inst = 1; AU_inst_sel = `ONE;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_SW :
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ONE; ALUSrc = `ONE; 
                                    RegWrite = `ZERO;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            default : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
									ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                    RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                        endcase
                    end
                      `OPCODE_Arith_I : //I instructions
                    begin
                        PC_en = 1'b1;
                      case(inst[14:12]) //function 3
                            `F3_ADDI :
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_SLTI :
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_SLTIU : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_XORI : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_ORI :
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_ANDI : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_SLLI :
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                    RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `F3_SRAI_SRLI : //Function 3 for SRAI and SRLI is the same
                                begin
                                    case (inst[31:25]) //Instruction [31:25]
                                        `F7_SRAI :
                                            begin
                                                Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                                ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                                RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                                RF_MUX_sel = `ZERO;
                                            end 
                                        `F7_SRLI :
                                            begin
                                                Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                                ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                                                RegWrite = `ONE;  signed_inst = `ONE; AU_inst_sel = `ZERO;
                                                RF_MUX_sel = `ZERO;
                                            end
                                        default : 
                                            begin
                                            Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                            ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                            RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                            RF_MUX_sel = `ZERO;
                                            end
                                    endcase
                                end
                            default : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                    RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end    
                        endcase
                    end
                      `OPCODE_Branch : //braches
                    begin
                        PC_en = 1'b1;
                      case(inst[14:12]) //function 3
                            `BR_BEQ : 
                                begin
                                    Branch = `ONE; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO;
                                    ALUOp = `ONE; MemWrite = `ZERO; ALUSrc = `ZERO;
                                    RegWrite = `ZERO; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `BR_BNE :
                                begin
                                    Branch = `ONE; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ONE; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                    RegWrite = `ZERO; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `BR_BLT :
                                begin
                                    Branch = `ONE; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ONE; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                    RegWrite = `ZERO; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `BR_BGE :
                                begin
                                    Branch = `ONE; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ONE; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                    RegWrite = `ZERO; signed_inst = `ONE; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `BR_BLTU :
                                begin
                                    Branch = `ONE; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ONE; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                    RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            `BR_BGEU : 
                                begin
                                    Branch = `ONE; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ONE; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                    RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                            default : 
                                begin
                                    Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                                    ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                                    RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                                    RF_MUX_sel = `ZERO;
                                end
                        endcase
                    end
                      //other non groupped 
                      `OPCODE_SYSTEM:
                          begin
                              Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                              ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                              RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                              RF_MUX_sel = `ZERO;
                          end
                      `OPCODE_FENCE:
                          begin
                             Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                             ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
                             RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
                             RF_MUX_sel = `ZERO;
                          end
                      `OPCODE_LUI : // loads the highest 16 bits of a register with a constant, and clears the lowest 16 bits to 0s
                          begin
                              Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO;
                              ALUOp = 3'b011; MemWrite = `ZERO; ALUSrc = `ONE; 
                              RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                              RF_MUX_sel = `ZERO; PC_en = `ONE;
                          end
                      `OPCODE_AUIPC :
                          begin
                              Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
                              ALUOp = 3'b010; MemWrite = `ZERO; ALUSrc = `ONE;
                              RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                              RF_MUX_sel = `ONE; PC_en = `ONE;
                          end
                      `OPCODE_JAL : 
                          begin
                              Branch = `ONE; jump = `ONE; MemRead = `ZERO; MemtoReg = `ZERO; 
                              ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE; 
                              RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                              RF_MUX_sel = 2'b10; PC_en = `ONE;
                          end
                      `OPCODE_JALR : 
                          begin
                              Branch = `ZERO; jump = `ONE; MemRead = `ZERO; MemtoReg = `ZERO;
                              ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ONE;
                              RegWrite = `ONE; signed_inst = `ONE; AU_inst_sel = `ZERO;
                              RF_MUX_sel = 2'b10; PC_en = `ONE;
                          end 
            endcase
     end
     else
    begin
        Branch = `ZERO; jump = `ZERO; MemRead = `ZERO; MemtoReg = `ZERO; 
        ALUOp = `ZERO; MemWrite = `ZERO; ALUSrc = `ZERO; 
        RegWrite = `ZERO; signed_inst = `ZERO; AU_inst_sel = `ZERO;
        RF_MUX_sel = `ZERO;
    end
    
    
    end

    
  
  
endmodule 
