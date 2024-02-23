module ALU_Ctrl( funct_i, ALUOp_i, ALU_operation_o, FURslt_o );

//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALU_operation_o;  
output     [2-1:0] FURslt_o;
     
//Internal Signals
wire		[4-1:0] ALU_operation_o;
wire		[2-1:0] FURslt_o;

//Main function
/*your code here*/

// Ainv Binv Op1 Op0
// or               = 0000
// and              = 0001
// add, addi        = 0010
// sub, bne, beq    = 0110
// nor              = 1101
// slt              = 0111

// ALUOp
// R format = 010
// addi     = 011
// lw, sw   = 000
// beq      = 001
// bne      = 110
// jump     = x

assign ALU_operation_o[0] = (ALUOp_i == 3'b010 && (funct_i == 6'b010100 || funct_i == 6'b100000 || funct_i == 6'b010101)) ? 1'b1 : 1'b0; // and, slt, nor
assign ALU_operation_o[1] = ((ALUOp_i == 3'b010 && (funct_i == 6'b010010 || funct_i == 6'b010000 || funct_i == 6'b100000)) || ALUOp_i == 3'b011 || ALUOp_i == 3'b001 || ALUOp_i == 3'b110) ? 1'b1 : 1'b0; // addi, beq, bne, add, sub, slt
assign ALU_operation_o[2] = ((ALUOp_i == 3'b010 && (funct_i == 6'b010000 || funct_i == 6'b010101 || funct_i == 6'b100000)) || ALUOp_i == 3'b001 || ALUOp_i == 3'b110) ? 1'b1 : 1'b0; // beq, bne, sub, nor, slt
assign ALU_operation_o[3] = (ALUOp_i == 3'b010 && funct_i == 6'b010101) ? 1'b1 : 1'b0; // nor

// furslt[0]: ALU result = 0, Shifter result = 1
// furslt[1]: shift left = 1, shift right = 0
assign FURslt_o[0] = (ALUOp_i == 3'b010 && (funct_i == 6'b000000 || funct_i == 6'b000010)) ? 1'b1 : 1'b0; // sll, srl
assign FURslt_o[1] = (ALUOp_i == 3'b010 && funct_i == 6'b000000) ? 1'b1 : 1'b0; // leftRight == 1 if sll

endmodule     
