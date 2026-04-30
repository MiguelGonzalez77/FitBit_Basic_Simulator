`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2025 01:57:29 PM
// Design Name: 
// Module Name: BCD_to_7Seg_Converter
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

module BCD_to_7Seg_Converter(  
  input CLOCK,
  input RESET,
  input EXCEED,
  input [31:0] step_count,
  input [15:0] distance_covered,
  input [3:0] initial_activity_count,
  input [15:0]high_activity_time,
  input [1:0]output_mode,
  output [3:0] ANODE,
  output reg [6:0] SevenSegment
); 

// BCD instantiation
wire [6:0] out_steps;
wire [6:0] out_distance;
wire [6:0] out_init_count;
wire [6:0] out_high_activity;

reg [3:0] bcd_steps = 0; 
reg [3:0] bcd_distance = 0;
reg [3:0] bcd_init_count = 0;
reg [3:0] bcd_high_activity = 0;

Binary_to_BCD_Converter steps (CLOCK, bcd_steps, out_steps);
Binary_to_BCD_Converter distance (CLOCK, bcd_distance, out_distance);
Binary_to_BCD_Converter init_count (CLOCK, bcd_init_count, out_init_count);
Binary_to_BCD_Converter high_activity (CLOCK, bcd_high_activity, out_high_activity);



// Clock divider - moved from separate source file
reg [15:0] count = 0;
wire slow_clk = count[15];


// State register variables
reg [1:0] current = 0;
reg [1:0] next = 0;

always @(posedge slow_clk) current <= next; //point next state to current state

reg [3:0] ANODE_BUF = 0; //array of 4 to represent the 4 seven segment displays
assign ANODE = ANODE_BUF;


always @(posedge CLOCK) begin
    count <= count + 1;
    
    
    SevenSegment <= (output_mode[1]) ? ((output_mode[0]) ? out_high_activity: out_init_count) : ((output_mode[0]) ? out_distance: out_steps);

    if(RESET) begin // Synchronous reset
        bcd_steps <= 4'b0000;// Set outputs
        ANODE_BUF <= 4'b1110;
        next <= 0;// set next state
        end
    else begin
        case(current)
        0: begin // state 0
        
                //bcd input for step count
                if(EXCEED)begin
                    bcd_steps <= 9;
                end
                else begin
                    bcd_steps <= ((step_count % 1000) % 100) % 10;
                end
                
                //bcd input for distance covered
                if(distance_covered[0]) begin
                    bcd_distance <= 5;
                end
                else begin
                    bcd_distance <= 0;
                end

              
                //bcd input for intial activity time over 32 steps/sec
                bcd_init_count <= initial_activity_count;
                
                //bcd input for high activity time
                bcd_high_activity <= ((high_activity_time % 1000) % 100) % 10;
            
                ANODE_BUF <= 4'b1110; 
                next <= 1; // set next state
            end
        1: begin // state 1
        
                //bcd input for step count
                if(EXCEED)begin
                    bcd_steps <= 9;
                end
                else begin
                    bcd_steps <= ((step_count % 1000) % 100)/10;
                end
                
                //bcd input for distance covered
                bcd_distance <= 10;      //number corresponding to underscore in bcd.v

                bcd_init_count <= 0;
                
                //bcd input for high activity time
                bcd_high_activity <= ((high_activity_time % 1000) % 100) / 10;
            
                ANODE_BUF <= 4'b1101;
                next <= 2;
            end
        2:begin
        
                //bcd input for step count
                if(EXCEED)begin
                    bcd_steps <= 9;
                end
                else begin
                    bcd_steps <= (step_count % 1000)/100;
                end
                
                //bcd input for distance covered
                bcd_distance <=  (distance_covered >> 1) % 10;
                
                bcd_init_count <= 0;
                
                //bcd input for high activity time
                bcd_high_activity <= (high_activity_time % 1000) / 100;
                
                ANODE_BUF <= 4'b1011;
                next <= 3;
            end
        3:begin
        
                //bcd input for step count
                if(EXCEED)begin
                    bcd_steps <= 9;
                end
                else begin
                    bcd_steps <= (step_count % 10000)/1000;
                end
                
                 //bcd input for distance covered
               
                bcd_distance <=  ((distance_covered >> 1) % 100) / 10;

                bcd_init_count <= 0;
                
                //bcd input for high activity time

                bcd_high_activity <= (high_activity_time % 10000) /1000;
                
                ANODE_BUF <= 4'b0111;
                next <= 0;
            end
        default: begin
        
            //bcd input for step count
            bcd_steps <= 4'd0000;
            ANODE_BUF <= 4'b1110;
            next <= 1;
            end
        endcase
    end
end

endmodule

