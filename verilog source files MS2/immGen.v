`include "defines.v"

module immGen(
    output reg [31:0] gen_out,
  input  [31:0] IR
    );
    always @(*) begin
	case (`OPCODE)
		`OPCODE_Arith_I   : 	gen_out = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		`OPCODE_Store     :     gen_out = { {21{IR[31]}}, IR[30:25], IR[11:8], IR[7] };
		`OPCODE_LUI       :     gen_out = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		`OPCODE_AUIPC     :     gen_out = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		`OPCODE_JAL       : 	gen_out = { {12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21], 1'b0 };
		`OPCODE_JALR      : 	gen_out = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		`OPCODE_Branch    : 	gen_out = { {20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
		default           : 	gen_out = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; // IMM_I
	endcase 
end
endmodule
