module top(
    input           CLK,            // 100Mhz clk from crystal
    input           CPU_RESETN,     // for pll
    input           CPU_RUN,        // Enable pc incremental
    input           CPU_DEBUG,      // Debug buttom, press to show current pc
    input   [6:0]   DIP,            //  sw0 ~ sw6
    output  [7:0]   SevenSegAn,     // Seg interface
    output          SevenSegDP,
    output  [6:0]   SevenSegCathode,
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

    pll pll_inst
    (
        .clk_in1(CLK),
        .clk_out1(clk_50Mhz),
        .clk_out2(cpu_clk),
        .resetn(CPU_RESETN),
        .locked(RESETN)             //here we use locked signal to reset cpu
    );
    
    CPU u_cpu (
        .clk            (cpu_clk       ),
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
        .CLK  	        (clk_50Mhz          ),
        .CPU_RESETN 	(RESETN       ),
        .CPU_DEBUG     (CPU_DEBUG            ),
        .CPU_RUN       (1'b1             ),
        .DIP           (DIP           ),
        // 7 Seg display
        .anode      	(SevenSegAn            ),
        .SevenSegDP    (SevenSegDP        ),
        .SevenSegCathode (SevenSegCathode   ),
        // IROM Interface
        .inst_clk       (cpu_clk          ),
        .inst_addr  	(inst_addr        ),
        .instruction	(instruction      ),
        // DRAM & MMIO Interface
        .perip_clk   	(~cpu_clk        ),//小巧思，你就学吧
        .perip_addr 	(perip_addr       ),
        .perip_wdata	(perip_wdata      ),
        .perip_wen  	(perip_wen        ),
        .perip_mask 	(perip_mask       ),
        .perip_rdata	(perip_rdata      )
    );

    assign LED = inst_addr[15:0];

endmodule

