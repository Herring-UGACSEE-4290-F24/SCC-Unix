# /bin/bash

set -e  # Exits the script if an error occurs

iverilog -o ALU_Sim.vvp ALU_testbench.v ALU.v
vvp ALU_Sim.vvp > run.log
gtkwave dump.vcd