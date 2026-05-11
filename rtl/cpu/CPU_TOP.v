`include "CPU_define.v"

module CPU (
    input         clk,
    input         rst_n,
    input         run,

    // Interface to IROM
    output [31:0]  pc,
    input  [31:0]  instruction,

    // Interface to DRAM & MMIO
    output [31:0]  perip_addr,
    output [31:0]  perip_wdata,
    output         perip_wen,
    output [1:0]   perip_mask,
    input  [31:0]  perip_rdata
);
//draft
wire pause; // 数据冒险停顿
wire flush; // 控制冒险刷新
wire [1: 0] forwardA, forwardB; // 数据冒险旁路
wire forwardC; // 数据冒险旁路
//111
wire flush_pred;
reg flush_reg;
assign flush = flush_reg;
reg flush_pred_reg;
assign flush_pred = flush_pred_reg;

// IF阶段
wire [31: 0] if_pc; // 指令地址
//assign pc = if_pc;
wire [31: 0] if_instr; // 指令
assign if_instr = instruction;//

// id阶段
wire [31: 0] id_pc; // 指令地址
wire [31: 0] id_instruction; // 指令
wire [6: 0] id_opcode; // 操作码
wire [2: 0] id_func3; 
wire [6: 0] id_func7;
wire id_MemtoReg;
wire id_RegWrite;
wire [4:0] id_A1;
wire [4:0] id_A2;
wire [4:0] id_A3;
wire [31:0] id_RD1;
wire [31:0] id_RD2;
wire [31:0]id_imm_32;
wire [4: 0] id_aluc;
wire id_AluSrc1; //
wire [1: 0] id_AluSrc2; //判断用的
wire [1: 0] id_MemWrite; 
wire [2: 0] id_MemRead;
wire [2: 0] id_extOP;
wire [1: 0] id_PcorRs1;
wire id_lui;//针对我亲爱的lui
wire id_isBranchInstr;
// ex阶段
wire [4:  0] ex_aluc; // 控制 ALU运算
wire ex_MemtoReg; // 二路选择器
wire ex_AluSrc1; // 二路选择器
wire[1: 0] ex_AluSrc2; // 三路选择器
wire ex_RegWrite; // 寄存器写信号
wire [1: 0] ex_MemWrite; // 写内存信号
wire [2: 0] ex_MemRead; // 读内存信号
wire[1: 0] ex_PcorRs1; // 无条件跳转
wire [31: 0] ex_pc; 
wire [31: 0] ex_RD1, ex_RD2;
wire [31: 0] ex_real_RD1, ex_real_RD2;
wire [31: 0] ex_imm32;
wire [4: 0] ex_A3, ex_A1, ex_A2;
wire [31: 0] ex_pcImm, ex_rs1Imm; // 分支
wire [31: 0] ex_Result; // ALu的输出
wire ex_conditionBranch; // 条件分支
wire ex_lui;
wire [31:0] ex_Alu_data1;
wire [31:0] ex_Alu_data2;
wire ex_isBranchInstr;
// me阶段
wire [31:0] me_pc;
wire me_MemtoReg; // 二路选择器
wire me_RegWrite; // 寄存器写信号
wire [1: 0] me_MemWrite; // 写内存信号
wire [2: 0] me_MemRead; // 读内存信号
wire[1: 0] me_PcorRs1; // 无条件跳转
wire me_conditionBranch; // 条件分支
wire [31: 0] me_pcImm, me_rs1Imm; // 分支
wire [31: 0] me_Result; // ALu的输出
wire [31: 0] me_RD2;
wire [4: 0] me_A3;
wire [4: 0] me_A2;
wire [31: 0] me_real_RD2;
wire [31: 0] me_outMem;
wire me_isBranchInstr;
// wb阶段
wire wb_MemtoReg; 
wire wb_RegWrite;
wire [31: 0] wb_outMem;
wire [31: 0] wb_Result;
wire [4: 0] wb_A3;
wire [31:0] wb_WD3;

if_id IF_ID(
    .clk(clk),
    .rst(~rst_n),
    .pause(pause),
    .flush(flush || flush_pred),

    .if_pc(if_pc),
    .if_instr(if_instr),

    .id_pc(id_pc),
    .id_instr(id_instruction)
);



reg [31:0] NextPC_reg;
wire [31:0] NextPC;
assign NextPC = NextPC_reg;


//decoder 部分


 Decoder Decoder(
        .instr(id_instruction),
        .opcode(id_opcode),
        .func3(id_func3),
        .func7(id_func7),
        .rd(id_A3),
        .rs1(id_A1),
        .rs2(id_A2)
    );
    
// Control 部分



Control Control(
    .opcode(id_opcode),
    .func3(id_func3),
    .func7(id_func7),
    .aluc(id_aluc),
    .aluOut_WB_memOut(id_MemtoReg),
    .rs1Data_EX_PC(id_AluSrc1), 
    .rs2Data_EX_imm32_4(id_AluSrc2),
    .write_reg(id_RegWrite),
    .write_mem(id_MemWrite), //用于mask
    .read_mem(id_MemRead),// 用于mask，注意位宽3
    .extOP(id_extOP),
    .pcImm_NEXTPC_rs1Imm(id_PcorRs1),
    .lui(id_lui),
    .a(id_isBranchInstr)
);

//Extend部分

Extend Extend(
    .instr(id_instruction),
    .extOP(id_extOP),
    .imm_32(id_imm_32)
);
//寄存器部分   
RegisterFile RegisterFile(
            .CLK(clk),
            .WE3(wb_RegWrite),     
            .A1(id_A1),
            .A2(id_A2),
            .A3(wb_A3),
            .WD3(wb_WD3),
            .RD1(id_RD1),
            .RD2(id_RD2)
        );   
// Hazard 部分

hazard_detection_unit HAZARD_DETECTION_UNIT(
    .ex_readMem(ex_MemRead),
    .ex_rd(ex_A3),
    .id_rs1(id_A1),
    .id_rs2(id_A2),

    .pause(pause)
); 

wire [31:0] id_target_pc;
assign id_target_pc = id_pc + id_imm_32;


// ********************************
//         id_ex 寄存器
// ********************************
id_ex ID_EX(
    .clk(clk),
    .rst(~rst_n),
    .pause(pause),
    .flush(flush),

    .id_aluc(id_aluc),
    .id_aluOut_WB_memOut(id_MemtoReg),
    .id_rs1Data_EX_PC(id_AluSrc1),
    .id_rs2Data_EX_imm32_4(id_AluSrc2),
    .id_writeReg(id_RegWrite),
    .id_writeMem(id_MemWrite),
    .id_readMem(id_MemRead),
    .id_pcImm_NEXTPC_rs1Imm(id_PcorRs1),
    .id_pc(id_pc),
    .id_rs1Data(id_RD1),
    .id_rs2Data(id_RD2),
    .id_imm32(id_imm_32),
    .id_rd(id_A3),
    .id_rs1(id_A1),
    .id_rs2(id_A2),
    .id_lui(id_lui),
    .id_isBranchInstr(id_isBranchInstr),

    .ex_aluc(ex_aluc),
    .ex_aluOut_WB_memOut(ex_MemtoReg),
    .ex_rs1Data_EX_PC(ex_AluSrc1),
    .ex_rs2Data_EX_imm32_4(ex_AluSrc2),
    .ex_writeReg(ex_RegWrite),
    .ex_writeMem(ex_MemWrite),
    .ex_readMem(ex_MemRead),
    .ex_pcImm_NEXTPC_rs1Imm(ex_PcorRs1),
    .ex_pc(ex_pc),
    .ex_rs1Data(ex_RD1),
    .ex_rs2Data(ex_RD2),
    .ex_imm32(ex_imm32),
    .ex_rd(ex_A3),
    .ex_rs1(ex_A1),
    .ex_rs2(ex_A2),
    .ex_lui(ex_lui),
    .ex_isBranchInstr(ex_isBranchInstr)
);   
  
// 俺是废物
// ex阶段总结来说，就是不断的数据选择
// 处理前馈，再选择alu来源，地址跳转就不在这算了，等会把imm_32,pc,这些数据传mem过去就行
// 算了还是在这加吧
// Alu部分，这里考虑lui多加根线
// 注意在alu部分，由m，w俩个数据前馈
// 然后还有一个特殊的前馈，load，store，刚好来的及
// 写一个数据前馈

forward_unit FORWARD_UNIT(
    .me_writeReg(me_RegWrite),
    .me_rd(me_A3),
    .wb_rd(wb_A3),
    .wb_writeReg(wb_RegWrite),
    .ex_rs1(ex_A1),
    .ex_rs2(ex_A2),

   
    .me_rs2(me_A2),
    .ex_forwardA(forwardA),
    .ex_forwardB(forwardB),
    .me_forwardC(forwardC)
);


//先考虑要不要前馈
assign ex_real_RD1 = (forwardA[1]) ? wb_WD3 : (forwardA[0]) ? me_Result : ex_RD1;
assign ex_real_RD2 = (forwardB[1]) ? wb_WD3 : (forwardB[0]) ? me_Result : ex_RD2;

assign ex_Alu_data1 = (ex_lui) ?  0 : (ex_AluSrc1) ? ex_pc : ex_real_RD1;// lui 特殊处理一下,妈的真麻烦    
assign ex_Alu_data2 = (ex_AluSrc2[1]) ? 4 : (ex_AluSrc2[0]) ? ex_imm32 : ex_real_RD2;//这里也是究极shi山
// ex_pcImm,ex_rs1Imm在这把这俩傻鸟算了
assign ex_pcImm = ex_imm32 + ex_pc;
assign ex_rs1Imm = ex_imm32 + ex_real_RD1;
Alu Alu(
    .aluc(ex_aluc),
    .a(ex_Alu_data1),
    .b(ex_Alu_data2),
    .out(ex_Result),
    .condition_branch(ex_conditionBranch)
);

// ********************************
//         ex_me 寄存器
// ********************************
ex_me EX_ME(
    .clk(clk),
    .rst(~rst_n),
    .flush(flush),

    .ex_aluOut_WB_memOut(ex_MemtoReg),
    .ex_writeReg(ex_RegWrite),
    .ex_writeMem(ex_MemWrite),
    .ex_readMem(ex_MemRead),
    .ex_pcImm_NEXTPC_rs1Imm(ex_PcorRs1),
    .ex_conditionBranch(ex_conditionBranch),
    .ex_pcImm(ex_pcImm),
    .ex_rs1Imm(ex_rs1Imm),
    .ex_outAlu(ex_Result),
    .ex_rs2Data(ex_real_RD2),
    .ex_rd(ex_A3),
    .ex_rs2(ex_A2),
    .ex_isBranchInstr(ex_isBranchInstr),
    .ex_pc(ex_pc),
  

    .me_aluOut_WB_memOut(me_MemtoReg),
    .me_writeReg(me_RegWrite),
    .me_writeMem(me_MemWrite),
    .me_readMem(me_MemRead),
    .me_pcImm_NEXTPC_rs1Imm(me_PcorRs1),
    .me_conditionBranch(me_conditionBranch),
    .me_pcImm(me_pcImm),
    .me_rs1Imm(me_rs1Imm),
    .me_outAlu(me_Result),
    .me_rs2Data(me_RD2),
    .me_rd(me_A3),
    .me_rs2(me_A2),
    .me_isBranchInstr(me_isBranchInstr),
    .me_pc(me_pc)
);
Memdata u_Memdata(
    .MemRead(me_MemRead),
    .perip_rdata(perip_rdata),
    .real_rdata(me_outMem)
);
assign  me_real_RD2 = (forwardC) ?  wb_WD3 : me_RD2;
// ********************************
//         me_wb 寄存器
// ********************************
me_wb ME_WB(
    .clk(clk),
    .rst(~rst_n),
    .me_aluOut_WB_memOut(me_MemtoReg),
    .me_writeReg(me_RegWrite),
    .me_outMem(me_outMem),
    .me_outAlu(me_Result),
    .me_rd(me_A3),

    .wb_aluOut_WB_memOut(wb_MemtoReg),
    .wb_writeReg(wb_RegWrite),
    .wb_outMem(wb_outMem),
    .wb_outAlu(wb_Result),
    .wb_rd(wb_A3)
);



// PC 部分
//其实这里有考虑是封装在模块内，综合考虑后还是放外面    
//说实话，always放外面有点不美观,可放里面又觉得引线麻烦
//折中一点，赋值在这体现，加法前面写，显得不那么冗长
//注意多周期的时候这里应该用的是me阶段的，先不写BTA吧，不太会写

always @(*) begin
    if(~me_conditionBranch && me_isBranchInstr) begin
    NextPC_reg = me_pc + 4;
    flush_reg = 1'b1;
    end else if(me_PcorRs1 == 2'b10) begin
    NextPC_reg = me_rs1Imm;
    flush_reg = 1'b1;
    end else if(id_isBranchInstr) begin
    NextPC_reg = id_target_pc;
    flush_pred_reg = 1'b1;
    end
    else begin
    NextPC_reg = pc + 4;
    flush_reg = 1'b0;
    flush_pred_reg = 0;
    end
end

ProgramCounter ProgramCounter(
            .CLK(clk),
            .Reset(~rst_n),
            .flush( flush),
            .pause(pause),
            .NextPC(NextPC),
            .PC(pc),
            .if_pc(if_pc)
        );
// 内存部分
// 这里还有点麻烦
// 主要是wen信号那,唉凑合着用吧
// 所以读有符号数到底在哪实现
// 后面不行加个专门模块把数据搞出来
// 感觉躲不掉，还是直接加吧

assign perip_addr = me_Result;
assign perip_wdata = me_real_RD2;
assign perip_wen = !(me_MemWrite == 2'b11);
assign perip_mask = (perip_wen) ? me_MemWrite : me_MemRead[1:0];//别说，还挺合理的


assign wb_WD3 = (wb_MemtoReg) ?  wb_outMem : wb_Result ;

  


endmodule