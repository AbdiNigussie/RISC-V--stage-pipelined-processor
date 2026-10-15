module Memdata(
    input [2:0] MemRead,      // Original encoding from Control
    input [31:0] perip_rdata,
    
    output reg [31:0] real_rdata
);

always @(*) begin
    real_rdata = perip_rdata;
    case (MemRead)
        3'b100: 
            if (perip_rdata[7])
                real_rdata = {24'hFFFFFF, perip_rdata[7:0]};
                
        // 3'b110: lh (Signed halfword)
        3'b101: 
            if (perip_rdata[15])
                real_rdata = {16'hFFFF, perip_rdata[15:0]};
    endcase
end

endmodule
