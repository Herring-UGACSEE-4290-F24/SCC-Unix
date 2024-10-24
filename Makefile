#Simulator
SIMULATOR = iverilog

#Source file written in verilog for SCC. Primary code files that are used to build SCC project.
#Source Files (examples include  = scc.v alu.v reg_file.v (match to our groups file names)). Add any missing files on wednesday.
SOURCE = ALU.v Reg_File.v Reg_File_2.v EXE.v DM.v ID.v IF.v Instruction_Mem.v

#Testbench serves as the as a simulated environment where you can apply inputs to the design under test and observe its outputs
TESTBENCH = Tb.v

#Output
EXECUTABLE = SCC_Tb #We can decide what to name this as a group on wednesday

#Default target
all: $(EXECUTABLE)

#Rule to compile the project and Testbench
$(EXECUTABLE): $(SOURCE) $(TESTBENCH)
	$(SIMULATOR) -o $(EXECUTABLE) $(SOURCE)	$(TESTBENCH)

#Run Simulations
run: $(EXECUTABLE)
	vvp $(EXECUTABLE)

#Remove generated files. Clean will remove the specified executable and any .vcd files, contributing to the cleanliness and manageability of your project.
clean:
	rm -f $(EXECUTABLE) *.vcd

#Phony targets which helps avoid potential issues if files with the same name exist in the directory.
.Phony: all run clean