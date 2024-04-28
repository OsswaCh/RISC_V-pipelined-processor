module regFile #(parameter n=5) (
    input rst, clk,
    input RegWrite,
    input [2:0] inst,
    input [31:0] data,
    input [n-1:0] read1, read2, write,
    output [31:0] r1, r2
);

    reg [31:0] x[31:0];
    integer i;

    assign r1 = x[read1];
    assign r2 = x[read2];

    always @(negedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                x[i] = 0;
            end
        end else if (RegWrite) begin
            if (write != 5'd0) begin
                case (inst)
                    3'b010: x[write] = data; // Standard write operation
                    3'b000: x[write] = {{24{data[7]}}, data[7:0]}; // LB: Load byte with sign extension
                    3'b001: x[write] = {{16{data[15]}}, data[15:0]}; // LH: Load halfword with sign extension
                    3'b100: x[write] = {24'b0, data[7:0]}; // LBU: Load byte unsigned
                    3'b101: x[write] = {16'b0, data[15:0]}; // LHU: Load halfword unsigned
                endcase
            end
        end
    end

endmodule