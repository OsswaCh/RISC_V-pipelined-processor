`timescale 1ns / 1ps


module MUX2x1(
    input A,
    input B,
    input sel,
    output out
    );
    
    assign out = sel?A:B;

    
endmodule
