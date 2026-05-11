module top(
    input           CLK,            // 100Mhz clk from crystal
    input           CPU_RESETN,     // for pll
    input           CPU_RUN,        // Enable pc incremental
    input           CPU_DEBUG,      // Debug buttom, press to show current pc
    input   [6:0]   DIP,            // sw0 ~ sw6
    output  [31:0]  DATA,           // output data for DIP switches
    output  [15:0]  LED
);

    wire [31:0] inst_addr;
    wire [31:0] instruction;
    wire RESETN;

    wire [31:0] perip_addr, perip_wdata, perip_rdata;
    wire        perip_wen;
    wire [1:0] perip_mask;

    wire        clk_50Mhz;
    wire        cpu_clk;
    
    assign clk_50Mhz = CLK;
    assign cpu_clk = CLK;
    assign RESETN = CPU_RESETN;
    
    CPU u_cpu (
        .clk            (cpu_clk        ),
        .rst_n          (RESETN     ),
        .run            (1'b1),

        .pc             (inst_addr      ),
        .instruction    (instruction    ),

        .perip_addr     (perip_addr     ),
        .perip_wdata    (perip_wdata    ),
        .perip_wen      (perip_wen      ),
        .perip_mask     (perip_mask     ),
        .perip_rdata    (perip_rdata    )
    );

    benchmark u_benchmark(
        .CLK  	        (clk_50Mhz  ),
        .CPU_RESETN 	(RESETN     ),
        .CPU_DEBUG      (CPU_DEBUG  ),
        .CPU_RUN        (1'b1       ),
        .DIP            (DIP        ),
        // IROM Interface
        .inst_clk       (cpu_clk          ),
        .inst_addr  	(inst_addr        ),
        .instruction	(instruction      ),
        // DRAM & MMIO Interface
        .perip_clk   	(cpu_clk          ),
        .perip_addr 	(perip_addr       ),
        .perip_wdata	(perip_wdata      ),
        .perip_wen  	(perip_wen        ),
        .perip_mask 	(perip_mask       ),
        .perip_rdata	(perip_rdata      )
    );

    assign LED = inst_addr[15:0];

    assign DATA = u_benchmark.seg_data;

endmodule

