`timescale 1ns / 1ps
module PulseGen(input CLOCK, input begin_fitbit, input reset_sw, input [1:0] change_mode, output reg signalJump = 0);
