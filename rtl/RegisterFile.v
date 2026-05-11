module RegisterFile(
    input CLK,
    input WE3,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,

    output [31:0] RD1,
    output [31:0] RD2
    );
    
    // declare RegBank
    reg [31:0] RegBank[0:31] ;
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            RegBank[i] = 32'b0;
    end
   always @(posedge CLK) begin
    if(WE3) RegBank[A3] <= WD3;
   end
   
   assign RD1 = RegBank[A1];
   assign RD2 = RegBank[A2];
   
   
endmodule