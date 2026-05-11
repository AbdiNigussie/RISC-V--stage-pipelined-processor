// CPU Configurations
// Here we define 0x8000_0000 ~ 0x8FFF_FFFF as the data memory space
`define MEM_ADDR_START 32'h0
`define MEM_ADDR_END   32'h400
`define XLEN 32


`define PC_LEN 32

`define REG_NUM 32
`define REG_LEN 5

`define ITYPE_OPCODE 7'b0010011
`define STYPE_OPCODE 7'b0100011
`define BTYPE_OPCODE 7'b1100011
`define UTYPE_OPCODE 7'b0110011
`define JTYPE_OPCODE 7'b1101111

`define ADDI 3'b000

`define ALU_OP_ADD 4'b0000
`define ALU_OP_SUB 4'b0001
`define ALU_OP_AND 4'b0010
`define ALU_OP_OR  4'b0011

// MMIO Configurations
// Here we define 0x9000_0000 ~ 0x9FFF_FFFF as the MMIO space


// ISA definitions
`define CTRL_SIG_LEN 13

`define INST_VALID 1'b1
`define INST_INVALID 1'b0

`define SRC1_REG 2'b00
`define SRC1_IMM 2'b01
`define SRC1_PC  2'b10
`define SRC1_X0  2'b11

`define SRC2_REG 2'b00
`define SRC2_IMM 2'b01
`define SRC2_NONE 2'b10

`define MEM_EN 1'b1
`define MEM_DIS 1'b0

`define WB_EN 1'b1
`define WB_DIS 1'b0

`define BRANCH_EN 1'b1
`define BRANCH_DIS 1'b0

`define JUMP_EN 1'b1
`define JUMP_DIS 1'b0

// ALU operation definitions
`define ALU_OP_WIDTH 4
`define ALU_OP_NOP 4'b1111
`define ALU_OP_ADD 4'b0000
`define ALU_OP_SUB 4'b0001
`define ALU_OP_AND 4'b0010
`define ALU_OP_OR  4'b0011
`define ALU_OP_XOR 4'b0100
`define ALU_OP_SLT 4'b0101  // Set less than (signed)
`define ALU_OP_SLTU 4'b0110 // Set less than unsigned
`define ALU_OP_SLL 4'b0111  // Shift left logical
`define ALU_OP_SRL 4'b1000  // Shift right logical
`define ALU_OP_SRA 4'b1001  // Shift right arithmetic
`define ALU_OP_LUI 4'b1010  // Load upper immediate
`define ALU_OP_JALR 4'b1011 // JALR: (rs1 + imm) & ~1

// Branch operation definitions
`define BRANCH_OP_WIDTH 3
`define BRANCH_OP_EQ  3'b000  // BEQ
`define BRANCH_OP_NE  3'b001  // BNE
`define BRANCH_OP_LT  3'b100  // BLT
`define BRANCH_OP_GE  3'b101  // BGE
`define BRANCH_OP_LTU 3'b110  // BLTU
`define BRANCH_OP_GEU 3'b111  // BGEU

// Memory access width
`define MEM_WIDTH_BYTE 2'b00
`define MEM_WIDTH_HALF 2'b01
`define MEM_WIDTH_WORD 2'b10

// Load sign extension
`define LOAD_SIGNED 1'b1
`define LOAD_UNSIGNED 1'b0

// Load/Store operation definitions
`define LB 3'b000   // Load byte signed
`define LH 3'b001   // Load halfword signed
`define LW 3'b010   // Load word
`define LBU 3'b100  // Load byte unsigned
`define LHU 3'b101  // Load halfword unsigned

// Read/Write memory wait states
// for XLINX BRAM: 2 wait states
`define __MEM_WAITSTATE__  2

