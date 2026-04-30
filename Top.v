`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 11:27:26 AM
// Design Name: 
// Module Name: Top
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


module Top(
    input clk, 
    input [3:0]sw,
    output EXCEED,
    output [3:0] an,
    output [6:0] seg
    );

    wire [31:0]step_count;
    wire [15:0]distance_covered;//fixed point, 1 digit
    wire [3:0]initial_activity_count;
    wire [15:0]high_activity_time;
    wire [1:0]output_mode;

    wire start = sw[0];
    wire reset = sw[1];
    wire [1:0]mode = sw[3:2];

    FitBit fitbit1(
        .CLK(clk),
        .START(start),
        .RESET(reset),
        .MODE(mode),
        .EXCEED(EXCEED),
        .step_count(step_count),
        .distance_covered(distance_covered),
        .initial_activity_count(initial_activity_count),
        .high_activity_time(high_activity_time),
        .output_mode(output_mode)
    );
    
    BCD_to_7Seg_Converter seg7(
        .CLOCK(clk),
        .RESET(reset),
        .EXCEED(SI),
        .step_count(step_count),
        .distance_covered(distance_covered),
        .initial_activity_count(initial_activity_count),
        .high_activity_time(high_activity_time),
        .output_mode(output_mode),
        .ANODE(an), 
        .SevenSegment(seg)
    ); 
    
endmodule