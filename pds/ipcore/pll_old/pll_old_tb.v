// Created by IP Generator (Version 2022.1 build 99559)



`timescale 1ns/10fs

//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//               
// Library:
// Filename:pll_old.v                 
//////////////////////////////////////////////////////////////////////////////
module pll_old_tb ();

    
    localparam real    CLKIN_FREQ      = 50.0; //@IPC float 10.0,500.0 
    
    localparam         INTERNAL_FB     = "CLKOUT0"; //@IPC enum CLKOUT0,CLKOUT1,CLKOUT2,CLKOUT3,DISABLE 
    
    localparam         EXTERNAL_FB     = "DISABLE"; //@IPC enum CLKOUT0,CLKOUT1,CLKOUT2,CLKOUT3,DISABLE 
        

    wire       clkout0       ;
    wire       clkout1       ;
    wire       clkout2       ;
    wire       clkout3       ;
    wire       lock          ;
    wire clkfb =  (EXTERNAL_FB == "DISABLE") ? 1'b0 :
    		  (EXTERNAL_FB == "CLKOUT0") ? clkout0 :
             	  (EXTERNAL_FB == "CLKOUT1") ? clkout1 :
             	  (EXTERNAL_FB == "CLKOUT2") ? clkout2 :
             	  (EXTERNAL_FB == "CLKOUT3") ? clkout3 : 1'b0;
    reg        clkin1        ;
    reg        clkin2        ;
    
    reg        clkin_sel     ;
    reg        pfden         ;
    reg  [1:0] phase_sel     ;
    reg        phase_dir     ;
    reg        phase_step_n  ;
    reg        load_phase    ;
    reg        cphase_step_n ;
    reg        clkout0_syn   ;
    reg        clkout1_syn   ;
    reg        clkout2_syn   ;
    reg        clkout3_syn   ;
    reg        stdby         ;
    reg        pll_pwd       ;
    reg        rst           ;
    reg        rstodiv       ;
    reg        rstodiv2      ;
    reg        rstodiv3      ;
    reg        apb_clk       ;
    reg        apb_rst_n     ;
    reg  [4:0] apb_addr      ;
    reg        apb_sel       ;
    reg        apb_en        ;
    reg        apb_write     ;
    reg  [7:0] apb_wdata     ; 

    initial
    begin
    
        clkin_sel     = 1'b0;
        pfden         = 1'b0;
        phase_sel     = 2'b0;
        phase_dir     = 1'b0;
        phase_step_n  = 1'b0;
        load_phase    = 1'b0;
        cphase_step_n = 1'b0;
        clkout0_syn   = 1'b0;
        clkout1_syn   = 1'b0;
        clkout2_syn   = 1'b0;
        clkout3_syn   = 1'b0;
        stdby         = 1'b0;
        rstodiv       = 1'b0;
        rstodiv2      = 1'b0;
        rstodiv3      = 1'b0;
        apb_clk       = 1'b0;
        apb_rst_n     = 1'b0;
        apb_addr      = 5'b0;
        apb_sel       = 1'b0;
        apb_en        = 1'b0;
        apb_write     = 1'b0;
        apb_wdata     = 8'b0; 
    end

    // clkin1 generation
    initial
    begin
        clkin1 = 0;
        forever #(500/CLKIN_FREQ) clkin1 = ~clkin1;
    end
    
    // clkin2 generation
    initial
    begin
        clkin2 = 1;
        forever #(500/CLKIN_FREQ) clkin2 = ~clkin2;
    end

    // reset and power down generation
    initial
    begin
        pll_pwd  = 1'b1;
        rst      = 1'b1;
        #50
        pll_pwd  = 1'b0;
        #50
        rst      = 1'b0;
    end

    pll_old U_pll_old (
    
    .clkout0(clkout0),
    
    .clkout1(clkout1),
    
    .clkin1(clkin1),
    
    .rst(rst),
    
    .lock(lock)           
    );

//******************Results Cheching************************
    reg  lock_ff1;
    reg  lock_ff2;
    reg  lock_ff3;
    reg  lock_neg;
    wire chk_ok;
    
    
    always @( posedge clkin1)
    begin
        lock_ff1 <= lock;
        lock_ff2 <= lock_ff1;
        lock_ff3 <= lock_ff2;
    end

    always @( posedge clkin1)
    begin
        if(rst==1'b1)
	    lock_neg <= 1'b0;
        else if((lock_ff2==1'b0)&&(lock_ff3==1'b1))
	    lock_neg <= 1'b1;
	else ;    
    end
    assign chk_ok = lock_ff3 & (~lock_neg);
    



    integer handle;
    initial
    begin
        #50000
        handle = $fopen ("sim_results.log","a");
        $fdisplay(handle,"chk_ok = %b,  $realtime = %-10d",chk_ok,$realtime );
	$display("Simulation Starts.") ;
	$display("Simulation is done.") ;
	if (chk_ok==1'b0)
	    $display("Simulation Failed due to Error Found.") ;
	else
	    $display("Simulation Success.") ;
        $finish;
    end

endmodule
