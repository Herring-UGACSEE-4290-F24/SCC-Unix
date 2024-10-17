# /bin/bash

set -e  # Exits the script if an error occurs

iverilog -o obj/DM_tb.vvp DM_tb.v ../src/DM.v
vvp obj/DM_tb.vvp > run.log
gtkwave dump.vcd