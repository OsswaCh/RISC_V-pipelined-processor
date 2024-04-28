`include "defines.v"

module DecompUnit(input reset,input clk,input  [31:0] inst,
output reg [31:0] instOut,
output reg  compress
);
    always@(*)
    begin
      if(reset)
        begin
          instOut = 32'd0;
          compress = `ZERO;
        end 
            
    else if(~clk)
    begin
        instOut = inst;
        
    end
    else if(inst[1:0] == 2'b11)
            begin
              compress =1'b0; 
              instOut = inst;
            end
    else
    begin
      if({inst[15:13],inst[1:0]} == 5'b11000)
            begin
              instOut = {{5{inst[5]}},inst[5], inst[12],2'b00, inst[4:2],2'b00, inst[9:7],3'b010, inst[11:10],inst[6],9'b000100011};
              compress = 1'b1;
            end
            
        else if({inst[15:13],inst[1:0]} == 5'b01000)
            begin
              instOut = {{5{inst[5]}}, inst[5], inst[12:10], inst[6], 4'b0000, inst[9:7],5'b01000, inst[4:2],7'b0000011};
                compress = 1'b1;
            end
            
        else if({inst[15:13],inst[1:0]} == 5'b00101)
            begin
           instOut = {inst[8],inst[8], inst[10:9], inst[6], inst[7], inst[2], inst[11], inst[5:3], inst[12],{8{inst[8]}}, 12'b000011101111};
                compress = 1'b1;
            end
            
        else if({inst[15:13],inst[1:0]} == 5'b00001)
            begin
              instOut = {{6{inst[12]}},inst[12],inst[6:2],inst[11:7],3'b000,inst[11:7],7'b0010011};
                compress = 1'b1;
    
              
            end 
        
        else if({inst[15:13],inst[1:0]} == 5'b01101)
            begin
           instOut = {{15{inst[12]}}, inst[12], inst[6:2], inst[11:7], 7'b0110111};
                compress = 1'b1;
    
              
            end
        else if({inst[15:13],inst[1:0]} == 5'b10001)
        begin
        case(inst[11:10])
            2'b00:
                begin
                  instOut = {inst[11:10],7'b0,inst[6:2], 2'b00, inst[9:7], 5'b10100, inst[9:7], 7'b0010011 };
                    compress = 1'b1;
                end 
            2'b01:
                begin
                  instOut = {inst[11:10],5'b0,inst[6:2], 2'b00, inst[9:7], 5'b10100, inst[9:7], 7'b0010011 };
                    compress = 1'b1;
    
                
               end
            2'b10:
               begin
                 instOut = {{6{inst[12]}},inst[12],inst[6:2], 2'b00, inst[9:7], 5'b11100, inst[9:7], 7'b0010011 };
                    compress = 1'b1;
    
                end
            2'b11:
              begin
                case(inst[6:5])
                    2'b00:
                        begin
                          instOut = {9'b010000000, inst[4:2], 2'b00, inst[9:7], 5'b00000, inst[9:7], 7'b0110011};
                            compress = 1'b1;
    
                        end
                    2'b01:
                        begin
                          instOut = {9'b000000000, inst[4:2], 2'b00, inst[9:7], 5'b10000, inst[9:7], 7'b0110011};
                            compress = 1'b1;
    
                        end
                    2'b10:
                        begin
                          instOut = {9'b000000000, inst[4:2], 2'b00, inst[9:7], 5'b11000, inst[9:7], 7'b0110011};
                            compress = 1'b1;
    
                        end     
                    2'b11:
                        begin
                          instOut = {9'b000000000, inst[4:2], 2'b00, inst[9:7], 5'b11100, inst[9:7], 7'b0110011};
                            compress = 1'b1;
    
                        end  
                    default:
                        begin
                        instOut = `ZERO;
                        end
                endcase
                      end 
                default:
                    begin
                    instOut = 0;
                    end 
            endcase
    end
    else if({inst[15:13],inst[1:0]} == 5'b00010)
    begin
    instOut = {7'b0000000, inst[12], inst[6:2], inst[11:7], 3'b001, inst[11:7], 7'b0010011};
        compress = 1'b1;

    end
   
    else if({inst[15:13],inst[1:0]} == 5'b10010)
    begin
    if(inst[11:2] == 0)
        begin
        instOut = 32'b00000000000100000000000001110011;
        compress = 1'b1;
        end
    else if (inst[6:2] == 0)
        begin
          instOut = {12'b000000000000, inst[11:7], 15'b000000011100111};
        compress = 1'b1;
        end
    else
        begin
      instOut = {7'b0000000, inst[6:2], inst[11:7], 3'b111,inst[11:7], 7'b0110011};
        compress = 1'b1;
        end
    end
    else
        begin
      instOut = 0;
        end 
    end
    end

endmodule