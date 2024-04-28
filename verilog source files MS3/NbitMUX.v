/*******************************************************************
*
* Module: NbitMUX
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: 2x1 multiplexer of two input A and B of size n each
*
* Change history: created in lab 3
*
**********************************************************************/


`include "MUX2x1.v"


module NbitMUX#(parameter N=4)(
  input [N-1:0]A,
  input [N-1:0]B,
  input sel,
  output [N-1:0]out
    );
    
    genvar i;                                                            
  for (i=0; i<N; i=i+1) begin                                          
       MUX2x1 mux (.A(A[i]), .B(B[i]), .sel(sel),.out(out[i]));
    end                                                                  
endmodule

