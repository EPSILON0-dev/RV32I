# CPU Tests
These tests test all of the CPU features (which is only the ISA). Tests come
from the official RISCV tests repositiory and were slightly modified to run
on this core.

## Running tests
```bash
make test GCC_PATH=<YOUR_GCC_PATH> GCC_PREFIX=<YOUR_GCC_PATH>
make clean
```
Make sure to set the GCC path and prefix. Also make sure your GCC supports the
RV32I architecture with ILP32 ABI.

## Dependancies
 * python3
 * Makefile
 * gcc (normal)
 * gcc (cross-riscv)
 * Verilator
 * ghdl
