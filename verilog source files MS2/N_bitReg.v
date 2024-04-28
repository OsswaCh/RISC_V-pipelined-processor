`timescale 1ns / 1ps
`include "DFlipFlop.v"

module N_bitReg#(parameter n =8)(

input [n-1:0]D,
input clk,
input rst,
input load,
output  [n-1:0]Q


    );
   
    

    wire [n-1:0] inp;
    
    assign inp=load? D:Q;
    
    genvar i;
    for (i=0; i<n; i=i+1) begin 
         DFlipFlop DFF(.clk(clk), .rst(rst), .D(inp[i]), .Q(Q[i]));
    end 
    
endmodule
