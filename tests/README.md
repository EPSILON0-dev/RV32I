# CPU Tests

This directory contains tests that verify the functionality of the CPU, specifically focusing on the RV32I ISA implementation. The tests are derived from the official RISC-V test repository and have been slightly modified to work with this core.

## Running the Tests

To run the tests, use the following commands:

```bash
make test GCC_PATH=<YOUR_GCC_PATH> GCC_PREFIX=<YOUR_GCC_PREFIX>
```

Replace `<YOUR_GCC_PATH>` and `<YOUR_GCC_PREFIX>` with the appropriate paths for your RISC-V GCC toolchain. Ensure that your GCC supports the RV32I architecture with the ILP32 ABI.

## Dependencies

The following tools and packages are required to build and run the tests:

- Python 3
- Make
- GCC (native)
- GCC (cross-compiler for RISC-V)
- Verilator
- GHDL

Make sure all dependencies are installed and properly configured before running the tests.
