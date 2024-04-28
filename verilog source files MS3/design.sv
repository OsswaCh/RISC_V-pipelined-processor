/*******************************************************************
*
* Module: top
* Project: RISC-V processor
* Author: ousswa chouchane 
* Description: The top module for the RISC-V processor 
*
* Change history: 
- integrated the alu and alu control 
- integrated the branching unit without jump 
- integrated the new control unit to accomodate for all instructions
- cleaned the top module

changed to be revised
ID_EX_RegisterRs2(/*ID_EX_Rs2*//*IF_ID_inst_out [24:20]), (forwarding unit)  + ~sclk gets u almost somewhere
same was done with id_ex_rs2 
and clock for ex/mem turned to negative

chenaegd mem_out in mem_wb into id

*
**********************************************************************/


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
`include "forwarding_unit.v"
`include "Hazard_Detection_Unit.v"
`include "defines.v"
`include "Branch_Unit.v"
`include "memory.v"
`include "DecompUnit.v"


module top(input clk, rst);

  wire [31:0] Read_addr;
  reg [31:0] PC_in; //changed to reg
  wire [31:0] inst_out;
  wire [31:0] write_data;
  wire [31:0] read1;
  wire [31:0] read2;
  wire [31:0] gen_out;
  wire [31:0] shift_out;
  wire [31:0] alu_input;
  wire [31:0] alu_out;
  wire [31:0] mem_out;
  wire [31:0] B_Add_Out;
  wire [31:0] jalr_add_out; //added
  wire [31:0] pc_inc;

  
  //forwarding unit wire

  wire [31:0] forwarded_A_ALU;
  wire [31:0] forwarded_B_ALU;
  wire [31:0] ALU_second_input;
  wire[1:0] forwardA_ALU;
  wire[1:0] forwardB_ALU;
  
  wire Branch;
  wire MemRead;
  wire MemtoReg;
  wire MemWrite;
  wire ALUSrc;
  wire RegWrite;
  wire zFlag;
  wire V;
  wire C;
  wire S;
  wire ofFlag;
  wire [1:0]B_MUX_Sel; //made 2 bit for jumping
  wire discard1;
  wire discard2;

  wire [2:0] ALUOp; //added 1 bit
  wire [4:0] alu_Selection;
  
  //control unit
  wire jump;
  wire signed_inst; // for the memory 
  wire [1:0] RF_MUX_sel; 
  wire [1:0] AU_inst_sel;
  wire PC_en;
  
  wire stall;  
  
  
  //pipeline registers 
  
  //IF_ID 
  wire [31:0] IF_ID_PC;
  wire [31:0] IF_ID_inst_out;
  wire [31:0] ID_EX_PC;
  wire [31:0] ID_EX_RegR1;
  wire [31:0] ID_EX_RegR2;
  wire [31:0] ID_EX_Imm;
  wire [63:0] IF_ID_input;
  wire IF_ID_flush_sel = stall | (B_MUX_Sel);  //--> to be revised 
  
  //ID_EX
  wire [31:0] ID_EX_inst;
  wire [2:0] ID_EX_ALUOp;
  wire [3:0] ID_EX_Func;
  wire [4:0] ID_EX_Rs1; 
  wire [4:0] ID_EX_Rs2; 
  wire [4:0] ID_EX_Rd;
  wire [15:0]ID_EX_input; //added 1 bit to 8 for 3 bit for aluop --> 16 for the new flags
  wire ID_EX_Branch;
  wire ID_EX_MemRead;
  wire ID_EX_MemtoReg;
  wire ID_EX_MemWrite;
  wire ID_EX_ALUSrc;
  wire ID_EX_RegWrite;
    
  //EX_MEM
  wire [31:0] EX_MEM_BranchAddOut;
  wire [31:0] EX_MEM_alu_out; 
  wire [31:0] EX_MEM_RegR2;
  wire [4:0] EX_MEM_Rd;
  wire [9:0] EX_MEN_cntrlInput; // changed from 5 bits to 9 bits for the select lines --> 10 for jump
  wire [3:0]EX_MEM_func;
  wire EX_MEM_Branch;
  wire EX_MEM_MemRead;
  wire EX_MEM_MemtoReg;
  wire EX_MEM_MemWrite;
  wire EX_MEM_RegWrite;
  wire EX_MEM_Zero;
  
  //MEM_WB
  reg [31:0] MEM_WB_data_mem_out; //changed to reg
  wire [31:0] MEM_WB_alu_out;
  wire MEM_WB_MemtoReg,MEM_WB_RegWrite;
  wire [4:0] MEM_WB_Rd;
  
  //alu muxes of forwarding unit
  reg [31:0] mux_alu1;
  reg [31:0] mux_alu2;
  
  //adder carry
  wire cout;
  
  
  //to clean
  wire [31:0] Jalr_add_Out;
  wire cout2, discard3; 
  wire [1:0]EX_MEM_RF_MUX_sel, EX_MEM_AU_inst_sel;
  wire EX_MEM_jump;
  wire [31:0] EX_MEM_Jalr_add_Out;
  wire flush_flag = (B_MUX_Sel==2'b1 || B_MUX_Sel==2'b10 )? 1:0; 
  wire ID_EX_jump,ID_EX_signed_inst, ID_EX_PC_en;
  wire [1:0]ID_EX_RF_MUX_sel, ID_EX_AU_inst_sel; 
  wire [1:0]MEM_WB_RF_MUX_sel;
  reg [31:0] RF_writeInReg_data; 
  wire [31:0] MEM_WB_Jalr_add_Out;
  reg sclk; 
  wire[7:0] mem_in; 
  wire [31:0] EX_MEM_inst;
  wire  [31:0] uncomp_instruction;
  wire compress;
  
  //////////////////////////// clock ////////////////////////////////  
  
  always@(posedge clk, posedge rst)
    begin 
        if(rst)
            sclk = 0;
        else
            sclk = ~sclk;
    end


  ////////////////////////////pc stage ////////////////////////////////
  
  //pc
  N_bitReg #(32) PC (
    .D(PC_in),
    .clk(sclk),
    .rst(rst),
    .load(~stall & PC_en),
    .Q(Read_addr)
	);
  
  //InstMem IM(Read_addr[7:2], inst_out); -->removed
 
  
 
  //a mux deciding what gets into the memory
  NbitMUX  #(8) MUX_MEM_input(
    .A(Read_addr[7:0]), 
    .B(EX_MEM_alu_out[7:0]), 
    .sel(sclk ), //when sclk is 1 it chooses pc else it chooses out output of the alu (address)
    .out(mem_in)
    );
 
  
	
  //single memory
  
  memory mem (     
    .sclk(sclk & ~stall), 
    .MemRead(EX_MEM_MemRead), 
    .MemWrite(EX_MEM_MemWrite),
    .signed_inst(EX_MEM_signed_inst),
    .AU_inst_sel(EX_MEM_AU_inst_sel),
    .addr(mem_in), 
    .data_in(mux_alu2),
    .data_out(mem_out)

	);
  
  
  //decompression unit
   

  DecompUnit decompU(
    .reset(rst), 
    .clk(sclk),
    .inst(mem_out),
    .instOut(uncomp_instruction),
    .compress(compress)
);

  wire [31:0] added_to_pc = compress? 32'd2:32'd4;
  
  RCA #(32) PC_adder(
      .A(added_to_pc),
      .B(Read_addr), // Changed from Read_addr to ID_EX_PC
      .sum(pc_inc),
      .cout(cout),
      .err(discard2)
    );	
  
  //note in muxes: if sel == 1 we choose A else we choose B 
  //since the branching happends in the mem stage
  always @ (*)begin
    case (B_MUX_Sel)
        2'b0:  PC_in= pc_inc;
        2'b01: PC_in = EX_MEM_BranchAddOut;
        2'b10: PC_in = EX_MEM_Jalr_add_Out;
        //3rd case?
        default: PC_in= pc_inc;
    endcase
  end
  
 
  //hazard detection 
  Hazard_Detection_Unit HazardUnit(
    .IF_ID_RegisterRs1(IF_ID_inst_out[19:15]), 
    .IF_ID_RegisterRs2(IF_ID_inst_out[24:20]), 
    .ID_EX_RegisterRd(ID_EX_Rd), 
    .ID_EX_MemRead(ID_EX_MemRead), 
    .stall(stall)
);
 

  
    //////////////////////////// IF/ID ////////////////////////////////

 
  
  //flushing the instruction in case of a branch
    NbitMUX  #(64) Mux_IF_ID_flush(
      .A({32'b0,32'b0000000_00000_00000_000_00000_0110011}), 
      .B({Read_addr, /*inst_out*//*mem_out*/uncomp_instruction}), //changed 
      .sel(flush_flag), //changed from B_MUX_Sel to flush_flag for jumps and branches
      .out(IF_ID_input)
    );

  	//IF_ID reg
  N_bitReg #( 64) IF_ID (
    .D(IF_ID_input), //changed from {Read_addr, inst_out}
    .clk(~sclk),
    .rst(rst),
    .load(~stall),
    .Q({IF_ID_PC, IF_ID_inst_out}) //inst_out holds also the data incase this is a data reading cycle
  );
  
  wire[4:0] ifIdrs2 = IF_ID_inst_out [24:20];
  wire[4:0] ifIdRd =  IF_ID_inst_out[11:7];
  
    
  	//control unit
  ctrl_unit CU (
    .rst(rst), 
    .inst(IF_ID_inst_out),
    .Branch(Branch),
    .jump(jump),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .signed_inst(signed_inst),
    .PC_en(PC_en),
    .RF_MUX_sel(RF_MUX_sel), //what data to write back in the reg
    .AU_inst_sel(AU_inst_sel),  //determines the type of store and laod from the memory
    .ALUOp(ALUOp) /*make it 1 bit bigger!!!--> done*/
	);
  
  //write data input (check auipc and jalr)
  
  
  always @ (*)begin
    case (MEM_WB_RF_MUX_sel)
        2'b0:  RF_writeInReg_data= /*MEM_WB_RegWrite*/write_data;
        2'b01: RF_writeInReg_data = MEM_WB_Jalr_add_Out;
        2'b10: RF_writeInReg_data = MEM_WB_Jalr_add_Out;//both calculated by the jalr adder
        //3rd case?
        default: RF_writeInReg_data= write_data;
    endcase
  end
  
  
  //register file
  regFile #( 5) RF(
   .rst(rst),
   .clk(~sclk),
   .RegWrite(MEM_WB_RegWrite),
    .data(RF_writeInReg_data), //changed from write_data
   .read1(IF_ID_inst_out[19:15]), 
   .read2(IF_ID_inst_out[24:20]),
   .write(MEM_WB_Rd),
   .r1(read1),
   .r2(read2)
	);

	//immediate generator
  immGen IG( 
    .IR(IF_ID_inst_out),
  	.Imm(gen_out)
  );
  
  //mux flushing ID/EX in case of stall of branch
	
  NbitMUX  #(16) MUX_Hazard_to_ID_EX( //made 9 bits for ALUOp
    .A(16'b0), 
    .B({Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp, jump, signed_inst, PC_en, RF_MUX_sel, AU_inst_sel}), 
    .sel(/*IF_ID_flush_sel*/flush_flag), 
    .out(ID_EX_input)
  );
  	//added jump, signed_inst, PC_en, RF_MUX_sel, AU_inst_sel and chaged size from 9 to 16
  
  
      //////////////////////////// ID/EX ////////////////////////////////

  
  //ID/EX reg
  
  wire [4:0] idExRd_test_before  = IF_ID_inst_out[11:7];
  wire [4:0] idExRs2_test_before = IF_ID_inst_out[24:20];


  
  N_bitReg #(195) ID_EX (
    .D({ID_EX_input,IF_ID_PC, read1, read2, gen_out, {IF_ID_inst_out[30], IF_ID_inst_out[14:12]}, IF_ID_inst_out[19:15], IF_ID_inst_out[24:20], IF_ID_inst_out[11:7],IF_ID_inst_out}),
    .clk(~sclk), //cahnegd this to ~
    .rst(rst),
    .load(1'b1),
    .Q({ID_EX_Branch, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite, ID_EX_ALUOp, /*add here*/ ID_EX_jump, ID_EX_signed_inst, ID_EX_PC_en, ID_EX_RF_MUX_sel, ID_EX_AU_inst_sel /*done*/ ,ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm, ID_EX_Func, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd, ID_EX_inst})
  );
  
  wire [4:0] idExRd_test_after  = ID_EX_Rd;
  wire [4:0] idExRs2_test_after = ID_EX_Rs2;
  
  //changed /*Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp*/ to ID_EX_input --> check size
  //changed the size from 155 to 187 and added the full instruction ID_EX_inst at the end
  //add 1 bit for the ALUOp --> 188
  //added 7 bits for the new controls jump, signed_inst, PC_en, RF_MUX_sel, AU_inst_sel --> 195
  //added ID_EX_jump, ID_EX_signed_inst, ID_EX_PC_en, ID_EX_RF_MUX_sel, ID_EX_AU_inst_sel
  
  
  //mux that flushed the control for ex/mem
  
  NbitMUX  #(10) MUX_Hazard_to_EX_MEM(
    .A(10'b0), 
    .B({ID_EX_Branch, ID_EX_jump,ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_RegWrite,ID_EX_RF_MUX_sel, ID_EX_AU_inst_sel}), 
    .sel(flush_flag),  //changed from B_MUX_Sel for jumps and branches
   .out(EX_MEN_cntrlInput)
 );
  //added 4 bits for ID_EX_RF_MUX_sel, ID_EX_AU_inst_sel 5-->9
  //added 1 bit for jumping -->10
  
  //1bit shifter 
  nBitShifter #(32) SL(
    .x(ID_EX_Imm), // ID_EX_Imm change to gen_out -->didnt do much s
    .y(shift_out)
  );
 wire[4:0] forwdIFIDrs1 = IF_ID_inst_out[19:15];
  wire[4:0] forwdIFIDrs2 = IF_ID_inst_out[24:20];
  
    //new forwarding unit
   Forwarding_Unit forward_unit(
     .ID_EX_RegisterRs1(/*ID_EX_Rs1*/IF_ID_inst_out[19:15]),  //to solve the forwarding problem
     .ID_EX_RegisterRs2(/*ID_EX_Rs2*/IF_ID_inst_out [24:20]), //to solve the forwarding problem
     .MEM_WB_RegWrite(MEM_WB_RegWrite), 
     .EX_MEM_RegWrite(EX_MEM_RegWrite), 
     .MEM_WB_RegisterRd(MEM_WB_Rd), 
     .EX_MEM_RegisterRd(EX_MEM_Rd), 
    .forwardA_ALU(forwardA_ALU), 
    .forwardB_ALU(forwardB_ALU)
  );
  
  
 
	//forwarding logic
  
  //input to port a OF ALU
  always @ (*)begin

    case (forwardA_ALU)
        2'b0: mux_alu1= ID_EX_RegR1;
        2'b11: mux_alu1 = ID_EX_RegR1;
        2'b01: mux_alu1 = write_data;
        2'b10: mux_alu1 =  EX_MEM_alu_out;
        default: mux_alu1= 0;
    endcase
  end

  //input to port a OF PORT B MUX
  always @ (*)begin

    case (forwardB_ALU)
        2'b0: mux_alu2= ID_EX_RegR2;
        2'b11: mux_alu2 = ID_EX_RegR2;
        2'b01: mux_alu2 = write_data;
        2'b10: mux_alu2 =  EX_MEM_alu_out;
        default: mux_alu2= 0;
    endcase
  end
  
  //input to port B OF ALU
  NbitMUX #(32) MUX_RF(
    .A(ID_EX_Imm),
    .B(mux_alu2),
    .sel(ID_EX_ALUSrc),
    .out(alu_input)
  );


  //alu control 
  
  alu_ctrl ALU_CU (
    .ALUOp(ID_EX_ALUOp),
    .inst(ID_EX_inst), 
    .ALU_selection(alu_Selection)
);
  
  ///alu

  NbitALU #(32) ALU(
    .A(mux_alu1),
    .B(alu_input),
    .alu_control(alu_Selection),
    .ALUout(alu_out),
    .Z(zFlag),
    .V(V),
    .C(C),
    .S(S)
	);
  
    //branch adder
  RCA #(32) Branch_adder(
    .A(shift_out), 
    .B(ID_EX_PC/*Read_addr*/), 
    .sum(B_Add_Out),
    .cout(cout),
    .err(discard1)
  );
  //changed A to ID_EX_Imm from shift out ?? // puts it back cauz not shifted
  //chanegd read_address here to ID_EX_PC ==> fixed sth // thinking of putting it back//if_id next?


  
  //jalr and auipc adder --> they only differ in the immediate added to pc which is handled by the immGen
  RCA #(32) Jalr_adder(
    .A(ID_EX_Imm), 
    .B(ID_EX_PC/*Read_addr*/), 
    .sum(Jalr_add_Out),
    .cout(cou2),
    .err(discard3)
  );
  
  
     //////////////////////////// EX_MEM ////////////////////////////////

  
