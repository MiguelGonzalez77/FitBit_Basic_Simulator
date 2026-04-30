`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 11:04:21 AM
// Design Name: 
// Module Name: FitBit
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


module FitBit(
  input CLK,
    input START,
    input RESET,
    input [1:0]MODE,

    output reg EXCEED,
    output reg [31:0]step_count,
    output reg [15:0]distance_covered,//fixed point, 1 digit
    output reg [3:0]initial_activity_count,
    output reg [15:0]high_activity_time,
    output [1:0]output_mode
    );
    
    wire pulse;
    wire [15:0] current_second;

    reg [2:0]output_mode_counter;
    assign output_mode = output_mode_counter[2:1];

    PulseGen step_input(
        .CLOCK          (CLK),
        .begin_fitbit   (START),
        .reset_sw       (RESET),
        .change_mode    (MODE),
        .signalJump     (pulse),
        .SECONDS        (current_second)
    );

    //Step counter 
    reg low_received;

    //distance counter
    reg [11:0]distance_counter;

    //Initial counter
    reg [11:0]pulses_second;
    reg [15:0]last_second;

    //High activity counter
    reg [15:0]current_high_activity_time;

    initial begin
        EXCEED = 0;
        step_count = 0;
        distance_covered = 0;
        initial_activity_count = 0;
        high_activity_time = 0;

        low_received = 1;
        distance_counter = 0;
        pulses_second = 0;
        last_second = 0;
        current_high_activity_time = 0;
        output_mode_counter = 0;
    end

    always @(posedge CLK) begin

        if(RESET)begin
            EXCEED <= 0;
            step_count <= 0;
            distance_covered <= 0;
            initial_activity_count <= 0;
            high_activity_time <= 0;

            low_received <= 1;
            distance_counter <= 0;
            pulses_second <= 0;
            last_second <= 0;
            current_high_activity_time <= 0;
        end
        else begin
            //STEP COUNT
            if(low_received && pulse)begin
                low_received <= 0;
                step_count <= step_count + 1;
                distance_counter <= distance_counter + 1;
                pulses_second <= pulses_second + 1;
            end
            else if(!low_received && !pulse)begin
                low_received <= 1;
            end

            if(step_count > 9999)begin
                EXCEED <= 1;
            end

            //DISTANCE COVERED
            if(distance_counter == 2048)begin
                distance_covered <= distance_covered + 1;
                distance_counter <= 0;
            end

            //Count Pulses per second
            if(current_second > last_second)begin
                last_second <= current_second;
                pulses_second <= 0;

                output_mode_counter <= output_mode_counter + 1;
                
                //INITIAL ACTIVITY COUNT
                if((pulses_second > 32) && (current_second < 10))begin
                    initial_activity_count <= initial_activity_count + 1;
                end

                //HIGH ACTIVITY COUNT
                if(pulses_second >= 64)begin
                    current_high_activity_time <= current_high_activity_time + 1;
                    if(current_high_activity_time == 60)begin
                        high_activity_time <= high_activity_time + 60;
                    end
                    else if(current_high_activity_time > 60)begin
                        high_activity_time <= high_activity_time + 1;
                    end
                end
                else begin
                    current_high_activity_time <= 0;
                end
            end
        end
    end  
endmodule
