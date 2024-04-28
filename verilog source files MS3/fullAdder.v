/*******************************************************************
*
* Module: FullAdder 
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: adds 2  1-bit integers
*
* Change history: created in the lab
*
**********************************************************************/

module FullAdder(
    input A,
    input B,
    input Cin,
    output sum,
    output Cout
    );
   assign {Cout,sum}=A+B+Cin;
   
endmodule