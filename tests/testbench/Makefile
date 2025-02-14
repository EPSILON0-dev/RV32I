build: build

build:
	ghdl analyze ../../hdl/core/cpu.vhd
	ghdl synth --out=verilog cpu > CPU.v
	verilator --cc --exe --build --trace -j 0 tb.cpp CPU.v
	mv obj_dir/VCPU ./tb

.PHONEY: clean
clean:
	-rm -r obj_dir
	-rm CPU.v work-obj93.cf tb CPU.vcd
