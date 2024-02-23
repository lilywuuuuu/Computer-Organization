module Pipeline_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signals
wire ALUSrc, ALUSrc_IDEX;
wire Jump, Jump_IDEX, Jump_EXMEM;
wire Branch, Branch_IDEX, Branch_EXMEM;
wire BranchType, BranchType_IDEX;
wire MemWrite, MemWrite_IDEX, MemWrite_EXMEM;
wire MemRead, MemRead_IDEX, MemRead_EXMEM; 
wire RegWrite, RegWrite_IDEX, RegWrite_EXMEM, RegWrite_MEMWB;
wire isZero, isZero_EXMEM;
wire PCSrc, zero, overflow;
wire [1:0]  MemtoReg, MemtoReg_IDEX, MemtoReg_EXMEM;
wire [1:0] RegDst, RegDst_IDEX, MemtoReg_MEMWB, FURslt;
wire [2:0] ALUOp, ALUOp_IDEX;
wire [3:0] ALU_operation;
wire [4:0] WriteReg_addr, WriteReg_addr_EXMEM, WriteReg_addr_MEMWB;
wire [27:0] Jump_shift2;
wire [31:0] PCAdder_out, PCAdder_out_IFID, PCAdder_out_IDEX, PCAdder_out_EXMEM;
wire [31:0] instr, instr_IFID, instr_IDEX, instr_EXMEM;
wire [31:0] RSdata, RTdata, RSdata_IDEX, RTdata_IDEX, RTdata_EXMEM;
wire [31:0] WriteDataMemory, WriteDataMemory_EXMEM, WriteDataMemory_MEMWB;
wire [31:0] PC_in, PC_out, WriteData, DataMemory_out, DataMemory_out_MEMWB, ALUSrcData;
wire [31:0] signextend, signextend_IDEX, result_shifter, result_ALU, Jump_addr;
wire [31:0] Branch_addr, Branch_addr_temp, Branch_addr_temp_EXMEM;


// IF 
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

// IF/ID Pipe Register

Pipe_Reg #(.size(32*2)) IFID(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({PCAdder_out, instr}),
        .data_o({PCAdder_out_IFID, instr_IFID})
);

// ID			
Reg_File RF( 
        .clk_i(clk_i),      
        .rst_n(rst_n),     
        .RSaddr_i(instr_IFID[25:21]),  
        .RTaddr_i(instr_IFID[20:16]),  
        .Wrtaddr_i(WriteReg_addr_MEMWB),  
        .Wrtdata_i(WriteData), 
        .RegWrite_i(RegWrite_MEMWB),
        .RSdata_o(RSdata),  
        .RTdata_o(RTdata)   
); 
 	
Decoder Decoder( 
        .instr_op_i(instr_IFID[31:26]), 
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

Sign_Extend SE( 
        .data_i(instr_IFID[15:0]),
        .data_o(signextend)
);

// ID/EX Pipe Register

Pipe_Reg #(.size(32*5 + 1*7 + 2*2 + 3*1)) IDEX(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({PCAdder_out_IFID, instr_IFID, signextend, 
                RSdata, RTdata, Jump, ALUOp, ALUSrc, Branch, 
                BranchType, MemWrite, MemRead, MemtoReg, RegDst, RegWrite}),
        .data_o({PCAdder_out_IDEX, instr_IDEX, signextend_IDEX, 
                RSdata_IDEX, RTdata_IDEX, Jump_IDEX, ALUOp_IDEX, 
                ALUSrc_IDEX, Branch_IDEX, BranchType_IDEX, MemWrite_IDEX, 
                MemRead_IDEX, MemtoReg_IDEX, RegDst_IDEX, RegWrite_IDEX})
);

// EX
Mux2to1 #(.size(32)) Mux_ALUSrc( 
        .data0_i(RTdata_IDEX),
        .data1_i(signextend_IDEX),
        .select_i(ALUSrc_IDEX),
        .data_o(ALUSrcData)
);

ALU_Ctrl AC( 
        .funct_i(instr_IDEX[5:0]),   
        .ALUOp_i(ALUOp_IDEX),   
        .ALU_operation_o(ALU_operation),
        .FURslt_o(FURslt)
);

