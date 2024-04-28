/*******************************************************************
*
* Module: Forwarding_Unit
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: detects the need for forwarding to avoid using wrong data
*
* Change history: created in lab 8
*
**********************************************************************/
`include "defines.v"


module Forwarding_Unit(

input [4:0] ID_EX_RegisterRs1,
input [4:0] ID_EX_RegisterRs2,
input  MEM_WB_RegWrite,
input  EX_MEM_RegWrite,
input [4:0] MEM_WB_RegisterRd,
input [4:0] EX_MEM_RegisterRd,
output reg [1:0] forwardA_ALU,
output reg [1:0] forwardB_ALU

    );
    always@(*) 
        // Forwarding to ALU
        begin
          
                //EX hazards
          if((EX_MEM_RegisterRd != `ZERO)&& (EX_MEM_RegWrite) && (EX_MEM_RegisterRd==ID_EX_RegisterRs1)) begin 
               forwardA_ALU = 2'b10;
          end
          else if ((MEM_WB_RegWrite && (MEM_WB_RegisterRd != `ZERO))
               &&(MEM_WB_RegisterRd == ID_EX_RegisterRs1)&& !((EX_MEM_RegisterRd != `ZERO)& (EX_MEM_RegWrite)&& (EX_MEM_RegisterRd==ID_EX_RegisterRs1)))
                    forwardA_ALU = 2'b01;
          
          else forwardA_ALU = `ZERO;
          
          if ((EX_MEM_RegisterRd != 0)&& (EX_MEM_RegWrite)&& (EX_MEM_RegisterRd==ID_EX_RegisterRs2)) begin 
              forwardB_ALU = 2'b10; 
          end
          else if ( MEM_WB_RegWrite && (MEM_WB_RegisterRd != `ZERO)
                &&(MEM_WB_RegisterRd == ID_EX_RegisterRs2)&& !((EX_MEM_RegisterRd != `ZERO)& (EX_MEM_RegWrite)&& (EX_MEM_RegisterRd==ID_EX_RegisterRs2)))
                     forwardB_ALU = `ONE; 
          else forwardB_ALU = `ZERO;
        end
          
        
endmodule
