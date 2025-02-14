test:
	make -C tests all
	make -C testbench
	python3 test.py

clean:
	-make -C tests clean
	-make -C testbench clean
	-rm CPU.vcd
