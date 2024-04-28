


module memory (     
  input sclk, 
  input MemRead, 
  input MemWrite,
  input signed_inst,
  input [1:0] AU_inst_sel,
  input [7:0] addr, 
  input [31:0] data_in,
  output reg [31:0] data_out

);

//we will be splitting one instruction in 4 bytes, thus every memory slot will be 1 byte
//for a normal instruction, the 4 bytes will be the same, but for a compressed intructions it will be 2 

reg[7:0] mem [(4*1024):0] ; //4KB memory
  reg[7:0] offset =  8'd128; //offset for the memory location of the data

//loading and storing logic

wire [7:0] data_location;
    assign data_location = addr + offset;

    always@(*)begin
         if(sclk) data_out = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
          else if (MemRead == 1)
                case(AU_inst_sel) 
                    // LW --> takes in the full instruction 
                    2'b00 : data_out = {mem[data_location+3], mem[data_location+2], mem[data_location+1], mem[data_location]};
                    // LH, LHU --> takes in only the lower 2 bytes
                    2'b01 : 
                    begin
                        case(signed_inst)

                            // LHU --> 0 extend (no sign)
                            1'b0 : data_out = {16'b0, mem[data_location+1], mem[data_location]};
                            // LH --> sign extend of the 4rth bit of the second byte
                            1'b1 : data_out = {{16{mem[data_location+1][3]}}, mem[data_location+1], mem[data_location]};
                            
                            default : data_out = 32'b0;
                        endcase
                    end
                    // LB, LBU
                    2'b10 : 
                    begin
                        case(signed_inst)
                            // LBU 0 extend (no sign)
                            1'b0 : data_out = {24'b0, mem[data_location]};
                            // LB sign extend of the 4rth bit of the first byte 
                            1'b1 : data_out = {{24{mem[data_location][3]}}, mem[data_location]};
                            
                            default : data_out = 32'b0;
                        endcase
                    end
                    
                    default : data_out = 32'b0;
                endcase
            else
                begin
                    data_out = 32'b0;
                end 
        end

//the the offset of the sign extend

    //storing
    always @(*) begin
          if (~sclk && MemWrite) //write to memory on the negative edge of the clokc
            case(AU_inst_sel) 
                // SW 
                2'b00 : {mem[data_location+3], mem[data_location+2], mem[data_location+1], mem[data_location]} = data_in;
                // SH 
                2'b01 : { mem[data_location+1], mem[data_location] } = data_in[15:0];
                // SB 
                2'b10 : mem[data_location] = data_in[7:0];
                //default stays the same
                default : mem[data_location] = mem[data_location];
             endcase
        else
            begin
                mem[data_location] = mem[data_location];
            end 
    end