ALU ALU( 
        .aluSrc1(RSdata_IDEX),
        .aluSrc2(ALUSrcData),
        .ALU_operation_i(ALU_operation),
        .result(result_ALU),
        .zero(zero),
        .overflow(overflow)
);

Adder Adder_Branch( 
        .src1_i(PCAdder_out_IDEX),     
        .src2_i(signextend_IDEX << 2),
        .sum_o(Branch_addr_temp)
);	
		
Shifter shifter( 
        .leftRight(FURslt[1]),
        .shamt(instr_IDEX[10:6]),
        .sftSrc(ALUSrcData),
        .result(result_shifter)
);

Mux2to1 #(.size(5)) Mux_RegDst( 
        .data0_i(instr_IDEX[20:16]), // rt
        .data1_i(instr_IDEX[15:11]), // rd
        .select_i(RegDst_IDEX[0]),
        .data_o(WriteReg_addr)
);
		
Mux2to1 #(.size(32)) Write_Data_Source( 
        .data0_i(result_ALU),
        .data1_i(result_shifter),
        .select_i(FURslt[0]),
        .data_o(WriteDataMemory)
);
		
Mux2to1 #(.size(1)) Mux_BranchType( 
        .data0_i(zero),
        .data1_i(!zero),
        .select_i(BranchType_IDEX),
        .data_o(isZero)
);

// EX/MEM Pipe Register

Pipe_Reg #(.size(32*5 + 1*6 + 2*1 + 5*1)) EXMEM(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({Branch_addr_temp, isZero, WriteDataMemory, 
                RTdata_IDEX, WriteReg_addr, PCAdder_out_IDEX, 
                instr_IDEX, Jump_IDEX, Branch_IDEX, MemWrite_IDEX, 
                MemRead_IDEX, MemtoReg_IDEX, RegWrite_IDEX}),
        .data_o({Branch_addr_temp_EXMEM, isZero_EXMEM, 
                WriteDataMemory_EXMEM, RTdata_EXMEM, WriteReg_addr_EXMEM, 
                PCAdder_out_EXMEM, instr_EXMEM, Jump_EXMEM, Branch_EXMEM, 
                MemWrite_EXMEM, MemRead_EXMEM, MemtoReg_EXMEM, RegWrite_EXMEM})
);

// MEM
Data_Memory DM( 
        .clk_i(clk_i), 
        .addr_i(WriteDataMemory_EXMEM), 
        .data_i(RTdata_EXMEM), 
        .MemRead_i(MemRead_EXMEM), 
        .MemWrite_i(MemWrite_EXMEM), 
        .data_o(DataMemory_out)
);

and U0 (PCSrc, Branch_EXMEM, isZero_EXMEM);
Mux2to1 #(.size(32)) Mux_PCSrc( 
        .data0_i(PCAdder_out_EXMEM),
        .data1_i(Branch_addr_temp_EXMEM),
        .select_i(PCSrc),
        .data_o(Branch_addr)
);

Mux2to1 #(.size(32)) Mux_Jump_or_Branch( 
        .data0_i(Branch_addr),
        .data1_i({PCAdder_out_EXMEM[31:28], instr_EXMEM[25:0], 2'b0}),
        .select_i(Jump_EXMEM),
        .data_o(PC_in)
);

// MEM/WB Pipe Register

Pipe_Reg #(.size(32*2 + 5*1 + 2*1 + 1*1)) MEMWB(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({WriteDataMemory_EXMEM, MemtoReg_EXMEM, 
                DataMemory_out, WriteReg_addr_EXMEM, RegWrite_EXMEM}),
        .data_o({WriteDataMemory_MEMWB, MemtoReg_MEMWB, 
                DataMemory_out_MEMWB, WriteReg_addr_MEMWB, RegWrite_MEMWB})
);

// WB
Mux2to1 #(.size(32)) Mux_MemtoReg( 
        .data0_i(WriteDataMemory_MEMWB),
        .data1_i(DataMemory_out_MEMWB),
        .select_i(MemtoReg_MEMWB[0]),
        .data_o(WriteData)
);


endmodule



