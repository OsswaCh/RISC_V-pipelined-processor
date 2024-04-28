

module ctrl_unit(
     input [4:0] inst,
     output reg Branch ,reg MemRead ,reg MemtoReg,reg MemWrite,reg ALUSrc,reg RegWrite, reg lui,
     output reg [1:0] ALUOp
    );
    
    always @(*) begin
    
    case(inst)
    
      //R instructions
    5'b01100: begin 
    Branch=1'b0 ;MemRead=1'b0 ;MemtoReg=1'b0; MemWrite=1'b0; ALUSrc=1'b0; RegWrite=1'b1;ALUOp=2'b10;lui=0;
    end
      // load instructions
    5'b00000 : begin 
        Branch=1'b0 ;MemRead=1'b1 ;MemtoReg=1'b1; MemWrite=1'b0; ALUSrc=1'b1; RegWrite=1'b1;ALUOp=2'b00;lui=0;

    end 
      //store instructions
     5'b01000 : begin 
        Branch=1'b0 ;MemRead=1'b0 ;MemtoReg=1'b0; MemWrite=1'b1; ALUSrc=1'b1; RegWrite=1'b0;ALUOp=2'b00;lui=0;

    end 
      //branch instructions
     5'b11000 : begin 
        Branch=1'b1 ;MemRead=1'b0 ;MemtoReg=1'b0; MemWrite=1'b0;ALUSrc=1'b0; RegWrite=1'b0;ALUOp=2'b01;lui=0;

    end 
      
      //I instructions
      5'b00100 : begin 
        Branch=1'b0 ;MemRead=1'b1 ;MemtoReg=1'b0; MemWrite=1'b0; ALUSrc=1'b1; RegWrite=1'b1;ALUOp=2'b11;lui=0;

    end
      
      //LUI
      5'b01101 : begin 
        Branch=1'b0 ;MemRead=1'b0 ;MemtoReg=1'b0; MemWrite=1'b0; ALUSrc=1'b1; RegWrite=1'b1;ALUOp=2'b11;lui=1;

    end
      
       //auipc
      5'b00101 : begin 
        Branch=1'b0 ;MemRead=1'b0 ;MemtoReg=1'b0; MemWrite=1'b0; ALUSrc=1'b1; RegWrite=1'b1;ALUOp=2'b10;lui=1;

    end
    
    endcase 
    
    end
    
    
endmodule
