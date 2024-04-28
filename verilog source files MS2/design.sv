`include "N_bitReg.v"
`include "InstMem.v"
`include "regFile.v"
`include "immGen.v"
`include "NbitMUX.v"
`include "NbitALU.v"
`include "DataMem.v"
`include "ctrl_unit.v"
`include "nBitShifter.v"
`include "alu_ctrl.v"
`include "Branch_Unit.v"



module top(input clk, rst);

 wire [31:0] PC_in, PC_out, inst_out, imm_gen_out, alu_out, data_mem_out, Write_data, PC_inc, pc_branch,read1, read2, shift_out, alu_in_mux;
wire [4:0] read1addr, read2addr, write_addr;
wire cf, zf, vf, sf, err, Branch , MemRead , MemtoReg, MemWrite, RegWrite, ALUSrc, s, v, c;
  wire [3:0] alusel;
wire [1:0] ALUOp;
  wire lui; 

  RCA #(.n(32)) next_pc(.A(PC_out), .B(32'd4), .sum(PC_inc), .err(err));
  N_bitReg#(.n(32)) PC(.D(PC_in), .clk(clk), .rst(rst), .load(1'b1), .Q(PC_out));
  InstMem  inst(.addr(PC_out[6:2]), .data_out(inst_out));

  regFile #(.n(5)) register(.rst(rst), .clk(clk), .RegWrite(RegWrite), .inst(inst_out[14:12]), .data(Write_data), .read1(inst_out[19:15]), .read2(inst_out[24:20]), .write(inst_out[11:7]), .r1(read1), .r2(read2));

  immGen imm(.gen_out(imm_gen_out), .IR(inst_out));

nBitShifter#(.n(32)) shl( .x(imm_gen_out), .y(shift_out));

RCA #(.n(32)) branch_pc(.A(PC_out), .B(shift_out), .sum(pc_branch), .err(err));

reg flag;
 
  Branch_Unit BU(.inst(inst_out[14:12]),
                 .cf(cf),
                 .zf(zf),
                 .vf(vf),
                 .sf(sf),
                 .Branch(Branch),
                 .flag(flag));

  NbitMUX#(.n(32)) MUX_pc(.A(pc_branch), .B(PC_inc ), .sel(flag), .out(PC_in));
  
  

  
NbitMUX#(.n(32)) MUX_reg(.A(imm_gen_out), .B(read2), .sel(ALUSrc), .out(alu_in_mux));

  
  NbitALU #( 32 ) ALU (
    .sel(alusel),
    .A(read1),
    .B(alu_in_mux),
    .shamt(inst_out[24:20]),
    .typ(inst_out[30]),
    .lui(lui),
    .ALUout(alu_out),
    .cf(cf),
    .zf(zf),
    .vf(vf),
    .sf(sf)
);


 DataMem data(.clk(clk), .MemRead(MemRead), .MemWrite(MemWrite), .inst(inst_out[14:12]), .addr(alu_out[6:2]), .data_in(read2), .data_out(data_mem_out));
NbitMUX#(.n(32)) MUX_data(.A(data_mem_out), .B(alu_out), .sel(MemtoReg), .out(Write_data));

  alu_ctrl alu_c(.aluop(ALUOp), .inst1(inst_out[14:12]), .inst2(inst_out[30]),.lui(lui) ,.alusel(alusel));
  
ctrl_unit cntrl(.inst(inst_out[6:2]), .Branch(Branch) , .MemRead(MemRead) , .MemtoReg(MemtoReg), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .lui(lui),.ALUOp(ALUOp));


endmodule