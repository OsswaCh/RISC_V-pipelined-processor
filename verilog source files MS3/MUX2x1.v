/*******************************************************************
*
* Module: MUX2x1
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: 1 bit 2x1 mux 
*
* Change history: created in lab 3
*
**********************************************************************/


module MUX2x1(
    input A,
    input B,
    input sel,
    output out
    );
    
    assign out = sel?A:B;

    
endmodule
