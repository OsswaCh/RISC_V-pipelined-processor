# RISC_V-pipelined-processor
A Verilog implementation of a 5 staged pipelined RISC_V processor with 1 memory and hazard detection.  

# CPU Modules Documentation

## I. Modules Description:

1. **Top Module - Central Processing Unit (CPU):**
    - Represents the core processing unit and integrates various components for instruction execution.
    - Functionality includes fetching, decoding, and executing instructions.
    - Inputs: clk (Clock signal), rst (Reset signal).
    - [Modules Used and detailed functionality.](#top-module---central-processing-unit-cpu)

2. **Memory Module:**
    - Responsible for storing program instructions and data.
    - Functionality includes reading and writing to memory.
    - Inputs: sclk (Clock signal), MemRead (Control signal for read), MemWrite (Control signal for write).
    - [Detailed functionality, memory capacity, and organization.](#memory-module)

3. **DecompUnit Module:**
    - Decompresses instructions in a compressed instruction set architecture (ISA).
    - Inputs: reset, clk, inst (32-bit instruction).
    - Outputs: instOut (Decompressed instruction), compress (Compression flag).
    - [Operation and functionality explained.](#decompuunit-module)

4. **Hazard Detection Unit Module:**
    - Identifies potential hazards during instruction execution.
    - Inputs: IF_ID_RegisterRs1, IF_ID_RegisterRs2, ID_EX_RegisterRd, ID_EX_MemRead.
    - Output: stall (Control signal for fetch stage).
    - [Detailed functionality and operation.](#hazard-detection-unit-module)

5. **Forwarding Unit Module:**
    - Resolves data hazards by forwarding data within the pipeline.
    - Inputs: ID_EX_RegisterRs1, ID_EX_RegisterRs2, MEM_WB_RegWrite, EX_MEM_RegWrite.
    - Outputs: forwardA_ALU, forwardB_ALU.
    - [Operation and benefits outlined.](#forwarding-unit-module)

6. **Branch Unit Module:**
    - Controls branching behavior within the processor.
    - Inputs: inst[2:0], Branch, jump, cf, zf, vf, sf.
    - Output: flag (Control signal for branch taken/jump type).
    - [Operation and functionality described.](#branch-unit-module)

7. **Control Unit Module:**
    - Generates control signals for the datapath based on instructions.
    - Inputs: rst, inst.
    - Outputs: Branch, jump, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, signed_inst, PC_en, RF_MUX_sel, AU_inst_sel.
    - [Detailed functionality and operation.](#control-unit-module)

8. **ALU Control Module:**
    - Determines ALU operation based on instruction type and function code.
    - Inputs: ALUOp, inst.
    - Output: ALU_selection.
    - [Functionality and operation explained.](#alu-ctrl-module)

9. **Register File Module:**
    - Stores temporary data during program execution.
    - Inputs: rst, clk, RegWrite, data, read1, read2, write.
    - Outputs: r1, r2.
    - [Functionality and operation detailed.](#regfile-module)

## II. Remarks:
- Challenges have been encountered with the forwarding unit's functionality.

---

### Top Module - Central Processing Unit (CPU):

The Top Module represents the core processing unit (CPU) and integrates various components responsible for instruction execution.


#### Functionality:
- Fetches instructions from memory.
- Decodes instructions.
- Executes arithmetic and logic operations using the ALU (Arithmetic Logic Unit).
- Manages control signals based on the instruction type (opcode) through the control unit.
Inputs:
- clk: Clock signal - synchronizes the operation of the CPU.
- rst: Reset signal - initializes the CPU to a known state.
Modules Used:
- N bitReg.v: N-bit register module - stores temporary data during instruction execution.
- regFile.v: Register file module - stores general-purpose registers for data manipulation.
- immGen.v: Immediate generator module - generates immediate values for certain instructions.
- NbitMUX.v: N-bit multiplexer module - allows selection between different data sources.
- NbitALU.v: N-bit ALU module - performs arithmetic and logic operations on data.
- ctrl unit.v: Control unit module - generates control signals based on the instruction type.
- nBitShifter.v: N-bit shifter module - shifts data by a specified number of bits.
- alu ctrl.v: ALU control module - generates specific control signals for the ALU based on the instruction.
- Branch Unit.v: Branch unit module - handles conditional branching instructions.
- Memory.v: Memory module - stores both program instructions and data.
- Hazard_detection_unit.v: Hazard detection module - identifies potential hazards during instruction execution.
- Forwarding_unit.v: Forwarding unit module - optimizes instruction execution by forwarding results from previous stages.
- DecompUnit.v: Decompressing unit module – decompresses instructions if in compressed form.

## Notes
- all of the functionalities of the alu for the uncompressed instructions are working 
- the tested functionalities of the compressed instructions are working
- loading, branching and jumping work fine except for the instruction following the correctly ecexuted one, this problem was not encountered in the pipelined implementation of two memories however we started facing it when we implemented the single memory 
- the forwarding is detected and applied correctly 
- storing sometimes have glitches we couldnt fix 
- the rest of the tested functionalities are working fine


## Instructions
view design.v for the top module
open the schematics using draw.io 
5 is the latest version

