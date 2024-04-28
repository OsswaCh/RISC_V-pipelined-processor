/*******************************************************************
*
* Module: N_bitReg
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: register of size n made out of Dflipflops
*
* Change history: created in lab 4
*
**********************************************************************/

`include "DFlipFlop.v"

module N_bitReg#(parameter N =8)(

  input [N-1:0]D,
  input clk,
  input rst,
  input load,
  output  [N-1:0]Q


    );
   
    

  wire [N-1:0] inp;
    
  assign inp=load? D:Q;
    
  genvar i;
  for (i=0; i<N; i=i+1) begin 
         DFlipFlop DFF(.clk(clk), .rst(rst), .D(inp[i]), .Q(Q[i]));
  end 
    
endmodule
