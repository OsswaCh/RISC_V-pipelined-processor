/*******************************************************************
*
* Module: nBitShifter
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: shifts an input x of size n 1 bit to the left
*
* Change history: created in lab 3
*
**********************************************************************/

module nBitShifter#(parameter N = 8)(
  input [N-1:0] x,
  output [N-1: 0] y
    );
    
  assign y = {x[N-2:0], 1'b0};
endmodule
