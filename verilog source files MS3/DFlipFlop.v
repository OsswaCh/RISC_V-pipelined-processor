/*******************************************************************
*
* Module: DFlipFlop 
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: normal dflipflop that takes a 1-bit input D and assigns it to the the 1-bit output Q
*
* Change history: created in the lab
*
**********************************************************************/
`include "defines.v"


module DFlipFlop(
  input clk, 
  input rst, 
  input D, 
  output reg Q
);
  
  always @ (posedge clk or posedge rst) 
    if (rst) begin
	    Q <= `ZERO;
    end else begin 
    	Q <= D;
  end 
endmodule