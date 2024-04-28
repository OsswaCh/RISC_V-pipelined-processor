

`include "shifter.v"
`include "RCA.v"

module NbitALU#(parameter N=32)(
    input [3:0] sel,
    input [N-1:0] A, B,
  	input [4:0] shamt,
  	input typ, lui,
    output reg [N-1:0] ALUout,
    output wire cf, zf, vf, sf /* flags: cf=carry flag, zf = zero flag, vf = overflow flag, sf = sign flag  */
);

    wire [N-1:0] add, sub, op_b; // op_b = ~B
    wire ERR1, ERR2;
    wire cfa, cfs; // carry flag add, carry flag sub
  	wire[31:0] sh;
  reg [1:0] typ_in; // type of the shifter
  
  	//choosign the right shfitng for the I instructions
  
  always @(*)
    case({sel,typ,lui})
      6'b010000 : typ_in = 00;
      6'b010100 : typ_in = 01;
      6'b010110 : typ_in = 10;
      6'b010111 : typ_in = 11;
      default: typ_in = 00;
    endcase
  
  shifter shifter0(.a(A), .shamt(shamt), .typ(typ_in),  .r(sh));

    assign op_b = (~B);
    assign {cf, add} = sel[2] ? (A + op_b + 1'b1) : (A + B); // add or sub
    assign zf = (add == 0);
    assign sf = add[N-1];
    assign vf = (A[N-1] ^ (op_b[N-1]) ^ add[N-1] ^ cf);

    always @(*)
    case (sel)
        4'b0010: begin
            ALUout = add;
        end
        4'b0110: begin 
            ALUout = add;
        end
        4'b0000: ALUout = A & B;
        4'b0001: ALUout = A | B;
        4'b0011: ALUout = {A[N-2:0], 1'b0}; // Logical left shift
      	4'b0100: ALUout = sh;
      	4'b0101: ALUout = sh;
        4'b0111: ALUout = {31'b0, (sf != vf)}; // Set less than
        4'b1111: ALUout = {31'b0, (~cf)}; // Set carry flag
        4'b1001: ALUout = A ^ B; // XOR
        4'b1000: ALUout = {1'b0, A[N-1:1]}; // Logical right shift
        4'b1100: ALUout = ($signed(A)) >>> B[4:0]; // SRA
      	4'b0100: ALUout = sh; //shift functions arithmatic
      	4'b1010: ALUout = sh; //lui
      
        default: ALUout = {N{1'b0}};
    endcase

    assign ZeroFlag = (ALUout == 0);

endmodule