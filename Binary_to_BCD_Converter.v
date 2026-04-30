`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2025 08:10:14 PM
// Design Name: 
// Module Name: Binary_to_BCD_Converter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Binary_to_BCD_Converter(input clk, input [3:0] binary,output [6:0] BCD);

// initialize the decimal to 0
reg [6:0] BCD_7Seg = 0;
assign BCD = BCD_7Seg;

// 0 since Basys 3 is anode-connected in FPGA therefore 
// 0 will turn on the segment since it will use the respective I/O pin 
always@(posedge clk)
    begin
    case(binary) // switch case for the 7 segment display
    4'b0000: BCD_7Seg = 7'b1000000;
    4'b0001: BCD_7Seg = 7'b1111001;
    4'b0010: BCD_7Seg = 7'b0100100;
    4'b0011: BCD_7Seg = 7'b0110000;
    4'b0100: BCD_7Seg = 7'b0011001;
    4'b0101: BCD_7Seg = 7'b0010010;
    4'b0110: BCD_7Seg = 7'b0000010;
    4'b0111: BCD_7Seg = 7'b1111000;
    4'b1000: BCD_7Seg = 7'b0000000;
    4'b1001: BCD_7Seg = 7'b0010000;
    4'b1010: BCD_7Seg = 7'b0111111; // _
    default: 
        BCD_7Seg = 7'b1111111; // default case if greater than 10.
    endcase
    end
endmodule