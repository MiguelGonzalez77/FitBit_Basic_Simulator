Before getting started:

Ensure that you own a Basys3 FPGA kit and also the software that got this running was by using Vivado as the environment.


Some notes on what to consider:

  The inputs to the Fitbit module are:
    1. A sequence of pulses denoting steps
    2. The system clock and reset


  Mapping Information:
    MODE – {Switch 3, Switch 2}
    RESET – Switch 1
    START – Switch 0
    SI – LED0

  Total step count: The total number of steps or pulses being counted. Since the 7-segment can only display up to
9999, the circuit should saturate at 9999 and would assert the signal SI to 1 as soon as the step count becomes
more than 9999, indicating that the step count value being displayed is inaccurate and is more than 9999.
Whenever reset is asserted, the step count will be set to 0000 and SI will go low if it was previously high. Note
that the reset is active high.


Distance covered: The displayed value of distance covered should be as per the following criterion: 2048 steps
will constitute half a mile for distance calculation assuming the size of the steps to be fixed at an average value.
To make distance calculation in hardware simpler, it is recommended to display the distance in denominations of
0.5 miles i.e., 0.5 miles, 1.0 miles, 1.5 miles and so on. This is achieved by rounding down the actual distance
covered to the nearest multiple of 0.5, so that the following are the display values for the total distance covered:
[0,0.5) -> 0
[0.5,1.0) -> 0.5
[1.0, 1.5) -> 1.0
[1.5, 2.0) -> 1.5 and so on.
Note that the correct distance should be displayed even when the display count for the number of steps
saturates at 9999.


Number of seconds with over 32 steps/second: This exhibits the number of seconds, which holds 32 steps per
second, within the first 9 seconds. For example, there are 4 seconds where the number of steps per second is
larger than 32 within the first 9 seconds, then your board should display 4 on the 7-segment. The value should be
held on even after 9 seconds until reset is asserted. This value should be cleared when reset is asserted. Once
reset is deasserted, the 9-second window should start from scratch and recount on the first 9 seconds.


High activity time greater than threshold: The tracker should recognize and award active seconds when the
activity is more strenuous than regular walking. The criterion for recognizing high activity time is “at least a
minute of activity at a rate of equal or larger than 64 steps per second”. For example, if the tracker detects an
activity of 64 steps (or larger) in a second for 60 continuous seconds for the first time, the high activity timer
should go from 0 to 60 seconds and the timer should increment per second for continued activity at a rate higher
than 64 steps per second (60, 61, 62…). The displayed value should freeze when the step rate goes below 64 at
any second. If the high activity is detected again, the frozen display should accumulate with the additional high
activity time.


Case 1:
Suppose the display froze at 67, and high activity time is detected again (a minute of activity at a rate of equal or
larger than 64 steps per second), the display should go from 67 to 127 after high activity at the end of the
minute.


Case 2:
Suppose there is activity at a rate equal to or higher than 64 steps per second for a period of 40 seconds,
followed by a period of rest/low activity. Then another 30 seconds of activity at a rate higher than 64
steps/second is detected. In this case, no high activity time should be counted.



Display Specifications for the Fitbit tracker:
Information from the Fitbit module should be displayed on the 7-segment display in a rotating fashion with a period of
2 seconds. The display should follow the following sequence: Total step count, Distance covered, Steps over 32(time),
High activity time, Total step count, Distance covered...and so on, with each piece of information being displayed for 2
seconds.


To display a decimal value like distance, represent the decimal point with a _. For e.g., 1.5 should be represented as 1_5
on the display. I chose to display a 0 or leave the upper unused digits unlit.


Pulse generator:

The fitbit requires a pulse generator to model the steps. The pulse generator should generate a sequence of pulses fed to the
Fitbit tracker module. The generator should not be affected by the tracker nor affect the tracker, it is a stand-alone
module from tracker. The generator should start generating the pulses once the input START signal goes high. When
the START signal goes low, the generator should stop generating any more pulses. It should start afresh when the signal
goes high again. The generator should have at least 4 modes:

  1. Walk mode (MODE = 2’b00): In this mode, the generator should output a sequence of pulses at a rate of 32
  pulses/steps per second.
  2. Jog mode (MODE = 2’b01): A sequence of pulses at the rate of 64 pulses/steps per second
  3. Run mode (MODE = 2’b10): A sequence of pulses at the rate of 128 pulses/steps per second. (MODE = 10)
  4. Hybrid mode (MODE = 2’b11): The sequence of pulses should be as follows:
       Time       1st sec  2nd sec  3rd sec  4th sec  5th sec  6th sec  7th sec   8th sec  9th sec  10th-73rd sec   74th-79th sec  80th-144th sec  145th sec onwards
      No. of
      pulses        20        33       66      27       70       30        19       30       33          69             34             124             No pulses


    
