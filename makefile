Default:
	echo "default target"

CompileASM:
	python3 parser/assembler.py testAsm/test.asm parser/instructions.json

CompileVerilog:
	iverilog -o src/FULL_TESTBENCH.vvp src/FULL_TESTBENCH.v src/SCC.v src/Instruction_and_data.v src/IF.v src/ID.v src/EXE.v src/ALU.v src/NormalRegs.v src/SpecialRegs.v
	vvp src/FULL_TESTBENCH.vvp -lx2
	gtkwave dump.lx2 FULL_TB.gtkw