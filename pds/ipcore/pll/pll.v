

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
// Filename:pll.v                 
//////////////////////////////////////////////////////////////////////////////
module pll (
    
    clkout0,
    
    clkout1,
    
    clkin1,
    
    rst,
    
    lock           
    );

    
    localparam real    CLKIN_FREQ      = 50.0; //@IPC float 10.0,500.0 
    
    localparam         PFDEN_EN        = "FALSE"; //@IPC bool 
    
    localparam         PFDEN_APB_EN    = "FALSE"; //@IPC bool 
    
    localparam         LOCK_MODE       = 0; //@IPC enum 0,1
    
    localparam integer STATIC_RATIOI   = 1; //@IPC int 1,128 
    
    localparam integer STATIC_RATIO0   = 8; //@IPC int 1,128 
    
    localparam integer STATIC_RATIO1   = 16; //@IPC int 1,128 
    
    localparam integer STATIC_RATIO2   = 8; //@IPC int 1,128 
    
    localparam integer STATIC_RATIO3   = 8; //@IPC int 1,128 
    
    localparam integer STATIC_RATIOF   = 1; //@IPC int 1,128 
    
    localparam         FRACN_EN        = "FALSE"; //@IPC bool 
    
    localparam integer FRACN_DIV       = 0; //@IPC int 0,65535 
    
    localparam         PHASE_APB_EN    = "FALSE"; //@IPC bool 
    
    localparam integer STATIC_PHASE0   = 0; //@IPC int 0,7 
    
    localparam integer STATIC_PHASE1   = 0; //@IPC int 0,7 
    
    localparam integer STATIC_PHASE2   = 0; //@IPC int 0,7 
    
    localparam integer STATIC_PHASE3   = 0; //@IPC int 0,7 
    
    localparam integer STATIC_CPHASE0  = 0; //@IPC int 0,127 
    
    localparam integer STATIC_CPHASE1  = 0; //@IPC int 0,127 
    
    localparam integer STATIC_CPHASE2  = 0; //@IPC int 0,127 
    
    localparam integer STATIC_CPHASE3  = 0; //@IPC int 0,127 
    
    localparam         VCOCLK_BYPASS0  = "FALSE"; //@IPC bool 
    
    localparam         VCOCLK_BYPASS1  = "FALSE"; //@IPC bool 
    
    localparam         VCOCLK_BYPASS2  = "FALSE"; //@IPC bool 
    
    localparam         VCOCLK_BYPASS3  = "FALSE"; //@IPC bool 
    
    localparam integer ODIV0_CLKIN_SEL = 0; //@IPC enum 0,1,2,3 
    
    localparam integer ODIV1_CLKIN_SEL = 0; //@IPC enum 0,1,2,3 
    
    localparam integer ODIV2_CLKIN_SEL = 0; //@IPC enum 0,1,2,3 
    
    localparam integer ODIV3_CLKIN_SEL = 0; //@IPC enum 0,1,2,3 
    
    localparam         CLKOUT0_SEL     = 0; //@IPC enum 0,1,2,3,4 
    
    localparam         CLKOUT1_SEL     = 0; //@IPC enum 0,1,2,3,4 
    
    localparam         CLKOUT2_SEL     = 0; //@IPC enum 0,1,2,3,4 
    
    localparam         CLKOUT3_SEL     = 0; //@IPC enum 0,1,2,3,4 
    
    localparam         CLKOUT0_SYN_EN  = "FALSE"; //@IPC bool 
    
    localparam         CLKOUT1_SYN_EN  = "FALSE"; //@IPC bool 
    
    localparam         CLKOUT2_SYN_EN  = "FALSE"; //@IPC bool 
    
    localparam         CLKOUT3_SYN_EN  = "FALSE"; //@IPC bool 
    
    localparam         INTERNAL_FB     = "CLKOUT0"; //@IPC enum CLKOUT0,CLKOUT1,CLKOUT2,CLKOUT3,DISABLE 
    
    localparam         EXTERNAL_FB     = "DISABLE"; //@IPC enum CLKOUT0,CLKOUT1,CLKOUT2,CLKOUT3,DISABLE 
    
    localparam         BANDWIDTH       = "OPTIMIZED"; //@IPC enum OPTIMIZED,LOW,HIGH 
    
    localparam         STDBY_EN        = "FALSE"; //@IPC bool 
    
    localparam         RST_INNER_EN    = "TRUE"; //@IPC bool 
    
    localparam         RSTODIV_EN      = "FALSE"; //@IPC bool 
    
    localparam         RSTODIV2_EN     = "FALSE"; //@IPC bool 
    
    localparam         RSTODIV3_EN     = "FALSE"; //@IPC bool 
    
    output      clkout0       ;
    
    output      clkout1       ;
    
    input       clkin1        ;
    
    input       rst           ;
    
    output      lock          ; 

    wire       clkout        ;
    wire       clkout0       ;
    wire       clkout1       ;
    wire       clkout2       ;
    wire       clkout3       ;
    wire       phase_source  ;  // Never used
    wire       lock          ;
    wire       clkin1        ;
    wire       clkin2        ;
    wire       clkfb         ;
    wire       clkin_sel     ;
    wire       pfden         ;
    wire [1:0] phase_sel     ;
    wire       phase_dir     ;
    wire       phase_step_n  ;
    wire       load_phase    ;
    wire       cphase_step_n ;
    wire       clkout0_syn   ;
    wire       clkout1_syn   ;
    wire       clkout2_syn   ;
    wire       clkout3_syn   ;
    wire       stdby         ;
    wire       pll_pwd       ;
    wire       rst           ;
    wire       rstodiv       ;
    wire       rstodiv2      ;
    wire       rstodiv3      ;
    wire       apb_clk       ;
    wire       apb_rst_n     ;
    wire [4:0] apb_addr      ;
    wire       apb_sel       ;
    wire       apb_en        ;
    wire       apb_write     ;
    wire [7:0] apb_wdata     ; 

    
    assign clkin2        = 1'b0;
    
    assign clkfb         = 1'b0;
    
    assign clkin_sel     = 1'b0;
    
    assign pfden         = 1'b0;
    
    assign phase_sel     = 2'b0;
    assign phase_dir     = 1'b0;
    assign phase_step_n  = 1'b0;
    assign load_phase    = 1'b0;
    assign cphase_step_n = 1'b0;
    
    assign clkout0_syn   = 1'b0;
    
    assign clkout1_syn   = 1'b0;
    
    assign clkout2_syn   = 1'b0;
    
    assign clkout3_syn   = 1'b0;
    
    assign stdby         = 1'b0;
    
    assign pll_pwd       = 1'b0;
    
    assign rstodiv       = 1'b0;
    
    assign rstodiv2      = 1'b0;
    
    assign rstodiv3      = 1'b0;
    
    assign apb_clk       = 1'b0;
    assign apb_rst_n     = 1'b0;
    assign apb_addr      = 5'b0;
    assign apb_sel       = 1'b0;
    assign apb_en        = 1'b0;
    assign apb_write     = 1'b0;
    assign apb_wdata     = 8'b0; 
    

