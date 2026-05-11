// File: irom.v
module IROM (
    input       [7:0]  addr,
    output reg  [31:0] rd_data
);

// Memory array: 256 x 32-bit words (addressable by [9:0])
reg [31:0] mem [0:255];

// Declare memory and initialize
initial begin
    $readmemh("irom.hex", mem);
end

// Combinational read
assign rd_data = mem[addr];

endmodule