//EX_MEN_cntrlInput = ID_EX_Branch, ID_EX_jump,ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_RegWrite,ID_EX_RF_MUX_sel, ID_EX_AU_inst_sel
  
  wire [4:0] exMemRd_test_before = ID_EX_Rd; 
  wire [4:0] exMemRd_test_after =  EX_MEM_Rd; 

  
  N_bitReg #(183) EX_MEM (
    .D({B_Add_Out,Jalr_add_Out,alu_out, mux_alu2/*ID_EX_RegR2*/,EX_MEN_cntrlInput, ID_EX_Rd,ID_EX_Func, zFlag,V,C,S,/*added*/ID_EX_inst }),
    .clk(~sclk),
    .rst(rst),
    .load(1'b1),
    .Q({EX_MEM_BranchAddOut,EX_MEM_Jalr_add_Out,/*jump addout added*/ EX_MEM_alu_out, EX_MEM_RegR2,/*begin*/ EX_MEM_Branch, EX_MEM_jump ,EX_MEM_MemRead, EX_MEM_MemtoReg, EX_MEM_MemWrite, EX_MEM_RegWrite ,EX_MEM_RF_MUX_sel, EX_MEM_AU_inst_sel,/*end*/ EX_MEM_Rd,EX_MEM_func, EX_MEM_Zero,EX_MEM_V,EX_MEM_C,EX_MEM_S/*added*/,EX_MEM_inst})
);
  //changed /* ID_EX_Branch, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_RegWrite*/ to EX_MEN_cntrlInput --> chdeck sizes 
  //added v,c,s and changed the size frol 107 to 110
  //added EX_MEM_func and made the size 114
  //add 4 bits for the new selects ID_EX_RF_MUX_sel, ID_EX_AU_inst_sel 114--> 118
  //added EX_MEM_jump size 118-->119
  //add 32bits for the Jalr_add_Out 119-->151 + EX_MEM_Jalr_add_Out
  //add id_ex_instruction +32bits : 151 -->183

  
  //branching unit
  Branch_Unit branchUnit(
    .inst(EX_MEM_func[2:0]),
    .Branch(EX_MEM_Branch),
    .jump(EX_MEM_jump),
    .cf(EX_MEM_C), 
    .zf(EX_MEM_Zero), 
    .vf(EX_MEM_V), 
    .sf(EX_MEM_S),
    .flag(B_MUX_Sel)
  );
