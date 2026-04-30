`timescale 1ns / 1ps
`define second 50000000

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2024 08:10:14 PM
// Design Name: 
// Module Name: PulseGen
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
module PulseGen(input CLOCK, input begin_fitbit, input reset_sw, 
                input [1:0] change_mode, output reg signalJump = 0,
                output [15:0] SECONDS);
   
   
    time cyclesPerSecond = (1000000000/10); // 100,000,000 therefore
    // it is 1/10th of a sec
    time totalTime = 0; // keeps track of total time
    time iterate = 0; 
    
    reg [15:0] currentSec = 0;
    assign SECONDS = currentSec;
    
    integer timeInterval = 0; // timeInterval of the pulse 
    integer lastintervalSec = 0; // previous second
    integer freqHz = 0; // freq of the pulse  
    integer signalJumpCount = 0;
    
    reg lastbegin = 0; // last start meaning it will
    // keep track of the last time start was used
    
    always @(posedge CLOCK) 
    begin
        if(!lastbegin && begin_fitbit) 
        // if start is on, but dependent on last start as well
        // checks the rising edge 
        begin
        // initialize conditions
            totalTime <= 0;
            iterate <= 0;
            lastintervalSec <= -1; // since prev second
            // of first initial second is -1, since 
            // initially it is 0
            signalJumpCount <= 0; 
            signalJump <= 0;
        end
        lastbegin <= begin_fitbit; // otherwise 
        // set the start to be the last start state.
        
        if(reset_sw) // if the reset switch has been 
        // executed, initialize all to 0 and reset
        // cyclespersecond
        begin
            totalTime <= 0;
            iterate <= 0;
            currentSec <= 0;
            timeInterval <= 0;
            lastintervalSec <= 0;
            freqHz <= 0;
            signalJumpCount <= 0;
            signalJump <= 0;
            cyclesPerSecond <= (1000000000/10);
        end
    
       if(!begin_fitbit) // if not starting
       begin 
       timeInterval <= (1000000000/10); // initalize period 
       // to be 10ns a cycle
       end
       else if(change_mode == 2'b11) // hybrid mode
       begin
           currentSec <= totalTime / (1000000000/10); // totalTime is initially 0
           // so set currentSec to 0
           // the following if statements execute only one block
           // as seconds increases, so it will do the corresponding
           // number of pulses, which must be doubled 
           // since new clk is 100MHz,
           
           // add 1 because to prevent jitter
           if(currentSec < 1)
           begin 
           timeInterval <= (1000000000/10) / ((20*2)+1);
           end
           else if(currentSec < 2) 
           begin
           timeInterval <= (1000000000/10) / ((33*2)+1);
           end
           else if(currentSec < 3) 
           begin
           timeInterval <= (1000000000/10) / ((66*2)+1);
           end
           else if(currentSec < 4) 
           begin
           timeInterval <= (1000000000/10) / ((27*2)+1);
           end
           else if(currentSec < 5) 
           begin
           timeInterval <= (1000000000/10) / ((70*2)+1);
           end
           else if(currentSec < 6) 
           begin
           timeInterval <= (1000000000/10) / ((30*2)+1);
           end
           else if(currentSec < 7)
           begin 
           timeInterval <= (1000000000/10) / ((19*2)+1);
           end
           else if(currentSec < 8) 
           begin
           timeInterval <= (1000000000/10) / ((30*2)+1);
           end
           else if(currentSec < 9) 
           begin
           timeInterval <= (1000000000/10) / ((33*2)+1);
           end
           else if(currentSec < 73) 
           begin
           timeInterval <= (1000000000/10) / ((69*2)+1);
           end
           else if(currentSec < 79) 
           begin
           timeInterval <= (1000000000/10) / ((34*2)+1);
           end
           else if(currentSec < 144) 
           begin
           timeInterval <= (1000000000/10) / ((124*2)+1);
           end
           else 
           begin
           timeInterval <= (1000000000/10);
           end
       end
       else // other modes
       begin
           currentSec <= totalTime / (1000000000/10);
           
           if(change_mode == 2'b00) // mode 0 is 32 pulses
           begin
           timeInterval <= (1000000000/10) / ((32*2)+1);
           end
           else if(change_mode == 2'b01)  // mode 01
           begin
           timeInterval <= (1000000000/10) / ((64*2)+1);
           end
           else if(change_mode == 2'b10) // mode 10
           begin
           timeInterval <= (1000000000/10) / ((128*2)+1);
           end
       end
       
       if(cyclesPerSecond >= (1000000000/10)) 
       begin
       // if cyclesPerSecond is larger than 100,000,000
       // this means a second has passed, therefore. 
       // a pulse has finished
           signalJump <= 0; // output
           signalJumpCount <= 0;
           iterate <= 0;
           cyclesPerSecond <= 1;
       end
       else if(iterate >= timeInterval) 
       // checks to see if the counter which tracks 
       // the # clock cycles per pulse period has exceeded the
       // pulse period related to the mode
       begin
           iterate <= 0; // set iterate back to 0
           signalJump <= !signalJump; // invert pulse signal
           cyclesPerSecond <= cyclesPerSecond + 1; // increment the cyclesperSecond counter
       end
       else 
       begin
           iterate <= iterate + 1; // otherwise we increment 
           // the iterate to keep track of pulse period
           cyclesPerSecond <= cyclesPerSecond + 1;
           // keep track and increment the number of cycles
           // has passed to make sure we don't go over 100MHz
       end
              
       totalTime <= totalTime + 1; // no matter what must increment
       // time by 1 second
    end
endmodule
