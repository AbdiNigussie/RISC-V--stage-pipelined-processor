// Created by IP Generator (Version 2022.1 build 99559)


//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:ipmc_spram.v
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module ipmc_spram_v1_3_DRAM
 #(
    parameter  c_CAS_STATUS     = 0             ,
    parameter  c_ADDR_WIDTH     = 10            ,  //write address width legal value:9~20 
    parameter  c_DATA_WIDTH     = 32            ,  //write data width legal value:1~1152
    parameter  c_OUTPUT_REG     = 0             ,  //output register legal value:0 or 1
    parameter  c_RD_OCE_EN      = 0             ,
    parameter  c_CLK_EN         = 0             ,
    parameter  c_ADDR_STROBE_EN = 0             ,
    parameter  c_RESET_TYPE     = "ASYNC"       ,  //legal valve "ASYNC" "SYNC" "ASYNC"
    parameter  c_POWER_OPT      = 0             ,  //0 :normal mode  1:low power mode legal value:0 or 1
    parameter  c_CLK_OR_POL_INV = 0             ,  //clk polarity invert for output register legal value 1 or 0
    parameter  c_INIT_FILE      = "NONE"        ,  //legal value:"NONE" or "initial file name"
    parameter  c_INIT_FORMAT    = "BIN"         ,  //initial data format legal valve: "bin" or "hex"
    parameter  c_WR_BYTE_EN     = 0             ,  //byte write enable legal value: 0 or 1
    parameter  c_BE_WIDTH       = 8             ,  //byte width legal value: 1~128
    parameter  c_RAM_MODE       = "SINGLE_PORT" ,
    parameter  c_WRITE_MODE     = "NORMAL_WRITE"   //"NORMAL_WRITE"; // TRANSPARENT_WRITE READ_BEFORE_WRITE
 )
  (
    input  wire [c_ADDR_WIDTH-1 : 0]  addr        ,
    input  wire [c_DATA_WIDTH-1 : 0]  wr_data     ,
    output wire [c_DATA_WIDTH-1 : 0]  rd_data     ,
    input  wire                       wr_en       ,
    input  wire                       clk         ,
    input  wire                       clk_en      ,
    input  wire                       addr_strobe ,
    input  wire                       rst         ,
    input  wire [c_BE_WIDTH-1 : 0]    wr_byte_en  ,
    input  wire                       rd_oce
  );

//*************************************************************************************************************************************************************


localparam INIT_EN = 1 ; // @IPC bool

localparam RST_VAL_EN = 0 ; // @IPC bool

