/*******************************************************************
*
* Module: BCD
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: made for the fpga implementation, takes in a 12 bit signed number and outputs its digits
*
* Change history: created in the lab
*
**********************************************************************/

module BCD(
input [12:0] num,

output reg [3:0] Hundreds,
output reg [3:0] Tens,
output reg [3:0] Ones
);
wire [7:0] unsigned_num = (num[7])? ~num + 1 : num;

 
integer i; 
always @(unsigned_num) 
begin 
//initialization 
 Hundreds = 4'd0; 
 Tens = 4'd0; 
 Ones = 4'd0; 
for (i = 6; i >= 0 ; i = i-1 ) 
begin 
if(Hundreds >= 5 ) 
 Hundreds = Hundreds + 3; 
if (Tens >= 5 ) 
 Tens = Tens + 3; 
 if (Ones >= 5) 
 Ones = Ones +3;
  
//shift left one 
 Hundreds = Hundreds << 1; 
 Hundreds [0] = Tens [3]; 
 Tens = Tens << 1; 
 Tens [0] = Ones[3]; 
 Ones = Ones << 1; 
 Ones[0] = unsigned_num[i]; 
end 
end 
endmodule 

