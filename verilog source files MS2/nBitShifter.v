module nBitShifter#(parameter n = 8)(
input [n-1:0] x,
output [n-1: 0] y
    );
    
    assign y = {x[n-2:0], 1'b0};
endmodule
