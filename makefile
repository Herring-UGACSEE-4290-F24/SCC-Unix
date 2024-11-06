Default:
	echo "default target"

CompileASM:
	python3 parser/assembler.py testAsm/test.asm parser/instructions.json

CompileVerilog:
	iverilog -o testsVer/obj/FULL_TESTBENCH.vvp testsVer/FULL_TESTBENCH.v src/SCC.v src/Instruction_and_data.v src/IF.v src/ID.v src/EXE.v src/ALU.v src/NormalRegs.v src/SpecialRegs.v
	vvp testsVer/obj/FULL_TESTBENCH.vvp -lx2
	gtkwave dump.lx2 testsVer/config/FULL_TB.gtkw