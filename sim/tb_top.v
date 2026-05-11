`timescale 1ns / 1ps
module tb_Top();

    reg clk;
    reg rst_n;

    reg [6:0] DIP = 7'b0;

    wire [15:0] LED;
    wire [31:0] DATA;

    top dut (
        .CLK        (clk        ),
        .CPU_RESETN (rst_n      ),
        .CPU_DEBUG  (1'b0       ),
        .CPU_RUN    (1'b1       ),
        .DIP        (DIP        ),
        .LED        (LED        )
    );
    
    initial begin 
        clk = 0; 
        forever #1 clk = ~clk;
    end

    initial begin
    
        rst_n = 0;
        #10;
        rst_n = 1;

        #100000 $finish;
        // @(posedge dut.u_benchmark.test_finish) #100;

        @(posedge clk) begin
            DIP = 7'b0000001;
            #100;
        end
        @(posedge clk) begin
            DIP = 7'b0000010;
            #100;
        end
        @(posedge clk) begin
            DIP = 7'b0000100;
            #100;
        end
        @(posedge clk) begin
            DIP = 7'b0001000;
            #100;
        end
        #100 $finish;
    end

    // DONT modify following initial code block,
    // that output waveform file
    initial begin
        $dumpfile("testbench.wave");
        $dumpvars;
        $display("save to testbench.wave");
    end 

endmodule
