/*******************************************************************
*
* Module: Branch_Unit
* Project: RISC-V processor
* Author: ousswa chouchane & michael henin 
* Description: determines the branching outcomes
*
* Change history: 
- added to the new pipelined impelmentation
- changed the cases to their defines equivient
*
**********************************************************************/
`include "defines.v"

module Branch_Unit(
  input [2:0]inst, ////Instruction[12:14]
  input Branch,
  input jump, 
  input cf, zf, vf, sf,
  output reg [1:0]flag //made it 2 bits to accomodate for the jumping
);
  
  always @* begin
    
    if(Branch == `ONE) begin
        if(jump) flag = 2'b01;
        else
        case(inst)
        `BR_BEQ: begin
        flag = {1'b0,zf & Branch}; // BEQ
            end
            `BR_BNE: begin
            flag = {1'b0,~(zf) & Branch}; // BNE
            end
            `BR_BLT: begin
            flag = {1'b0,(sf != vf) & Branch}; // BLT
            end
            `BR_BGE: begin
            flag = {1'b0,(sf == vf) & Branch}; // BGE
            end
            `BR_BLTU: begin
            flag = {1'b0,~cf & Branch}; // BLTU
            end
            `BR_BGEU: begin
            flag = {1'b0,cf & Branch}; // BGEU
            end
            default: begin
            flag = 2'b0; // Default case to handle unexpected values
            end
        endcase
    end
    else begin
        flag = (jump)? 2'b10: 2'b00; // if not branching, then jump
    end
    
    
    
end
  
endmodule