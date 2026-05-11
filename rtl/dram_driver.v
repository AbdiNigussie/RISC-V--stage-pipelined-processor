`timescale 1ns / 1ps
`include "define.v"

// DRAM Driver Module
// Implements RISC-V Load/Store Unit memory interface
// Supports LW/LH/LHU/LB/LBU loads and SW/SH/SB stores
module dram_driver(
    input          clk,
    input          rstn,
    input  [31:0]  perip_addr,        // Byte address from CPU
    input  [31:0]  perip_wdata,       // Write data from CPU
    input  [1:0]   perip_mask,        // Access size: 00=byte, 01=half, 10=word
    input          dram_wen,          // Write enable
    output reg [31:0]  perip_rdata    // Read data to CPU
);

    // Internal signals
    reg [3:0]  dram_wea;                  // Byte enable for DRAM (4 bits for 4 bytes)
    wire [9:0] dram_addr;                 // Word address for DRAM (10-bit for 1024 words)
    reg [31:0] dram_wdata;                // Write data to DRAM
    wire [31:0] dram_rdata;                // Read data from DRAM

    // Address calculation: convert byte address to word address
    // For 10-bit DRAM address, we use bits [11:2] which gives us 1024 words (4KB)
    // Bits [1:0] are byte offset within the word
    assign dram_addr = perip_addr[11:2];

    // assign dram_wdata = perip_wdata;
    always @(*) begin
        if (~dram_wen) begin
            dram_wdata = 32'b0; // No write
        end
        else begin 
            case (perip_mask)
                2'b00: begin
                    if (perip_addr[1:0] == 2'b00) 
                        dram_wdata = perip_wdata;       // Byte at byte 0
                    else if (perip_addr[1:0] == 2'b01) 
                        dram_wdata = perip_wdata << 8;  // Byte at byte 1
                    else if (perip_addr[1:0] == 2'b10) 
                        dram_wdata = perip_wdata << 16; // Byte at byte 2
                    else 
                        dram_wdata = perip_wdata << 24; // Byte at byte 3
                end 
                2'b01: begin
                    if (perip_addr[1:0] == 2'b00) 
                        dram_wdata = perip_wdata;       // Half at byte 0-1
                    else 
                        dram_wdata = perip_wdata << 16; // Half at byte 2-3
                end
                2'b10: dram_wdata = perip_wdata;    // Word
                default: dram_wdata = 32'b0;          // No write
            endcase
        end
    end

    always @(*) begin
        if (~dram_wen) begin
            dram_wea = 4'b0000; // No write
        end
        else begin 
            case (perip_mask)
                2'b00: dram_wea = 4'b0001 << perip_addr[1:0]; // Byte
                2'b01: dram_wea = 4'b0011 << perip_addr[1:0]; // Half
                2'b10: dram_wea = 4'b1111;   // Word
                default: dram_wea = 4'b0000; // No write
            endcase
        end
    end

    // DRAM instantiation (supports both PANGO and Xilinx)
`ifdef IVERILOG 
    DRAM Mem_DRAM (
        .wr_data(dram_wdata),               // input [31:0]
        .addr(dram_addr),                   // input [9:0]
        .wr_en(dram_wen),                   // input
        .wr_byte_en(dram_wea),              // input [3:0]
        .clk(clk),                          // input
        .rst(~rstn),                        // input
        .rd_data(dram_rdata)                // output [31:0]
    );
`else 
`ifdef PANGO
    DRAM Mem_DRAM (
        .wr_data(dram_wdata),               // input [31:0]
        .addr(dram_addr),                   // input [9:0]
        .wr_en(dram_wen),                   // input
        .wr_byte_en(dram_wea),              // input [3:0]
        .clk(clk),                          // input
        .rst(~rstn),                        // input
        .rd_data(dram_rdata)                // output [31:0]
    );
`else 
    DRAM Mem_DRAM (
        .clka(clk),                         // input
        .rsta(~rstn),                       // input (not used)
        .ena(1'b1),                         // input (always enabled)
        .wea(dram_wea),                     // input
        .addra(dram_addr),                  // input [9:0]
        .dina(dram_wdata),                  // input [31:0]
        .douta(dram_rdata),                 // output [31:0]
        .rsta_busy()                        // output (not used)
    );
`endif
`endif // IVERILOG

    // assign perip_rdata = dram_rdata;
    always @(*) begin
        case (perip_mask)
            2'b00: begin
                if (perip_addr[1:0] == 2'b00) 
                    perip_rdata = {24'b0, dram_rdata[7:0]};         // Byte at byte 0
                else if (perip_addr[1:0] == 2'b01) 
                    perip_rdata = {24'b0, dram_rdata[15:8]};        // Byte at byte 1
                else if (perip_addr[1:0] == 2'b10) 
                    perip_rdata = {24'b0, dram_rdata[23:16]};       // Byte at byte 2
                else 
                    perip_rdata = {24'b0, dram_rdata[31:24]};       // Byte at byte 3
            end 
            2'b01: begin
                if (perip_addr[1:0] == 2'b00) 
                    perip_rdata = {16'b0, dram_rdata[15:0]};  // Half at byte 0-1
                else 
                    perip_rdata = {16'b0, dram_rdata[31:16]}; // Half at byte 2-3
            end
            2'b10: perip_rdata = dram_rdata;       // Word
            default: perip_rdata = 32'b0;          // No write
        endcase
    end


endmodule
