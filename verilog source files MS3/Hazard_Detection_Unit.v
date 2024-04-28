/*******************************************************************
*
* Module: Hazard_Detection_Unit
* Project: RISC-V processor
* Author: ousswa chouchane 
* Description: detects load use hazards and output stall as a flag to the processor that it should stall for 1 cycle 
*
* Change history: created in lab 8
*
**********************************************************************/
`include "defines.v"

module Hazard_Detection_Unit(
  input[4:0] IF_ID_RegisterRs1, 
  input[4:0] IF_ID_RegisterRs2, 
  input[4:0] ID_EX_RegisterRd, 
  input ID_EX_MemRead, 
  output reg stall
);

always @(*)
begin
  if (((IF_ID_RegisterRs1 == ID_EX_RegisterRd) | (IF_ID_RegisterRs2 == ID_EX_RegisterRd) ) & ID_EX_MemRead & (ID_EX_RegisterRd != 0))
    begin
      stall = `ONE;
    end
  else stall = `ZERO;
end

  
  
endmodule 