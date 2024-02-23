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

// or = 0000, and = 0001, add = 0010, sub = 0110, nor = 1101, slt = 0111, 

assign ALU_operation_o[0] = (ALUOp_i[1] && (funct_i == 6'b010100 || funct_i == 6'b100000 || funct_i == 6'b010101)) ? 1'b1 : 1'b0; // and, slt, nor
assign ALU_operation_o[1] = ((ALUOp_i[1] && (funct_i == 6'b010010 || funct_i == 6'b010000 || funct_i == 6'b100000)) || ALUOp_i[2]) ? 1'b1 : 1'b0; // add, sub, slt, addi
assign ALU_operation_o[2] = (ALUOp_i[1] && (funct_i == 6'b010000 || funct_i == 6'b010101 || funct_i == 6'b100000)) ? 1'b1 : 1'b0; // sub, nor, slt
assign ALU_operation_o[3] = (ALUOp_i[1] && funct_i == 6'b010101) ? 1'b1 : 1'b0; // nor

// furslt: ALU result = 00, Shifter result = 01, Zero filled = 10
assign FURslt_o[0] = (ALUOp_i[1] && (funct_i == 6'b000000 || funct_i == 6'b000010)) ? 1'b1 : 1'b0;
assign FURslt_o[1] = 1'b0;

endmodule     
