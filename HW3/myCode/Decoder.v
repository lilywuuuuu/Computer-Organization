module Decoder( instr_op_i, RegWrite_o,	ALUOp_o, ALUSrc_o, RegDst_o );
     
//I/O ports
input	[6-1:0] instr_op_i;

output			RegWrite_o;
output	[3-1:0] ALUOp_o;
output			ALUSrc_o;
output			RegDst_o;
 
//Internal Signals
wire	[3-1:0] ALUOp_o;
wire			ALUSrc_o;
wire			RegWrite_o;
wire			RegDst_o;

//Main function
/*your code here*/

// R format = 000000
// lw       = 100011
// sw       = 101011
// beq      = 000100
// addi     = 001000

// ALU op: 000 = sw/lw, 001 = beq, 010 = R-format, 100 = addi

assign ALUOp_o[0] = (instr_op_i[2]) ? 1'b1 : 1'b0;
assign ALUOp_o[1] = (instr_op_i == 6'b000000) ? 1'b1 : 1'b0;
assign ALUOp_o[2] = (instr_op_i == 6'b001000) ? 1'b1 : 1'b0;
assign ALUSrc_o = (instr_op_i[5] || instr_op_i[3]) ? 1'b1 : 1'b0;
assign RegWrite_o = (instr_op_i == 6'b000000 || instr_op_i == 6'b100011 || instr_op_i == 6'b001000) ? 1'b1 : 1'b0;
assign RegDst_o = (instr_op_i == 6'b000000) ? 1'b1 : 1'b0; 

endmodule
   