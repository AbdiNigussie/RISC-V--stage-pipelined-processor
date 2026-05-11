
module ProgramCounter(
    input CLK,
    input Reset,
    input [31:0] NextPC,

    output reg [31:0] PC
    );
    
always @(posedge CLK or posedge Reset) 
    if(Reset) PC <=0;
    else PC <= NextPC;
  
endmodule
