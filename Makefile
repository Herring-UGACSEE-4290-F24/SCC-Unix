#Directory for source files
SRC_DIR = src 

#Directory for test bench
TB_DIR = tests

#Simulator
SIMULATOR = iverilog

#Source file written in verilog for SCC. Primary code files that are used to build SCC project.
#Source Files (examples include  = scc.v alu.v reg_file.v (match to our groups file names)). Add any missing files on wednesday.
SOURCE = $(SRC_DIR)/ALU.v $(SRC_DIR)/DM.v $(SRC_DIR)/EXE.v $(SRC_DIR)/ID.v $(SRC_DIR)/IF.v $(SRC_DIR)/Instruction_Mem.v $(SRC_DIR)/Reg_File_2.v $(SRC_DIR)/Reg_File.v $(SRC_DIR)/SCC.v

#Testbench serves as the as a simulated environment where you can apply inputs to the design under test and observe its outputs
TESTBENCH = $(TB_DIR)/Tb.v

#Output
EXECUTABLE = SCC_Tb #We can decide what to name this as a group on wednesday

#Default target
all: $(EXECUTABLE)
	@echo SOURCE: $(SOURCE)
	@echo TESTBENCH: $(TESTBENCH)
	
#Rule to compile the project and Testbench
$(EXECUTABLE): $(SOURCE) $(TESTBENCH)
	$(SIMULATOR) -o $(EXECUTABLE) $(SOURCE)	$(TESTBENCH)

#Run Simulations
run: $(EXECUTABLE)
	vvp $(EXECUTABLE)

#view waveform (requires GTKwave)
#Replace with 'gtkwave output.lxt2' for other group members
view: run
	gtkwave output.vcd

#Remove generated files. Clean will remove the specified executable and any .vcd files, contributing to the cleanliness and manageability of your project.
#Replace with 'rm -f $(EXECUTABLE) *.vcd *.lxt *.lxt2' for other group memebers
#Replace with 'rm -f $(EXECUTABLE) *.vcd' for other group memebers
clean:
	rm -f $(EXECUTABLE) *.vcd

#Phony targets which helps avoid potential issues if files with the same name exist in the directory.
.PHONY: all run clean


