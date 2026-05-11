
module ProgramCounter(
    input CLK,
    input Reset,
    input flush,
    input pause,
    input [31:0] NextPC,

    output reg [31:0] PC,
    output reg [31:0] if_pc
    );
always @(posedge CLK) begin
        if(Reset) begin
            PC <= 0;
            if_pc <= 0;
        end else if(flush) begin
            PC <= NextPC;//并非冗余，有个优先级的关系
            if_pc <= NextPC;
        end else if(pause) begin
            // 空操作
            // 阻止寄存器值改变
        end else begin
            PC <= NextPC;
            if_pc<= NextPC;
        end 
    end
endmodule
