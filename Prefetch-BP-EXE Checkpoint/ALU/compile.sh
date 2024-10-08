# /bin/bash

iverilog -o ALU_Sim.vvp ALU_testbench.v ALU.v
vvp ALU_Sim.vvp > run.log