// remove PANGO definition, if you use vivado


// CPU Configurations
// Here we define 0x8000_0000 ~ 0x8FFF_FFFF as the data memory space
`define MEM_ADDR_START 32'h8000_0000
`define MEM_ADDR_END   32'h8FFF_FFFF
`define XLEN 32

`define PERIP_RES0_ADDR 32'h90000000
`define PERIP_RES1_ADDR 32'h90000004
`define PERIP_RES2_ADDR 32'h90000008
`define PERIP_RES3_ADDR 32'h9000000c
`define PERIP_RES4_ADDR 32'h90000010