`include "DRAM_init_param.v"

//********************************************************************************************************************************************************************
//declare localparam
 //L_DATA_WIDTH is the parameter value of DATA_WIDTH_A and DATA_WIDTH_B in a instance DRM ,define witch type DRM to instance in noraml mode
//********************************************************************************************************************************************************************
localparam  c_WR_BYTE_WIDTH = c_WR_BYTE_EN ? c_DATA_WIDTH/(c_BE_WIDTH==0 ? 1 : c_BE_WIDTH) : (c_DATA_WIDTH%9 ==0 ? 9 : c_DATA_WIDTH%8 ==0 ? 8 : 9 );

localparam  N_DATA_WIDTH = c_ADDR_WIDTH <= 9  ? (((c_ADDR_STROBE_EN == 1) || (c_WRITE_MODE != "NORMAL_WRITE")) ? (c_DATA_WIDTH%9 == 0 ? 9 : c_DATA_WIDTH%8 == 0 ? 8 : 9 ) : (c_DATA_WIDTH%9 == 0 ? 18 : c_DATA_WIDTH%8 == 0 ? 16 : 18)):
                           c_ADDR_WIDTH == 10 ? (c_DATA_WIDTH%9 == 0 ? 9  : c_DATA_WIDTH%8 == 0 ? 8 : 9 ):   //cascade with 1k*9   type DRM
                           c_ADDR_WIDTH == 11 ? 4:                                 //cascade with 2k*4   type DRM
                           c_ADDR_WIDTH == 12 ? 2:                                 //cascade with 4k*2   type DRM
                           c_ADDR_WIDTH == 13 ? 1:                                 //cascade with 8k*1   type DRM
                                                1;                                 //cascade with 16k*1  type DRM

localparam  L_DATA_WIDTH = c_DATA_WIDTH == 1  ? 1:                 //cascade with 8k*1   type DRM
                           c_DATA_WIDTH == 2  ? 2:                 //cascade with 4k*2   type DRM
                           c_DATA_WIDTH <= 4  ? 4:                 //cascade with 2k*4   type DRM
                           c_DATA_WIDTH <= 8  ? 8:                 //cascade with 1k*8   type DRM
                           c_DATA_WIDTH == 9  ? 9:                 //cascade with 1k*9   type DRM
                           c_DATA_WIDTH%9 == 0 ? (((c_ADDR_STROBE_EN == 1) || (c_WRITE_MODE != "NORMAL_WRITE")) ? 9 : 18) :
                           c_DATA_WIDTH%8 == 0 ? (((c_ADDR_STROBE_EN == 1) || (c_WRITE_MODE != "NORMAL_WRITE")) ? 8 : 16)
                                               : (((c_ADDR_STROBE_EN == 1) || (c_WRITE_MODE != "NORMAL_WRITE")) ? 9 : 18);
//********************************************************************************************************************************************************************
//BYTE ENABLE parameter 
//byte_enable && WIDTH_RATIO = 1
localparam  N_BYTE_DATA_WIDTH = c_WR_BYTE_WIDTH == 8 ? 16 : 18;

localparam  L_BYTE_DATA_WIDTH = c_WR_BYTE_WIDTH == 8 ? 16 : 18;

//DRM_DATA_WIDTH is the  port parameter  of DRM
localparam  DRM_DATA_WIDTH  = c_WR_BYTE_EN == 1 ? L_BYTE_DATA_WIDTH :
                              c_POWER_OPT  == 1 ? L_DATA_WIDTH : N_DATA_WIDTH;

localparam  DATA_LOOP_NUM  = (c_DATA_WIDTH%DRM_DATA_WIDTH == 0) ? (c_DATA_WIDTH/DRM_DATA_WIDTH):(c_DATA_WIDTH/DRM_DATA_WIDTH + 1);

localparam  Q_DATA_WIDTH  = (DRM_DATA_WIDTH == 18) ? 9 : (DRM_DATA_WIDTH == 16) ? 8 : DRM_DATA_WIDTH;

//DRM_ADDR_WIDTH is the ADDR_WIDTH of INSTANCE DRM primitives 
localparam  DRM_ADDR_WIDTH = DRM_DATA_WIDTH == 1  ? ((c_CAS_STATUS == 1) ? 14 : 13):
                             DRM_DATA_WIDTH == 2  ? 12:
                             DRM_DATA_WIDTH == 4  ? 11:
                             DRM_DATA_WIDTH == 8  ? 10:
                             DRM_DATA_WIDTH == 9  ? 10:
                             DRM_DATA_WIDTH == 16 ?  9:
                                                     9;

localparam  ADDR_WIDTH = c_ADDR_WIDTH > DRM_ADDR_WIDTH ? c_ADDR_WIDTH : DRM_ADDR_WIDTH;
//CS_ADDR_WIDTH is the CS address width to choose the DRM18K CS_ADDR_WIDTH=  [ extra-addres + cs[2]+csp[1]+cs[0] ]
localparam  CS_ADDR_WIDTH = ADDR_WIDTH - DRM_ADDR_WIDTH;

//ADDR_LOOP_NUM difine how many loops to cascade the c_ADDR_WIDTH
localparam  ADDR_LOOP_NUM  = 2**CS_ADDR_WIDTH;
//CAS_DATA_WIDTH is the cascaded  data width 
localparam  CAS_DATA_WIDTH   = DRM_DATA_WIDTH*DATA_LOOP_NUM;
localparam  Q_CAS_DATA_WIDTH = Q_DATA_WIDTH*DATA_LOOP_NUM;

localparam  WR_BYTE_WIDTH    =  c_WR_BYTE_EN == 1 ? c_WR_BYTE_WIDTH :
                             ( (DRM_DATA_WIDTH >=8 || DRM_DATA_WIDTH >=9 ) ? ((c_DATA_WIDTH%9 == 0) ? 9 : 8 ) : 1 );

//MASK_NUM the mask base value 
localparam  MASK_NUM  = ( DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH == 16 ) ? (ADDR_LOOP_NUM > 4 ? 2 : 4 ):
                        ( ADDR_LOOP_NUM >8 ) ? (( DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH == 16 ) ? 2 : 4) : 8;

//parameter  check
initial begin
   if( c_ADDR_WIDTH>20 || c_ADDR_WIDTH<9  ) begin
      $display("IPSpecCheck: 03030300 ipmc_flex_spram parameter setting error !!!: c_ADDR_WIDTH must between 9-20")/* PANGO PAP_CRITICAL_WARNING */;
      //$finish;
   end 
   else if( c_DATA_WIDTH>1152 || c_DATA_WIDTH<1 ) begin
      $display("IPSpecCheck: 03030301 ipmc_flex_spram parameter setting error !!!: c_DATA_WIDTH must between 1-1152")/* PANGO PAP_CRITICAL_WARNING */;
      //$finish;
   end 
   else if ( c_CAS_STATUS!=0 && c_CAS_STATUS!=1 ) begin
      $display("IPSpecCheck: 03030303 ipmc_flex_spram parameter setting error !!!: c_CAS_STATUS must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_ADDR_STROBE_EN!=0 && c_ADDR_STROBE_EN!=1 ) begin
      $display("IPSpecCheck: 03030304 ipmc_flex_spram parameter setting error !!!: c_ADDR_STROBE_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_CLK_EN!=0 && c_CLK_EN!=1 ) begin
      $display("IPSpecCheck: 03030305 ipmc_flex_spram parameter setting error !!!: c_CLK_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_RD_OCE_EN!=0 && c_RD_OCE_EN!=1 ) begin
      $display("IPSpecCheck: 03030306 ipmc_flex_spram parameter setting error !!!: c_RD_OCE_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( c_OUTPUT_REG!=1 && c_OUTPUT_REG!=0 ) begin
      $display("IPSpecCheck: 03030307 ipmc_flex_spram parameter setting error !!!: c_OUTPUT_REG must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end 
   else if( c_CLK_OR_POL_INV!=1 && c_CLK_OR_POL_INV!=0 ) begin
      $display("IPSpecCheck: 03030308 ipmc_flex_spram parameter setting error !!!: c_CLK_OR_POL_INV must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end 
   else if ( c_RD_OCE_EN==1 && c_OUTPUT_REG==0 )begin
      $display("IPSpecCheck: 03030309 ipmc_flex_spram parameter setting error !!!: c_OUTPUT_REG must be 1 when c_RD_OCE_EN is 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_CLK_OR_POL_INV==1 && c_OUTPUT_REG==0 )begin
      $display("IPSpecCheck: 03030310 ipmc_flex_spram parameter setting error !!!: c_OUTPUT_REG must be 1 when c_CLK_OR_POL_INV is 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( (c_WR_BYTE_EN==1 && (c_ADDR_STROBE_EN==1 || c_WRITE_MODE!="NORMAL_WRITE"))) begin
      $display("IPSpecCheck: 03030311 ipmc_flex_spram parameter setting error !!!: Byte Write only works when c_ADDR_STROBE_EN is 0 and c_WRITE_MODE is NORMAL_WRITE")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_WR_BYTE_EN==0 && c_ADDR_STROBE_EN==1 && c_WRITE_MODE!="NORMAL_WRITE" ) begin
      $display("IPSpecCheck: 03030312 ipmc_flex_spram parameter setting error !!!: When Byte Write disabled, Address Strobe only works when c_WRITE_MODE is NORMAL_WRITE")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( c_RESET_TYPE!="ASYNC" && c_RESET_TYPE!="SYNC") begin
      $display("IPSpecCheck: 03030313 ipmc_flex_spram parameter setting error !!!: c_RESET_TYPE must be ASYNC or SYNC ")/* PANGO PAP_ERROR */;
      $finish;
   end 
   else if( c_POWER_OPT!=1 && c_POWER_OPT!=0 ) begin
      $display("IPSpecCheck: 03030314 ipmc_flex_spram parameter setting error !!!: c_POWER_OPT must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( c_INIT_FORMAT!="BIN" && c_INIT_FORMAT!="HEX" ) begin
      $display("IPSpecCheck: 03030315 ipmc_flex_spram parameter setting error !!!: c_INIT_FORMAT must be bin or hex ")/* PANGO PAP_ERROR */;
      $finish;
   end 
   else if( c_WR_BYTE_EN!=0 && c_WR_BYTE_EN!=1 ) begin
      $display("IPSpecCheck: 03030316 ipmc_flex_spram parameter setting error !!!: c_WR_BYTE_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if( c_WRITE_MODE!="NORMAL_WRITE" && c_WRITE_MODE!="TRANSPARENT_WRITE" && c_WRITE_MODE!="READ_BEFORE_WRITE" ) begin
         $display("IPSpecCheck: 03030319 ipmc_flex_spram parameter setting error !!!: c_WRITE_MODE must be NORMAL_WRITE or TRANSPARENT_WRITE or READ_BEFORE_WRITE")/* PANGO PAP_ERROR */;
         $finish;
   end
   else if( c_WR_BYTE_EN==1 ) begin
      if( c_WR_BYTE_WIDTH!=8 &&  c_WR_BYTE_WIDTH!=9 ) begin
         $display("IPSpecCheck: 03030317 ipmc_flex_spram parameter setting error !!!: c_WR_BYTE_WIDTH must be 8 or 9")/* PANGO PAP_ERROR */;
         $finish;
      end
      if( (c_DATA_WIDTH%8)!=0 && (c_DATA_WIDTH%9)!=0 ) begin
         $display("IPSpecCheck: 03030318 ipmc_flex_spram parameter setting error !!!: c_DATA_WIDTH must be 8*N or 9*N")/* PANGO PAP_ERROR */;
         $finish;
      end	
   end   
end
//main code
//********************************************************************************************************************************************************
//inner variables

wire [CAS_DATA_WIDTH-1:0]                  wr_data_bus   ;
reg  [Q_CAS_DATA_WIDTH-1:0]                da_data_bus   ;        //the data bus of data_cascaded instance DRM
wire [Q_CAS_DATA_WIDTH*ADDR_LOOP_NUM-1:0]  qa_data_bus   ;        //the total data width of instance DRM
wire [ADDR_WIDTH-1:0]                      addr_bus      ;
reg  [DATA_LOOP_NUM*14-1:0]                drm_addr      ;        //write address to all instance DRM
reg                                        cs_bit0       ;        //write cs[0]  to all instance DRM
reg  [ADDR_LOOP_NUM-1:0]                   cs_bit1_bus   ;        //write cs[1]  to all instance DRM
reg  [ADDR_LOOP_NUM-1:0]                   cs_bit2_bus   ;        //write cs[2] bus  to every data_cascaded DRM-block

wire                                       wr_en_b       ;
wire                                       clk_en_b      ;
reg  [CAS_DATA_WIDTH*ADDR_LOOP_NUM-1:0]    rd_data_bus   ;
reg  [Q_CAS_DATA_WIDTH-1:0]                db_data_bus   ;        //the data bus of data_cascaded instance DRM
wire [Q_CAS_DATA_WIDTH*ADDR_LOOP_NUM-1:0]  qb_data_bus   ;        //the total data width of instance DRM
reg  [DATA_LOOP_NUM*14-1:0]                drm_b_addr    ;
reg                                        csb_bit0      ;        //write cs[0]  to all instance DRM
reg  [ADDR_LOOP_NUM-1:0]                   csb_bit1_bus  ;        //write cs[1]  to all instance DRM
reg  [ADDR_LOOP_NUM-1:0]                   csb_bit2_bus  ;        //write cs[2] bus  to every data_cascaded DRM-block

//byte enable 
wire [CAS_DATA_WIDTH/WR_BYTE_WIDTH-1 : 0]  wr_byte_en_bus;

wire [DATA_LOOP_NUM*ADDR_LOOP_NUM-1:0]     cas_caout     ;
wire [DATA_LOOP_NUM*ADDR_LOOP_NUM-1:0]     cas_cbout     ;
//********************************************************************************************************************************************************
//write data mux 
assign  wr_data_bus[CAS_DATA_WIDTH-1:0] = {{(CAS_DATA_WIDTH-c_DATA_WIDTH){1'b0}},wr_data[c_DATA_WIDTH-1:0]};

assign  addr_bus[ADDR_WIDTH-1:0] = {{(ADDR_WIDTH-c_ADDR_WIDTH){1'b0}},addr[c_ADDR_WIDTH-1:0]};
  //drive wr_byte_en_bus 
assign  wr_byte_en_bus = (c_WR_BYTE_EN == 0) ? -1 : {{(CAS_DATA_WIDTH/WR_BYTE_WIDTH-c_DATA_WIDTH/WR_BYTE_WIDTH){1'b0}},wr_byte_en[c_BE_WIDTH-1:0]};

//generate drm_addr connect to the instance DRM directly ,based on DRM_DATA_WIDTH
integer gen_wa;
always@(*) begin
   for(gen_wa=0;gen_wa < DATA_LOOP_NUM;gen_wa = gen_wa +1 ) begin
      case(DRM_DATA_WIDTH)
         1     : begin
                     drm_addr[gen_wa*14 +: 14]   = (c_CAS_STATUS == 1) ? addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0] : {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0]};
                     drm_b_addr[gen_wa*14 +: 14] = (c_CAS_STATUS == 1) ? addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0] : {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0]};
                 end
         2     : begin
                     drm_addr[gen_wa*14 +: 14]   = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],1'b0};
                     drm_b_addr[gen_wa*14 +: 14] = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],1'b0};
                 end
         4     : begin
                     drm_addr[gen_wa*14 +: 14]   = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],2'b00};
                     drm_b_addr[gen_wa*14 +: 14] = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],2'b00};
                 end
         8,9   : begin
                     drm_addr[gen_wa*14 +: 14]   = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],3'b000};
                     drm_b_addr[gen_wa*14 +: 14] = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],3'b000};
                 end
         16,18 : begin
                     if(c_WRITE_MODE != "NORMAL_WRITE")
                     begin
                        drm_addr[gen_wa*14 +: 14]   = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],2'b00,wr_byte_en_bus[gen_wa*2 +: 2]};
                        drm_b_addr[gen_wa*14 +: 14] = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],2'b10,wr_byte_en_bus[gen_wa*2 +: 2]};
                     end
                     else begin
                        drm_addr[gen_wa*14 +: 14]   = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],2'b00,wr_byte_en_bus[gen_wa*2 +: 2]};
                        drm_b_addr[gen_wa*14 +: 14] = {1'b1, addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],2'b00,wr_byte_en_bus[gen_wa*2 +: 2]};
                     end
                 end
         default: begin
                      drm_addr[gen_wa*14 +: 14]   = 14'b0;
                      drm_b_addr[gen_wa*14 +: 14] = 14'b0;
                  end
      endcase
   end
end

localparam  CS_ADDR_3_LSB = (CS_ADDR_WIDTH >= 3) ? (ADDR_WIDTH-CS_ADDR_WIDTH+1) : (ADDR_WIDTH-2);  //avoid reveral index of wr_addr_bus
localparam  CS_ADDR_4_LSB = (CS_ADDR_WIDTH >= 4) ? (ADDR_WIDTH-1-CS_ADDR_WIDTH+3) : (ADDR_WIDTH-2); //avoid reveral index of wr_addr_bus

//generate  CS control signal
integer gen_m;
always@(*) begin
    for(gen_m=0;gen_m<ADDR_LOOP_NUM;gen_m=gen_m+1) begin
      if(DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH == 16) begin
        if(CS_ADDR_WIDTH == 0) begin
            cs_bit0 = 0;
            cs_bit1_bus[gen_m] = 0;
            if(c_WRITE_MODE != "NORMAL_WRITE")
                cs_bit2_bus[gen_m] = 1'b1;
            else
                cs_bit2_bus[gen_m] = 1'b0;
         end
         else if(CS_ADDR_WIDTH == 1) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];//ADDR_WIDTH-CS_ADDR_WIDTH=DRM_ADDR_WIDTH;
            cs_bit1_bus[gen_m] = 0;
            if(c_WRITE_MODE != "NORMAL_WRITE")
                cs_bit2_bus[gen_m] = 1'b1;
            else
                cs_bit2_bus[gen_m] = 1'b0;
         end
         else if(CS_ADDR_WIDTH == 2) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];//ADDR_WIDTH-CS_ADDR_WIDTH=DRM_ADDR_WIDTH;
            cs_bit1_bus[gen_m] = addr_bus[ADDR_WIDTH-1];
            if(c_WRITE_MODE != "NORMAL_WRITE")
                cs_bit2_bus[gen_m] = 1'b1;
            else
                cs_bit2_bus[gen_m] = 1'b0;
         end
         else if(CS_ADDR_WIDTH >= 3) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];//ADDR_WIDTH-CS_ADDR_WIDTH=DRM_ADDR_WIDTH;
            cs_bit1_bus[gen_m] = (addr_bus[(ADDR_WIDTH-1):CS_ADDR_3_LSB] == (gen_m/2)) ? 0:1;
            if(c_WRITE_MODE != "NORMAL_WRITE")
                cs_bit2_bus[gen_m] = 1'b1;
            else
                cs_bit2_bus[gen_m] = 1'b0;
         end
      end
      else begin
         if(CS_ADDR_WIDTH == 0) begin
            cs_bit0 = 0;
            cs_bit1_bus[gen_m] = 0;
            cs_bit2_bus[gen_m] = 0;
         end 
         else if(CS_ADDR_WIDTH == 1) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];
            cs_bit1_bus[gen_m] = 0;
            cs_bit2_bus[gen_m] = 0;
         end 
         else if(CS_ADDR_WIDTH == 2) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-2];
            cs_bit1_bus[gen_m] = addr_bus[ADDR_WIDTH-1];
            cs_bit2_bus[gen_m] = 0;
         end 
         else if(CS_ADDR_WIDTH == 3) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-3];
            cs_bit1_bus[gen_m] = addr_bus[ADDR_WIDTH-2];
            cs_bit2_bus[gen_m] = addr_bus[ADDR_WIDTH-1];
         end 
         else if(CS_ADDR_WIDTH >= 4) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];
            cs_bit1_bus[gen_m] = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH+1];
            cs_bit2_bus[gen_m] = (addr_bus[(ADDR_WIDTH-1):CS_ADDR_4_LSB] == (gen_m/4)) ? 0 : 1;
         end
      end
   end
end

//B port CS
always@(*) begin
   if(DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH == 16)
      csb_bit0 = cs_bit0 ;
   else
      csb_bit0 = 0;
end

always@(*) begin
   if(DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH == 16)
      csb_bit1_bus = cs_bit1_bus ;
   else
      csb_bit1_bus = 'b0;
end

always@(*) begin
   if(DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH == 16)
      csb_bit2_bus = cs_bit2_bus;
   else
      csb_bit2_bus = 'b0;
end

wire [18*DATA_LOOP_NUM*ADDR_LOOP_NUM-1:0]  QA_bus;
wire [18*DATA_LOOP_NUM*ADDR_LOOP_NUM-1:0]  QB_bus;
wire [18*DATA_LOOP_NUM-1:0]                DA_bus;
wire [18*DATA_LOOP_NUM-1:0]                DB_bus;

integer  drm_d_i;
always@(*) begin
   for (drm_d_i = 0; drm_d_i <DATA_LOOP_NUM; drm_d_i = drm_d_i+1) begin
      db_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] = 'b0;
      da_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] = 'b0;
      if(DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH == 16)
         {db_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] ,da_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH]} = wr_data_bus[drm_d_i*DRM_DATA_WIDTH +:DRM_DATA_WIDTH];
      else begin
         da_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] = wr_data_bus[drm_d_i*DRM_DATA_WIDTH +:DRM_DATA_WIDTH];
         db_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] = 'b0;
      end
   end
end

localparam RAM_MODE_SEL       = (c_RAM_MODE == "ROM") ? "ROM"
                                                      : ((DRM_DATA_WIDTH > 9) && (c_WRITE_MODE != "NORMAL_WRITE")) ? "TRUE_DUAL_PORT"   : "SINGLE_PORT";
localparam DRM_DATA_WIDTH_SEL = (c_RAM_MODE == "ROM") ? DRM_DATA_WIDTH
                                                      : ((DRM_DATA_WIDTH > 9) && (c_WRITE_MODE != "NORMAL_WRITE")) ? (DRM_DATA_WIDTH/2) : DRM_DATA_WIDTH;

//generate constructs: ADDR_LOOP to cascade request address  and  DATA LOOP to cascade request data
genvar gen_i,gen_j;
generate 
  for(gen_j=0;gen_j<ADDR_LOOP_NUM;gen_j=gen_j+1) begin:ADDR_LOOP 
     for(gen_i=0;gen_i<DATA_LOOP_NUM;gen_i=gen_i+1) begin:DATA_LOOP
        //MASK SEL
        localparam CSA_MASK     = ( DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH == 16 ) ? (gen_j%MASK_NUM & 3'b011) : (gen_j%MASK_NUM);
        localparam CSB_MASK     = ( DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH == 16 ) ? (gen_j%MASK_NUM & 3'b011) : (gen_j%MASK_NUM);
        localparam CSA_MASK_SEL = ((DRM_DATA_WIDTH > 9) && (c_WRITE_MODE != "NORMAL_WRITE")) ? (3'b100 | gen_j%MASK_NUM) : CSA_MASK;
        localparam CSB_MASK_SEL = ((DRM_DATA_WIDTH > 9) && (c_WRITE_MODE != "NORMAL_WRITE")) ? (3'b100 | gen_j%MASK_NUM) : CSB_MASK;

        //data route
        assign DA_bus[gen_i*9 +: Q_DATA_WIDTH] = da_data_bus[gen_i*Q_DATA_WIDTH +: Q_DATA_WIDTH];
        assign DB_bus[gen_i*9 +: Q_DATA_WIDTH] = db_data_bus[gen_i*Q_DATA_WIDTH +: Q_DATA_WIDTH];
        assign qa_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +: Q_DATA_WIDTH] = QA_bus[(gen_i*9+gen_j*9*DATA_LOOP_NUM) +: Q_DATA_WIDTH];
        assign qb_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +: Q_DATA_WIDTH] = QB_bus[(gen_i*9+gen_j*9*DATA_LOOP_NUM) +: Q_DATA_WIDTH];


        assign wr_en_b  = (DRM_DATA_WIDTH <= 9) ? 1'b0 : wr_en;
        assign clk_en_b = (DRM_DATA_WIDTH <= 9) ? 1'b0 : (c_WRITE_MODE == "NORMAL_WRITE") ? ~wr_en & clk_en : clk_en;



        GTP_DRM9K_E1 # (

         .INIT_00         (INIT_00[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_01         (INIT_01[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_02         (INIT_02[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_03         (INIT_03[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_04         (INIT_04[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_05         (INIT_05[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_06         (INIT_06[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_07         (INIT_07[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_08         (INIT_08[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_09         (INIT_09[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_0A         (INIT_0A[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_0B         (INIT_0B[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_0C         (INIT_0C[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_0D         (INIT_0D[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_0E         (INIT_0E[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_0F         (INIT_0F[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_10         (INIT_10[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_11         (INIT_11[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_12         (INIT_12[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_13         (INIT_13[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_14         (INIT_14[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_15         (INIT_15[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_16         (INIT_16[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_17         (INIT_17[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_18         (INIT_18[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_19         (INIT_19[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_1A         (INIT_1A[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_1B         (INIT_1B[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_1C         (INIT_1C[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_1D         (INIT_1D[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_1E         (INIT_1E[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),
         .INIT_1F         (INIT_1F[(gen_j * DATA_LOOP_NUM + gen_i)*288 +: 288]),

         .GRS_EN          ("FALSE"                 ),
         .CSA_MASK        (CSA_MASK_SEL            ),
         .CSB_MASK        (CSB_MASK_SEL            ),
         .DATA_WIDTH_A    (DRM_DATA_WIDTH_SEL      ),    // 1 2 4 8 16 9 18
         .DATA_WIDTH_B    (DRM_DATA_WIDTH_SEL      ),    // 1 2 4 8 16 9 18
         .WRITE_MODE_A    (c_WRITE_MODE            ),
         .WRITE_MODE_B    (c_WRITE_MODE            ),
         .DOA_REG         (c_OUTPUT_REG            ),
         .DOB_REG         (c_OUTPUT_REG            ),
         .DOA_REG_CLKINV  (c_CLK_OR_POL_INV        ),
         .DOB_REG_CLKINV  (c_CLK_OR_POL_INV        ),

         .RST_TYPE        (c_RESET_TYPE            ),
         .RAM_MODE        (RAM_MODE_SEL            ),
         .RAM_CASCADE     ("NONE"                  ),
         .BLOCK_X         (gen_i                   ),
         .BLOCK_Y         (gen_j                   ),
         .RAM_DATA_WIDTH  (CAS_DATA_WIDTH          ),
         .RAM_ADDR_WIDTH  (ADDR_WIDTH              ),
         .INIT_FILE       (c_INIT_FILE             ),
         .INIT_FORMAT     (c_INIT_FORMAT           )
        )
        U_DRM9K
        (
         .CLKA            (clk                  ),
         .RSTA            (rst                  ),
         .CEA             (clk_en               ),
         .WEA             (wr_en                ),
         .ORCEA           (rd_oce               ),
         .DIA             (DA_bus[gen_i*9 +: 9] ),
         .DOA             (QA_bus[(gen_i*9+gen_j*9*DATA_LOOP_NUM) +: 9]          ),
         .ADDRA           (drm_addr[gen_i*14 +: 14]                              ),
         .ADDRA_HOLD      (addr_strobe                                           ),
         .CSA             ({cs_bit2_bus[gen_j],cs_bit1_bus[gen_j],cs_bit0}       ),
         .BWEA            (drm_addr[gen_i*14 +: 2]                               ),
         .CINA            (                     ),
         .COUTA           (                     ),
         
         .CLKB            (clk                  ),
         .RSTB            (rst                  ),
         .CEB             (clk_en_b             ),
         .WEB             (wr_en_b              ),
         .ORCEB           (rd_oce               ),
         .DIB             (DB_bus[gen_i*9 +: 9] ),
         .DOB             (QB_bus[(gen_i*9+gen_j*9*DATA_LOOP_NUM) +:9]              ),
         .ADDRB           (drm_b_addr[gen_i*14 +: 14]                               ),
         .ADDRB_HOLD      (addr_strobe                                              ),
         .CSB             ({csb_bit2_bus[gen_j],csb_bit1_bus[gen_j],csb_bit0}       ),
         .CINB            (                     ),
         .COUTB           (                     )
        );


        //rd_data_bus 
        always@(*)
        begin
           if(DRM_DATA_WIDTH == 18 || DRM_DATA_WIDTH ==16)
              rd_data_bus[gen_i*DRM_DATA_WIDTH+gen_j*CAS_DATA_WIDTH +:DRM_DATA_WIDTH] = {qb_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH] ,qa_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH]};
           else
              rd_data_bus[gen_i*DRM_DATA_WIDTH+gen_j*CAS_DATA_WIDTH +:DRM_DATA_WIDTH] = qa_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH];
        end 
     end
  end
endgenerate

//rd_data: extra mux combination  logic
localparam   ADDR_SEL_LSB = (CS_ADDR_WIDTH > 0) ? (ADDR_WIDTH - CS_ADDR_WIDTH) : (ADDR_WIDTH - 1);

wire [CS_ADDR_WIDTH-1:0]   addr_bus_rd_sel;
reg  [CS_ADDR_WIDTH-1:0]   addr_bus_rd_ce;
reg  [CS_ADDR_WIDTH-1:0]   addr_bus_rd_ce_ff;
wire [CS_ADDR_WIDTH-1:0]   addr_bus_rd_ce_mux;
reg  [CS_ADDR_WIDTH-1:0]   addr_bus_rd_oce;
reg  [CS_ADDR_WIDTH-1:0]   addr_bus_rd_invt;
reg  [CAS_DATA_WIDTH-1:0]  rd_full_data;

reg     wr_en_ff;

//CE
always @(posedge clk or posedge rst)
begin
    if (rst)
        addr_bus_rd_ce <= 0;
    else if (~addr_strobe & clk_en)
        addr_bus_rd_ce <= addr_bus[ADDR_WIDTH-1:ADDR_SEL_LSB];
end

always @(posedge clk or posedge rst)
begin
    if (rst)
        wr_en_ff <= 1'b0;
    else if (clk_en)
        wr_en_ff <= wr_en;
end

always @(posedge clk or posedge rst)
begin
    if (rst)
        addr_bus_rd_ce_ff   <= 0;
    else if (~wr_en_ff)
        addr_bus_rd_ce_ff   <= addr_bus_rd_ce;
end

assign addr_bus_rd_ce_mux = (c_WRITE_MODE != "NORMAL_WRITE") ? addr_bus_rd_ce : wr_en_ff ? addr_bus_rd_ce_ff : addr_bus_rd_ce;

//OCE
always @(posedge clk or posedge rst)
begin
    if (rst)
        addr_bus_rd_oce <= 0;
    else if (rd_oce)
        addr_bus_rd_oce <= addr_bus_rd_ce_mux;
end

//INVT
always @(negedge clk or posedge rst)
begin
    if (rst)
        addr_bus_rd_invt <= 0;
    else if (rd_oce)
        addr_bus_rd_invt <= addr_bus_rd_ce_mux;
end

assign  addr_bus_rd_sel = (c_CLK_OR_POL_INV == 1) ? addr_bus_rd_invt : (c_OUTPUT_REG == 1) ? addr_bus_rd_oce : addr_bus_rd_ce_mux;

integer n;
always@(*)
begin
   rd_full_data = 0;
   if(ADDR_LOOP_NUM>1) begin 
      for(n=0;n<ADDR_LOOP_NUM;n=n+1) begin
         if(addr_bus_rd_sel == n)
            rd_full_data = rd_data_bus[n*CAS_DATA_WIDTH +: CAS_DATA_WIDTH];
      end
   end
   else begin
      rd_full_data = rd_data_bus;
   end
end

assign  rd_data = rd_full_data[c_DATA_WIDTH-1:0];

endmodule