//added the jump and chenged the size of B_MUX_Sel


  
     //////////////////////////// MEM_WB ////////////////////////////////
 
  wire [4:0] memWbRd_test_before =  EX_MEM_Rd; 

  N_bitReg #(105) MEM_WB (
    .D({EX_MEM_MemtoReg, EX_MEM_Jalr_add_Out ,EX_MEM_RegWrite, uncomp_instruction/*EX_MEM_inst[31:0]*/, EX_MEM_alu_out, EX_MEM_Rd, EX_MEM_RF_MUX_sel}),
    .clk(sclk),
    .rst(rst),
    .load(1'b1),
    .Q({MEM_WB_MemtoReg, MEM_WB_Jalr_add_Out,MEM_WB_RegWrite, MEM_WB_data_mem_out, MEM_WB_alu_out, MEM_WB_Rd,MEM_WB_RF_MUX_sel})
  );
  
  //need to add EX_MEM_RF_MUX_sel +2bits -->71-->73
  //add 32 bits for the jal/jalr addout 73-->105

  /*
  always@(*)begin 
    
    if (~sclk) MEM_WB_data_mem_out=mem_out;
    else MEM_WB_data_mem_out=EX_MEM_inst[31:0];
    
  end 
    */
    
  
  NbitMUX #(32) MUX_Mem(
    .A(MEM_WB_data_mem_out),
  	.B(MEM_WB_alu_out),
  	.sel(MEM_WB_MemtoReg),
  	.out(write_data)
  );
 
   ////////////////////old trash for comparision//////////////////
  

  

endmodule


