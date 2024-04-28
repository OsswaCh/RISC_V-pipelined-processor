/*******************************************************************
*
* Module: RCA
* Project: RISC-V processor
* Author: ripple carry adder that takes two inputs of size n
* Description:represent the Processor's register file 
*
* Change history: created in lab 2 & updated in lab 6 to work with the negative edge of the clock 
*
**********************************************************************/

`include "fullAdder.v"


module RCA#(parameter N=32)(
  input [N-1:0] A,B,
  output [N-1:0] sum,
  output cout, 
output err

    );

  assign err = (A[N-1] != B[N-1])? 1'b0:
    (A[N-1] == sum[N-1])? 1'b0: 1'b1;
  wire [N:0]Cin;
    genvar i;
    assign Cin[0]=1'b0;
    generate 
      for (i=0; i<N; i=i+1) begin        
        FullAdder FA(.A(A[i]), .B(B[i]),.Cin(Cin[i]), .sum(sum[i]), .Cout (Cin[i+1]));
       end 
    endgenerate
  assign Cout = Cin[N];
       
        
endmodule