//testcase
  initial begin
    {mem[3], mem[2], mem[1], mem[0]}=32'b00000000000000000010010100000011;   //lw x10, 0(x0)   //(0)x0 = 5
 {mem[7], mem[6], mem[5], mem[4]}=32'b00000000010000000010010000000011;  //lw x8, 4(x0)  //4(x0)= 3
    {mem[11], mem[10], mem[9], mem[8]}=32'b00000000100000000010010010000011; //lw x9, 8(x0)    // 8(x0) = 7
    {mem[15], mem[14], mem[13], mem[12]}=32'b00000010100101000000001010110011; //mul x5, x8, x9#x5 = x8*x9(21)
    {mem[19], mem[18], mem[17], mem[16]}=32'b00000010100101000001001100110011;//mulh x6, x8, x9 # x6 = high 32 bits of the multiplication (0)
    {mem[23], mem[22], mem[21], mem[20]}=32'b00000010100101000011001110110011;//mulhu x7, x8, x9# x7 =unsigned multiplication high 32 bits (0)
    {mem[27], mem[26], mem[25], mem[24]}=32'b00000010100101000000010110111011;  //mulw x11, x8, x9    # x11 = low 32 bits of the multiplication (21)
    {mem[31], mem[30], mem[29], mem[28]}=32'b00000010100101000100011000110011;  //div  x12, x8, x9    # x12 = quotient of x8 / x9 (0)
    {mem[35], mem[34], mem[33], mem[32]}=32'b00000010100101000110011010110011;  //rem  x13, x8, x9    # x13 = remainder of x8 / x9 (3) 
    {mem[39], mem[38], mem[37], mem[36]}=32'b00000010100101000101011100110011;  //divu x14, x8, x9    # x14 = unsigned quotient of x8 / x9 (0)
    {mem[43], mem[42], mem[41], mem[40]}=32'b00000010100101000111011110110011;  //remu x15, x8, x9    # x15 = unsigned remainder of x8 / x9 (3)
    {mem[47], mem[46], mem[45], mem[44]}=32'b00000000101000000000100000010011;  //addi x16, x0, 10   // x11 = 10
    {mem[51], mem[50], mem[49], mem[48]}=32'b00000001000001010000100010110011; //add   x17, x10, x16   //(15)
    {mem[55], mem[54], mem[53], mem[52]}=32'b01000001000010001000100100110011;  //sub   x18, x17, x16    // (5)
    {mem[59], mem[58], mem[57], mem[56]}=32'b00000000001001010001100110010011; //slli   x19, x10, 2      // (20)
    {mem[63], mem[62], mem[61], mem[60]}=32'b00000001000001010010101010110011; //slt   x21, x10, x16   //x16 = 1 
    {mem[67], mem[66], mem[65], mem[64]}=32'b00000000101010000011101100110011;  //sltu  x22, x16, x10  //x17 = 1 
    {mem[71], mem[70], mem[69], mem[68]}=32'b00000001000001010100101110110011;  //xor   x23, x10, x16     //(15)
    {mem[75], mem[74], mem[73], mem[72]}=32'b00000001000001010111110000110011;  //and   x24, x10, x16    //(0)
    {mem[79], mem[78], mem[77], mem[76]}=32'b00000001000001010110110010110011;  //or    x25, x10, x16    //(15)
    {mem[83], mem[82], mem[81], mem[80]}=32'b00000000100000000010010010000011;  //lw x9, 8(x0)
    {mem[87], mem[86], mem[85], mem[84]}=32'b00000000110000000010010000000011;  //lw x8, 12(x0)
    {mem[91], mem[90], mem[89], mem[88]}=32'b00000000000000001000010100110111; //lui  x10, 8(x0)    # Load upper immediate to x10 (higher 20 bits of 8(x0))  
    {mem[95], mem[94], mem[93], mem[92]}=32'b00000000001000000000011111101111;  //jal  x15, 2  # Jump and link to function loop_func (saves PC to x15)
    {mem[99], mem[98], mem[97], mem[96]}=32'b00000000100001001000000100110011;  //add  x2, x9, x8
    {mem[103], mem[102], mem[101], mem[100]}=32'b00000000000101000000010000010011;  //addi x8, x8, 1 
    {mem[107], mem[106], mem[105], mem[104]}=32'b11111110100001001001111111100011;  //bne  x9, x8, -2 
    {mem[111], mem[110], mem[109], mem[108]}=32'b00000000000000000000011100010011; //addi x14, x0, 0
    {mem[115], mem[114], mem[113], mem[112]}=32'b00000000000000000010110100010111;  //AUIPC    x26, 2 
    
    {mem[119], mem[118], mem[117], mem[116]}=32'b00000000100100000010100000100011;  //sw x9, 16(x0)
    {mem[123], mem[122], mem[121], mem[120]}=32'b00000001000000000010010100000011;  //lw x10, 16(x0)
    {mem[127], mem[126], mem[125], mem[124]}=32'b00000000000001010000010100010011;  //addi x10, x10, 0 
 

 //data



    {mem[131], mem[130], mem[129], mem[128]} = { 32'd5};
    {mem[135], mem[134], mem[133], mem[132]} = { 32'd3};
    {mem[139], mem[138], mem[137], mem[136]} = { 32'd7};
    {mem[143], mem[142], mem[141], mem[140]} = { 32'd3};
  end


endmodule