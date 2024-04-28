/*******************************************************************
*
* Module: Forwarding_Unit
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description:represent the Processor's register file 
*
* Change history: created in lab 2 & updated in lab 6 to work with the negative edge of the clock 
*
**********************************************************************/

module regFile #(parameter N=5) (
input rst,clk,
input  RegWrite,
input [31:0]data,
  input [N-1:0] read1,read2,write,
output [31:0]r1,r2
    );
    
  reg[31:0] x[31:0];
    assign r1 = x[read1];
    assign r2 = x[read2];
    integer i;

  always @ (negedge clk or posedge rst) begin
    
    if (rst==1)begin 
    for (i=0; i<32; i=i+1)begin
    x[i]=0;
    end
    end
    else begin 
    if (RegWrite==1)begin
     if(write == 5'd0) begin
        x[write] = 0;
      end else begin
    x[write]= data;
      end
    end
    end
    
    end
    
endmodule

