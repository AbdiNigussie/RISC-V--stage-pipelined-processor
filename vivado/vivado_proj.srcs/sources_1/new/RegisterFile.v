module RegisterFile(
    input CLK,
    input WE3,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,

    output reg [31:0] RD1,  
    output reg [31:0] RD2   
);
    
    reg [31:0] RegBank[0:31];
    reg [4:0] addr1_reg, addr2_reg;
    integer i;
    
    initial begin
        for (i = 0; i < 32; i = i + 1)
            RegBank[i] = 32'b0;
        RD1 = 32'b0;
        RD2 = 32'b0;
    end
    
    // 上升沿写入
    always @(posedge CLK) begin
        if(WE3 && A3 != 0) RegBank[A3] <= WD3;
    end
    
    // 组合逻辑读取 - RD1
    always @(*) begin
        if(A1 == 5'h0) begin
            // x0寄存器硬连线到0
            RD1 = 32'h0000_0000;
        end else begin
            if(WE3 && (A1 == A3) && (A3 != 0)) begin
                // 数据前递：如果正在写入的寄存器是当前要读取的
                RD1 = WD3;  // 使用要写入的新值
            end else begin
                // 正常读取寄存器值
                RD1 = RegBank[A1];
            end
        end
    end
    
    // 组合逻辑读取 - RD2
    always @(*) begin
        if(A2 == 5'h0) begin
            // x0寄存器硬连线到0
            RD2 = 32'h0000_0000;
        end else begin
            if(WE3 && (A2 == A3) && (A3 != 0)) begin
                // 数据前递：如果正在写入的寄存器是当前要读取的
                RD2 = WD3;  // 使用要写入的新值
            end else begin
                // 正常读取寄存器值
                RD2 = RegBank[A2];
            end
        end
    end
endmodule