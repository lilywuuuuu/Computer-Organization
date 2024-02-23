module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signals
wire ALUSrc, ALU_zero, branch, RegWrite, RegDst, ALUoverflow;
wire [2:0] ALUOp;
wire [3:0] ALU_operation;
wire [1:0] FURslt;
wire [4:0] RDaddr;
wire [31:0] PC_in, PC_out, IM_out, RDdata, RSdata, RTdata, result_shifter, result_ALU;
wire [31:0] SE_out, ZF_out, ALU_src2, Adder2_out, Adder2_in;

//modules
Program_Counter PC(
        .clk_i(clk_i),      
        .rst_n(rst_n),     
        .pc_in_i(PC_in) ,   
        .pc_out_o(PC_out) 
);
	
Adder Adder1(
        .src1_i(32'd4),     
        .src2_i(PC_out),
        .sum_o(PC_in)    
);
	
Instr_Memory IM(
        .pc_addr_i(PC_out),  
        .instr_o(IM_out)    
);

Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(IM_out[20:16]), // rt
        .data1_i(IM_out[15:11]), // rd
        .select_i(RegDst),
        .data_o(RDaddr)
);	
		
Reg_File RF(
        .clk_i(clk_i),      
        .rst_n(rst_n),     
        .RSaddr_i(IM_out[25:21]),  
        .RTaddr_i(IM_out[20:16]),  
        .RDaddr_i(RDaddr),  
        .RDdata_i(RDdata), 
        .RegWrite_i(RegWrite),
        .RSdata_o(RSdata),  
        .RTdata_o(RTdata)   
);
	
Decoder Decoder(
        .instr_op_i(IM_out[31:26]), 
        .RegWrite_o(RegWrite), 
        .ALUOp_o(ALUOp),   
        .ALUSrc_o(ALUSrc),   
        .RegDst_o(RegDst)   
);

ALU_Ctrl AC(
        .funct_i(IM_out[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALU_operation_o(ALU_operation),
        .FURslt_o(FURslt)
);
	
Sign_Extend SE(
        .data_i(IM_out[15:0]),
        .data_o(SE_out)
);

Zero_Filled ZF(
        .data_i(IM_out[15:0]),
        .data_o(ZF_out)
);
		
Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(RTdata),
        .data1_i(SE_out),
        .select_i(ALUSrc),
        .data_o(ALU_src2)
);	
		
ALU ALU(
        .aluSrc1(RSdata),
        .aluSrc2(ALU_src2),
        .ALU_operation_i(ALU_operation),
        .result(result_ALU),
        .zero(ALU_zero),
        .overflow(ALUoverflow)
);
		
Shifter shifter( 
        .result(result_shifter), 
        .leftRight(FURslt[0]),
        .shamt(IM_out[10:6]),
        .sftSrc(ALU_src2) 
);
		
Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(result_ALU),
        .data1_i(result_shifter),
        .data2_i(ZF_out),
        .select_i(FURslt),
        .data_o(RDdata)
);			

endmodule



