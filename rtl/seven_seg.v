`timescale 1ns / 1ps

module seven_seg(
    input clk,                  // fundamental frequency 100MHz
    input rstn,                 // active LOW reset signal
    input [31:0] data,          // 32-bit MEM contents willing to display on 7-segments
    output SevenSegDP,          // dot point for 7-segments
    output reg [7:0] anode,     // anodes for 7-segments
    output reg [6:0] SevenSegCathode // cathodes for 7-segments
);

    reg [7:0] enable;               // 8-bit signal to indicate which 7-segment unit is enabled (active LOW)
    reg [3:0] data_disp;            // display data_disp for each 7-segment unit, 0 to F, therefore 4 bits
    reg [16:0] count_fast = 17'b0;  // counter for slowering down 100MHz to 1kHz for 7-segments multiplexing
    reg seven_seg_enable = 1'b0;    // 1-bit enable signal for 1kHz multiplexing speed of 7-segments

    assign SevenSegDP = 1'b1;       // disable all dot points

    // generate a shift signal seven_seg_enable for the anode registers
    always @(posedge clk) begin
        count_fast <= count_fast + 1;       // fast counter is enabled by the fundamental frequency 100MHz
        if(count_fast == 17'h1869F) begin   // counter should count from 0 to 99,999 for 1kHz
           seven_seg_enable <= 1'b1;        // set the enable flag signal 
           count_fast <= 17'b0;             // reset the counter
        end
        else 
            seven_seg_enable <= 0;          // clear the enable flag signal if counter doesn't reach 99,999
    end

    // enable signal is a loop shift register from 8'b0000_0001 to 8'b1000_0000
    always @(posedge clk) begin
        if (~rstn) begin
            enable <= 8'b00000001;       // multiplexing signal for eight 7-segment units, turn on the most right one initially 
            anode <= 8'hFF;              // disable all anode signals of 7-segments (active LOW)
        end
        else if (seven_seg_enable) begin          // when 7-segments are enabled, multiplexing eight 7-segment units on by one
            enable <= (enable == 8'h80) ? 8'h01 : (enable << 1); //eight 7-segment units are turned on 1 by 1, with frequency 1kHz
            anode <= ~enable;               // anode signal is active LOW
        end
    end

    // anode driver (active low)
    always @(*) begin
        case (anode) // assigning the 32-bit data_disp to each 7-segment unit
            8'b11111110 : data_disp = data[3:0];
            8'b11111101 : data_disp = data[7:4];
            8'b11111011 : data_disp = data[11:8];
            8'b11110111 : data_disp = data[15:12];
            8'b11101111 : data_disp = data[19:16];
            8'b11011111 : data_disp = data[23:20];
            8'b10111111 : data_disp = data[27:24];
            8'b01111111 : data_disp = data[31:28];
            default : data_disp = 4'h0;
        endcase
    end

    // cathod decoder for the hex display
    always @(*) begin
        if (~rstn) begin 
            SevenSegCathode = 7'b1111111;       // disable all cathode signals of 7-segments (active HIGH)
        end
        else begin 
        case (data_disp) // based on 4-bit data_disp, turn on/off corresponding cathode signals
            4'h0 : SevenSegCathode = 7'b1000000; 
            4'h1 : SevenSegCathode = 7'b1111001;
            4'h2 : SevenSegCathode = 7'b0100100;
            4'h3 : SevenSegCathode = 7'b0110000;
            4'h4 : SevenSegCathode = 7'b0011001;
            4'h5 : SevenSegCathode = 7'b0010010;
            4'h6 : SevenSegCathode = 7'b0000010;
            4'h7 : SevenSegCathode = 7'b1111000;
            4'h8 : SevenSegCathode = 7'b0000000;
            4'h9 : SevenSegCathode = 7'b0010000;
            4'hA : SevenSegCathode = 7'b0001000;
            4'hB : SevenSegCathode = 7'b0000011;
            4'hC : SevenSegCathode = 7'b1000110;
            4'hD : SevenSegCathode = 7'b0100001;
            4'hE : SevenSegCathode = 7'b0000110;
            4'hF : SevenSegCathode = 7'b0001110;
        endcase
        end 
    end
    
endmodule
