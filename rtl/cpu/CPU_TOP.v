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
wire pause; // Stall for a data hazard
wire flush; // Flush for a control hazard
wire [1: 0] forwardA, forwardB; // Forwarding for data hazards
wire forwardC; // Forwarding for data hazards
//111
wire flush_pred;
reg flush_reg;
assign flush = flush_reg;
reg flush_pred_reg;
assign flush_pred = flush_pred_reg;

// IF stage
wire [31: 0] if_pc; // Instruction address
//assign pc = if_pc;
wire [31: 0] if_instr; // Instruction
assign if_instr = instruction;//

// ID stage
wire [31: 0] id_pc; // Instruction address
wire [31: 0] id_instruction; // Instruction
wire [6: 0] id_opcode; // Opcode
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
wire [1: 0] id_AluSrc2; //ALU operand selection control
wire [1: 0] id_MemWrite; 
wire [2: 0] id_MemRead;
wire [2: 0] id_extOP;
wire [1: 0] id_PcorRs1;
wire id_lui;//Special handling for LUI
wire id_isBranchInstr;
// EX stage
wire [4:  0] ex_aluc; // ALU operation control
wire ex_MemtoReg; // 2-to-1 multiplexer control
wire ex_AluSrc1; // 2-to-1 multiplexer control
wire[1: 0] ex_AluSrc2; // 3-to-1 multiplexer control
wire ex_RegWrite; // Register write enable
wire [1: 0] ex_MemWrite; // Memory write control
wire [2: 0] ex_MemRead; // Memory read control
wire[1: 0] ex_PcorRs1; // Unconditional jump
wire [31: 0] ex_pc; 
wire [31: 0] ex_RD1, ex_RD2;
wire [31: 0] ex_real_RD1, ex_real_RD2;
wire [31: 0] ex_imm32;
wire [4: 0] ex_A3, ex_A1, ex_A2;
wire [31: 0] ex_pcImm, ex_rs1Imm; // Branch
wire [31: 0] ex_Result; // ALU output
wire ex_conditionBranch; // Conditional branch
wire ex_lui;
wire [31:0] ex_Alu_data1;
wire [31:0] ex_Alu_data2;
wire ex_isBranchInstr;
// MEM stage
wire [31:0] me_pc;
wire me_MemtoReg; // 2-to-1 multiplexer control
wire me_RegWrite; // Register write enable
wire [1: 0] me_MemWrite; // Memory write control
wire [2: 0] me_MemRead; // Memory read control
wire[1: 0] me_PcorRs1; // Unconditional jump
wire me_conditionBranch; // Conditional branch
wire [31: 0] me_pcImm, me_rs1Imm; // Branch
wire [31: 0] me_Result; // ALU output
wire [31: 0] me_RD2;
wire [4: 0] me_A3;
wire [4: 0] me_A2;
wire [31: 0] me_real_RD2;
wire [31: 0] me_outMem;
wire me_isBranchInstr;
// WB stage
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


//Decoder section


 Decoder Decoder(
        .instr(id_instruction),
        .opcode(id_opcode),
        .func3(id_func3),
        .func7(id_func7),
        .rd(id_A3),
        .rs1(id_A1),
        .rs2(id_A2)
    );
    
// Control section



Control Control(
    .opcode(id_opcode),
    .func3(id_func3),
    .func7(id_func7),
    .aluc(id_aluc),
    .aluOut_WB_memOut(id_MemtoReg),
    .rs1Data_EX_PC(id_AluSrc1), 
    .rs2Data_EX_imm32_4(id_AluSrc2),
    .write_reg(id_RegWrite),
    .write_mem(id_MemWrite), //Used for masking
    .read_mem(id_MemRead),// Used for masking; note the 3-bit width
    .extOP(id_extOP),
    .pcImm_NEXTPC_rs1Imm(id_PcorRs1),
    .lui(id_lui),
    .a(id_isBranchInstr)
);

//Immediate extension section

Extend Extend(
    .instr(id_instruction),
    .extOP(id_extOP),
    .imm_32(id_imm_32)
);
//Register file section
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
// Hazard handling section

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
//         id_ex pipeline register
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
  
// I am hopeless at this.
// The EX stage is essentially a sequence of data selections.
// Handle forwarding, then select ALU operands; initially, jump targets were to be computed in MEM using imm_32 and pc.
// On second thought, compute them here instead.
// ALU section: add an extra signal for LUI.
// ALU inputs can be forwarded from the MEM and WB stages.
// There is also a special load-to-store forwarding path; the data arrives just in time.
// Implement data forwarding.

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


//First determine whether forwarding is needed.
assign ex_real_RD1 = (forwardA[1]) ? wb_WD3 : (forwardA[0]) ? me_Result : ex_RD1;
assign ex_real_RD2 = (forwardB[1]) ? wb_WD3 : (forwardB[0]) ? me_Result : ex_RD2;

assign ex_Alu_data1 = (ex_lui) ?  0 : (ex_AluSrc1) ? ex_pc : ex_real_RD1;// Special-case LUI; this is a real nuisance.
assign ex_Alu_data2 = (ex_AluSrc2[1]) ? 4 : (ex_AluSrc2[0]) ? ex_imm32 : ex_real_RD2;//This is another particularly messy expression.
// Compute both ex_pcImm and ex_rs1Imm here.
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
//         ex_me pipeline register
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
//         me_wb pipeline register
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



// PC section
//Considered encapsulating this in a module, but ultimately kept it outside.
//Keeping the always block outside looks awkward, but putting it inside complicates the wiring.
//As a compromise, keep assignments here and additions above to reduce clutter.
//For multicycle operation, use the MEM-stage values here; BTA is omitted for now because its implementation is unclear.

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
// Memory section
// This section is still somewhat awkward.
// The main difficulty is the wen signal; keep the current approach for now.
// Where should signed-load handling be implemented?
// If necessary, add a dedicated module to extract the data.
// A dedicated module seems unavoidable, so add it now.

assign perip_addr = me_Result;
assign perip_wdata = me_real_RD2;
assign perip_wen = !(me_MemWrite == 2'b11);
assign perip_mask = (perip_wen) ? me_MemWrite : me_MemRead[1:0];//This selection is actually quite reasonable.


assign wb_WD3 = (wb_MemtoReg) ?  wb_outMem : wb_Result ;

  


endmodule