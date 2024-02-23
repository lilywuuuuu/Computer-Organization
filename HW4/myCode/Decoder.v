module Decoder( instr_op_i, RegWrite_o,	ALUOp_o, ALUSrc_o, RegDst_o, Jump_o, Branch_o, BranchType_o, MemWrite_o, MemRead_o, MemtoReg_o );
     
//I/O ports
input	[6-1:0] instr_op_i;

output			RegWrite_o;
output	[3-1:0] ALUOp_o;
output			ALUSrc_o;
output	[2-1:0]	RegDst_o, MemtoReg_o;
output			Jump_o, Branch_o, BranchType_o, MemWrite_o, MemRead_o;
 
//Internal Signals
wire	[3-1:0] ALUOp_o;
wire			ALUSrc_o;
wire			RegWrite_o;
wire	[2-1:0]	RegDst_o, MemtoReg_o;
wire			Jump_o, Branch_o, BranchType_o, MemWrite_o, MemRead_o;

//Main function
/*your code here*/

// Op field
// R format = 000000
// lw       = 100001
// sw       = 100011
// beq      = 111011
// bne      = 100101
// addi     = 001000
// jump     = 100010

// ALUOp
// R format = 010
// addi     = 011
// lw, sw   = 000
// beq      = 001
// bne      = 110
// jump     = x

assign ALUOp_o[0] = (instr_op_i == 6'b001000 || instr_op_i == 6'b111011) ? 1'b1 : 1'b0; // addi, beq
assign ALUOp_o[1] = (instr_op_i == 6'b000000 || instr_op_i == 6'b100101 || instr_op_i == 6'b001000) ? 1'b1 : 1'b0; // R format, bne, addi
assign ALUOp_o[2] = (instr_op_i == 6'b100101) ? 1'b1 : 1'b0; // bne

assign ALUSrc_o      = (instr_op_i == 6'b100001 || instr_op_i == 6'b100011 || instr_op_i == 6'b001000) ? 1'b1 : 1'b0; // lw, sw, addi
assign RegWrite_o    = (instr_op_i == 6'b000000 || instr_op_i == 6'b100001 || instr_op_i == 6'b001000) ? 1'b1 : 1'b0; // R format, lw, addi
assign RegDst_o[0]   = (instr_op_i == 6'b000000) ? 1'b1 : 1'b0; // R format
assign MemtoReg_o[0] = (instr_op_i == 6'b100001) ? 1'b1 : 1'b0; // lw
assign Jump_o        = (instr_op_i == 6'b100010) ? 1'b1 : 1'b0; // jump
assign Branch_o      = (instr_op_i == 6'b111011 || instr_op_i == 6'b100101) ? 1'b1 : 1'b0; // beq, bne 
assign BranchType_o  = (instr_op_i == 6'b100101) ? 1'b1 : 1'b0; // bne
assign MemWrite_o    = (instr_op_i == 6'b100011) ? 1'b1 : 1'b0; // sw
assign MemRead_o     = (instr_op_i == 6'b100001) ? 1'b1 : 1'b0; // lw


endmodule
   