module FullAdder(
    input A,
    input B,
    input Cin,
    output sum,
    output Cout
    );
   assign {Cout,sum}=A+B+Cin;
   
endmodule