GTP_PLL_E2 #(
    .CLKIN_FREQ      (CLKIN_FREQ      ),
    .PFDEN_EN        (PFDEN_EN        ),
    .PFDEN_APB_EN    (PFDEN_APB_EN    ),
    .LOCK_MODE       (LOCK_MODE       ),
    .STATIC_RATIOI   (STATIC_RATIOI   ),
    .STATIC_RATIO0   (STATIC_RATIO0   ),
    .STATIC_RATIO1   (STATIC_RATIO1   ),
    .STATIC_RATIO2   (STATIC_RATIO2   ),
    .STATIC_RATIO3   (STATIC_RATIO3   ),
    .STATIC_RATIOF   (STATIC_RATIOF   ),
    .FRACN_EN        (FRACN_EN        ),
    .FRACN_DIV       (FRACN_DIV       ),
    .PHASE_APB_EN    (PHASE_APB_EN    ),
    .STATIC_PHASE0   (STATIC_PHASE0   ),
    .STATIC_PHASE1   (STATIC_PHASE1   ),
    .STATIC_PHASE2   (STATIC_PHASE2   ),
    .STATIC_PHASE3   (STATIC_PHASE3   ),
    .STATIC_CPHASE0  (STATIC_CPHASE0  ),
    .STATIC_CPHASE1  (STATIC_CPHASE1  ),
    .STATIC_CPHASE2  (STATIC_CPHASE2  ),
    .STATIC_CPHASE3  (STATIC_CPHASE3  ),
    .VCOCLK_BYPASS0  (VCOCLK_BYPASS0  ),
    .VCOCLK_BYPASS1  (VCOCLK_BYPASS1  ),
    .VCOCLK_BYPASS2  (VCOCLK_BYPASS2  ),
    .VCOCLK_BYPASS3  (VCOCLK_BYPASS3  ),
    .ODIV0_CLKIN_SEL (ODIV0_CLKIN_SEL ),
    .ODIV1_CLKIN_SEL (ODIV1_CLKIN_SEL ),
    .ODIV2_CLKIN_SEL (ODIV2_CLKIN_SEL ),
    .ODIV3_CLKIN_SEL (ODIV3_CLKIN_SEL ),
    .CLKOUT0_SEL     (CLKOUT0_SEL     ),
    .CLKOUT1_SEL     (CLKOUT1_SEL     ),
    .CLKOUT2_SEL     (CLKOUT2_SEL     ),
    .CLKOUT3_SEL     (CLKOUT3_SEL     ),
    .CLKOUT0_SYN_EN  (CLKOUT0_SYN_EN  ),
    .CLKOUT1_SYN_EN  (CLKOUT1_SYN_EN  ),
    .CLKOUT2_SYN_EN  (CLKOUT2_SYN_EN  ),
    .CLKOUT3_SYN_EN  (CLKOUT3_SYN_EN  ),
    .INTERNAL_FB     (INTERNAL_FB     ),
    .EXTERNAL_FB     (EXTERNAL_FB     ),
    .BANDWIDTH       (BANDWIDTH       ),
    .STDBY_EN        (STDBY_EN        ),
    .RST_INNER_EN    (RST_INNER_EN    ),
    .RSTODIV_EN      (RSTODIV_EN      ),
    .RSTODIV2_EN     (RSTODIV2_EN     ),
    .RSTODIV3_EN     (RSTODIV3_EN     ) 
    ) u_pll_e2 (
    .CLKOUT        (clkout        ),
    .CLKOUT0       (clkout0       ),
    .CLKOUT1       (clkout1       ),
    .CLKOUT2       (clkout2       ),
    .CLKOUT3       (clkout3       ),
    .PHASE_SOURCE  (phase_source  ),
    .LOCK          (lock          ),
    .CLKIN1        (clkin1        ),
    .CLKIN2        (clkin2        ),
    .CLKFB         (clkfb         ),
    .CLKIN_SEL     (clkin_sel     ),
    .PFDEN         (pfden         ),
    .PHASE_SEL     (phase_sel     ),
    .PHASE_DIR     (phase_dir     ),
    .PHASE_STEP_N  (phase_step_n  ),
    .LOAD_PHASE    (load_phase    ),
    .CPHASE_STEP_N (cphase_step_n ),
    .CLKOUT0_SYN   (clkout0_syn   ),
    .CLKOUT1_SYN   (clkout1_syn   ),
    .CLKOUT2_SYN   (clkout2_syn   ),
    .CLKOUT3_SYN   (clkout3_syn   ),
    .STDBY         (stdby         ),
    .PLL_PWD       (pll_pwd       ),
    .RST           (rst           ),
    .RSTODIV       (rstodiv       ),
    .RSTODIV2      (rstodiv2      ),
    .RSTODIV3      (rstodiv3      ),
    .APB_CLK       (apb_clk       ),
    .APB_RST_N     (apb_rst_n     ),
    .APB_ADDR      (apb_addr      ),
    .APB_SEL       (apb_sel       ),
    .APB_EN        (apb_en        ),
    .APB_WRITE     (apb_write     ),
    .APB_WDATA     (apb_wdata     )
    );


endmodule    
