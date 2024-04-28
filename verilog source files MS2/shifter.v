module shifter(
    input wire [31:0] a,
    input wire [4:0] shamt,
    input wire [1:0] typ,
    output reg [31:0] r
);

always @* begin
    case(typ)
        2'b00: r = a << shamt; // Logical Left Shift
        2'b01: r = a >> shamt; // Logical Right Shift
        2'b10: r = $signed(a) >>> shamt; // Arithmetic Right Shift (with sign extension)
        2'b11: r = {16'b0, a[31:16]}; // LUI: Load Upper Immediate (Extract upper 16 bits)

        default: r = a; // No shift (default behavior)
    endcase
end

endmodule