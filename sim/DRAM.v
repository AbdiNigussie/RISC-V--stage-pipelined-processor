// File: mem_dram.v
module DRAM (
    input        [31:0] wr_data,
    input        [9:0]  addr,
    input               wr_en,
    input        [3:0]  wr_byte_en,
    input               clk,
    input               rst,          // active-high reset (note: your top uses ~rstn)
    output reg   [31:0] rd_data
);

// Memory array: 1024 x 32-bit words
reg [31:0] mem [0:1023];

// Read logic (synchronous read)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        rd_data <= 32'h0;
    end else begin
        rd_data <= mem[addr];
    end
end

// Write logic (synchronous write with byte enable)
integer i;
always @(posedge clk) begin
    if (wr_en) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (wr_byte_en[i]) begin
                mem[addr][8*i +: 8] <= wr_data[8*i +: 8];
            end
        end
    end
end

// Initialize memory from hex file (for simulation only)
initial begin
    $readmemh("dram.hex", mem);
end

endmodule