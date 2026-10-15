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
    
    // Write on the rising clock edge
    always @(posedge CLK) begin
        if(WE3 && A3 != 0) RegBank[A3] <= WD3;
    end
    
    // Combinational read - RD1
    always @(*) begin
        if(A1 == 5'h0) begin
            // Register x0 is hardwired to zero
            RD1 = 32'h0000_0000;
        end else begin
            if(WE3 && (A1 == A3) && (A3 != 0)) begin
                // Forward data if the register being written is also being read
                RD1 = WD3;  // Use the new value being written
            end else begin
                // Read the stored register value normally
                RD1 = RegBank[A1];
            end
        end
    end
    
    // Combinational read - RD2
    always @(*) begin
        if(A2 == 5'h0) begin
            // Register x0 is hardwired to zero
            RD2 = 32'h0000_0000;
        end else begin
            if(WE3 && (A2 == A3) && (A3 != 0)) begin
                // Forward data if the register being written is also being read
                RD2 = WD3;  // Use the new value being written
            end else begin
                // Read the stored register value normally
                RD2 = RegBank[A2];
            end
        end
    end
endmodule