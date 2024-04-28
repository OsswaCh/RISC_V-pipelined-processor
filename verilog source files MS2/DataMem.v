module DataMem (
    input clk,
    input MemRead,
    input MemWrite,
    input [2:0] inst,
    input [4:0] addr,
    input [31:0] data_in,
    output reg [31:0] data_out
);

    reg [31:0] mem [0:63];

    always @(posedge clk) begin
        if (MemWrite) begin
            case (inst)
                3'b010: mem[addr] <= data_in;
                3'b000: mem[addr] <= {24'b0, data_in[7:0]};
                3'b001: mem[addr] <= {16'b0, data_in[15:0]};
                default: mem[addr] <= data_in; // Default assignment if inst is not matched
            endcase
        end
    end

    always @(*) begin
        if (MemRead) begin
            data_out = mem[addr];
        end
    end

    // Initial values for memory
    initial begin 
        mem[0] = 32'd17;
        mem[1] = 32'd9;
        mem[2] = 32'd25;
    end

endmodule
