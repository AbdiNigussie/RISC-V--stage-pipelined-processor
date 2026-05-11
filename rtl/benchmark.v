`timescale 1ns / 1ps
`include "define.v"


module benchmark(
        input CLK               , // 50MHz clock
        input CPU_RESETN        ,
        input CPU_DEBUG         ,
        input CPU_RUN           ,
        input [6:0] DIP         ,

        // 7 Seg display
        output [7:0] anode      ,
        output SevenSegDP       ,
        output [6:0] SevenSegCathode,

        // IROM interface
        input inst_clk          ,
        input [31:0] inst_addr  ,
        output [31:0] instruction,

        // DRAM & MMIO interface
        input        perip_clk  ,
        input [31:0] perip_addr ,
        input [31:0] perip_wdata,
        input perip_wen         ,
        input [1:0] perip_mask  ,
        output [31:0] perip_rdata
    );
    
    // IROM Instance
`ifdef IVERILOG
    IROM Mem_IROM (
        .addr       (inst_addr >> 2),
        .rd_data    (instruction)
    );
`else 
`ifdef PANGO
    IROM Mem_IROM (
      .addr(inst_addr >> 2),// input [9:0]
      .clk(inst_clk),       // input
      .rst(1'b0),           // input
      .rd_data(instruction) // output [31:0]
    );
`else 
    IROM Mem_IROM (
        .a          (inst_addr >> 2),
        .spo        (instruction)
    );
`endif
`endif // IVERILOG
    
    wire In_Mem;
    wire dram_wen;
    wire [31:0] dram_wdata;
    wire [31:0] dram_rdata;

    assign In_Mem = (perip_addr >= `MEM_ADDR_START) && (perip_addr <= `MEM_ADDR_END);
    assign dram_wen = perip_wen & In_Mem;
    assign dram_wdata = perip_wdata;
    assign  perip_rdata = dram_rdata;

    // DRAM Instance
    dram_driver dram_driver_inst (
        // .clk                (CLK),
        .clk				(perip_clk),
        .rstn               (CPU_RESETN),
        .perip_addr			(perip_addr),
        .perip_wdata		(perip_wdata),
        .perip_mask			(perip_mask),
        .dram_wen 			(dram_wen),
        .perip_rdata		(dram_rdata)
    );

    // seg test
    reg [31:0] result [4:0];
    
    wire test_finish = CPU_RUN & (result[3] != 32'h0000_0000);

    always @(posedge perip_clk or negedge CPU_RESETN) begin
        if (~CPU_RESETN) begin
            result[0] <= 32'h0000_0000;
            result[1] <= 32'h0000_0000;
            result[2] <= 32'h0000_0000;
            result[3] <= 32'h0000_0000;
            result[4] <= 32'h0000_0000;
        end  
        else if (perip_wen && (perip_addr == `PERIP_RES0_ADDR)) begin
            result[0] <= perip_wdata; 
        end
        else if (perip_wen && (perip_addr == `PERIP_RES1_ADDR)) begin
            result[1] <= perip_wdata; 
        end
        else if (perip_wen && (perip_addr == `PERIP_RES2_ADDR)) begin
            result[2] <= perip_wdata; 
        end
        else if (perip_wen && (perip_addr == `PERIP_RES3_ADDR)) begin
            result[3] <= perip_wdata; 
        end 
        else if (perip_wen && (perip_addr == `PERIP_RES4_ADDR)) begin
            result[4] <= perip_wdata; 
        end 
    end

    // 1us timer & run time counter
    reg [7:0] cnt_1us;
    wire posedge_1us = (cnt_1us == 8'd49);

    always @(posedge CLK or negedge CPU_RESETN) begin
        if (~CPU_RESETN) begin
            cnt_1us <= 8'h00;
        end 
        else if (posedge_1us) begin
            cnt_1us <= 8'h00;
        end
        else begin
            cnt_1us <= cnt_1us + 1;
        end 
    end

    reg [31:0] run_time; // us
    always @(posedge CLK or negedge CPU_RESETN) begin
        if (~CPU_RESETN) begin
            run_time <= 32'h0000_0000;
        end 
        else if (CPU_RUN && posedge_1us && (~test_finish)) begin
            run_time <= run_time + 1;
        end 
    end


    reg [31:0] seg_data;
    always @(posedge CLK or negedge CPU_RESETN) begin
        if (~CPU_RESETN) begin
            seg_data = 32'h0000_0000;
        end 
        else if (CPU_DEBUG) begin
            seg_data = inst_addr;
        end 
        else if (DIP[0]) begin 
            seg_data = result[0];
        end
        else if (DIP[1]) begin 
            seg_data = result[1];
        end
        else if (DIP[2]) begin 
            seg_data = result[2];
        end
        else if (DIP[3]) begin 
            seg_data = result[3];
        end
        else if (DIP[4]) begin 
            seg_data = result[4];
        end
        else if (test_finish) begin
            seg_data = run_time;
        end
        else begin
            seg_data = 32'h0000_0000;
        end
    end

    seven_seg u_seven_seg(
        .clk(CLK),
        .rstn(CPU_RESETN),
        .data(seg_data),
        .SevenSegDP(SevenSegDP),
        .anode(anode),
        .SevenSegCathode(SevenSegCathode)
    );


endmodule