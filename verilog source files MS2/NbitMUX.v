`include "MUX2x1.v"


module NbitMUX#(parameter n=4)(
    input [n-1:0]A,
    input [n-1:0]B,
    input sel,
    output [n-1:0]out
    );
    
    genvar i;                                                            
    for (i=0; i<n; i=i+1) begin                                          
       MUX2x1 mux (.A(A[i]), .B(B[i]), .sel(sel),.out(out[i]));
    end                                                                  
endmodule

