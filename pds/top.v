`include "../rtl/define.v"

module top(
    input           CLK,            // 100Mhz clk from crystal
    input           CPU_RESETN,     // for pll
    input           CPU_RUN,        // Enable pc incremental
    input           CPU_DEBUG,      // Debug buttom, press to show current pc
    input   [6:0]   DIP,            //  sw0 ~ sw6
    output  [7:0]   SevenSegAn,     // 7 Seg anodes
    output [15:0]   SevenSegCatHL,  // 7 Seg cathodes x2 = high part + low part
    output  [7:0]   LED             // LED light display. Display the value of program counter.
);
    wire RESETN;
    wire [31:0] inst_addr;
    wire [31:0] instruction;

    wire [31:0] perip_addr, perip_wdata, perip_rdata;
    wire        perip_wen;
    wire [1:0]  perip_mask;
    
    wire        pll_lock;
    wire        clk_50Mhz;
    wire        cpu_clk;

`ifdef PDS_LITE
    pll pll_inst
    (
        .rst(1'b0),        // reset input, high acitve 
        .clkin1(CLK),
        .clkout0(clk_50Mhz),
        .clkout1(cpu_clk),
        .lock(pll_lock)             //here we use locked signal to reset cpu
    );
`else 
    pll_old pll_inst
    (
        .rst(1'b0),        // reset input, high acitve 
        .clkin1(CLK),
        .clkout0(clk_50Mhz),
        .clkout1(cpu_clk),
        .lock(pll_lock)             //here we use locked signal to reset cpu
    );
`endif
    
    assign RESETN = CPU_RESETN & pll_lock;

    CPU u_cpu (
        .clk            (cpu_clk        ),
        .rst_n          (RESETN         ),
        .run            (1'b1           ),

        .pc             (inst_addr      ),
        .instruction    (instruction    ),

        .perip_addr     (perip_addr     ),
        .perip_wdata    (perip_wdata    ),
        .perip_wen      (perip_wen      ),
        .perip_mask     (perip_mask     ),
        .perip_rdata    (perip_rdata    )
    );

    wire dp; 
    wire [6:0] cathode;
    wire [7:0] anode;

    benchmark u_benchmark(
        .CLK  	        (clk_50Mhz   ),
        .CPU_RESETN 	(RESETN      ),
        .CPU_DEBUG      (CPU_DEBUG   ),
        .CPU_RUN        (1'b1        ),
        .DIP            (DIP         ),
        .anode      	(anode       ),
        .SevenSegDP     (dp          ),
        .SevenSegCathode(cathode     ),
        // IROM Interface
        .inst_clk       (cpu_clk     ),
        .inst_addr  	(inst_addr   ),
        .instruction	(instruction ),
        // DRAM & MMIO Interface
        .perip_clk      (cpu_clk   ),
        .perip_addr 	(perip_addr  ),
        .perip_wdata	(perip_wdata ),
        .perip_wen  	(perip_wen   ),
        .perip_mask 	(perip_mask  ),
        .perip_rdata	(perip_rdata )
    );

    assign SevenSegAn = anode;
    
    assign SevenSegCatHL = ((&anode[3:0]) == 1'b0) ? {8'hff, dp, cathode} : {dp, cathode, 8'hff};
    
    assign LED = inst_addr[9:2];

endmodule

