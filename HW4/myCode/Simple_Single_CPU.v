module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signals
wire ALUSrc, zero, RegWrite, overflow, isZero;
wire Jump, Branch, BranchType, MemWrite, MemRead, PCSrc;
wire [1:0] RegDst, MemtoReg, FURslt;
wire [2:0] ALUOp;
wire [3:0] ALU_operation;
wire [4:0] WriteReg_addr;
wire [27:0] Jump_shift2;
wire [31:0] PC_in, PC_out, PCAdder_out, instr, WriteData, WriteDataMemory, DataMemory_out, RSdata, RTdata, ALUSrcData;
wire [31:0] signextend, zerofilled, result_shifter, result_ALU, Jump_addr, Branch_addr, Branch_addr_temp;

//modules
Program_Counter PC( 
        .clk_i(clk_i),      
        .rst_n(rst_n),     
        .pc_in_i(PC_in), 
        .pc_out_o(PC_out) 
);
	
Adder PCAdder( 
        .src1_i(PC_out),     
        .src2_i(32'd4),
        .sum_o(PCAdder_out)
);
	
Instr_Memory IM( 
        .pc_addr_i(PC_out),  
        .instr_o(instr)    
);

Mux2to1 #(.size(5)) Mux_RegDst( 
        .data0_i(instr[20:16]), // rt
        .data1_i(instr[15:11]), // rd
        .select_i(RegDst[0]),
        .data_o(WriteReg_addr)
);	
		
Reg_File RF( 
        .clk_i(clk_i),      
        .rst_n(rst_n),     
        .RSaddr_i(instr[25:21]),  
        .RTaddr_i(instr[20:16]),  
        .RDaddr_i(WriteReg_addr),  
        .RDdata_i(WriteData), 
        .RegWrite_i(RegWrite),
        .RSdata_o(RSdata),  
        .RTdata_o(RTdata)   
); 
 	
Decoder Decoder( 
        .instr_op_i(instr[31:26]), 
        .Jump_o(Jump),
        .ALUOp_o(ALUOp), 
        .ALUSrc_o(ALUSrc),
        .Branch_o(Branch),
        .BranchType_o(BranchType),
        .MemWrite_o(MemWrite),
        .MemRead_o(MemRead),
        .MemtoReg_o(MemtoReg),
        .RegWrite_o(RegWrite), 
        .RegDst_o(RegDst)   
);

ALU_Ctrl AC( 
        .funct_i(instr[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALU_operation_o(ALU_operation),
        .FURslt_o(FURslt)
);
	
Sign_Extend SE( 
        .data_i(instr[15:0]),
        .data_o(signextend)
);

Zero_Filled ZF( 
        .data_i(instr[15:0]),
        .data_o(zerofilled)
);
		
Mux2to1 #(.size(32)) Mux_ALUSrc( 
        .data0_i(RTdata),
        .data1_i(signextend),
        .select_i(ALUSrc),
        .data_o(ALUSrcData)
);	
		
ALU ALU( 
        .aluSrc1(RSdata),
        .aluSrc2(ALUSrcData),
        .ALU_operation_i(ALU_operation),
        .result(result_ALU),
        .zero(zero),
        .overflow(overflow)
);

Mux2to1 #(.size(1)) Mux_BranchType( 
        .data0_i(zero),
        .data1_i(!zero),
        .select_i(BranchType),
        .data_o(isZero)
);
		
Shifter shifter( 
        .result(result_shifter), 
        .leftRight(FURslt[1]),
        .shamt(instr[10:6]),
        .sftSrc(ALUSrcData) 
);
		
Mux2to1 #(.size(32)) Write_Data_Source( 
        .data0_i(result_ALU),
        .data1_i(result_shifter),
        .select_i(FURslt[0]),
        .data_o(WriteDataMemory)
);

Data_Memory DM( 
        .clk_i(clk_i), 
        .addr_i(WriteDataMemory), 
        .data_i(RTdata), 
        .MemRead_i(MemRead), 
        .MemWrite_i(MemWrite), 
        .data_o(DataMemory_out)
);

Mux2to1 #(.size(32)) Mux_MemtoReg( 
        .data0_i(WriteDataMemory),
        .data1_i(DataMemory_out),
        .select_i(MemtoReg[0]),
        .data_o(WriteData)
);

Adder Adder_Branch( 
        .src1_i(PCAdder_out),     
        .src2_i(signextend << 2),
        .sum_o(Branch_addr_temp)
);

and U0 (PCSrc, Branch, isZero);
Mux2to1 #(.size(32)) Mux_PCSrc( 
        .data0_i(PCAdder_out),
        .data1_i(Branch_addr_temp),
        .select_i(PCSrc),
        .data_o(Branch_addr)
);

Mux2to1 #(.size(32)) Mux_Jump_or_Branch( 
        .data0_i(Branch_addr),
        .data1_i({PCAdder_out[31:28], instr[25:0], 2'b0}),
        .select_i(Jump),
        .data_o(PC_in)
);

endmodule



