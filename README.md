# RISC-V
This is RISC-V compatible CPU made for MIMAS V2 FPGA.  
### Features:
 - Basic RV32I instruction set
 - 64K of combined data/program memory
 - UART interface for uploading programs and communicating

## Dependencies:
* verilator
* ghdl
* riscv-unknown-elf-gcc

0.338 coremark

2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 18083
Total time (secs): 18
Iterations/Sec   : 6
Iterations       : 110
Compiler version : GCC15.1.0
Compiler flags   : -Os
Memory location  : STACK
seedcrc          : 0xE9F5
[0]crclist       : 0xE714
[0]crcmatrix     : 0x1FD7
[0]crcstate      : 0x8E3A
[0]crcfinal      : 0x134
Correct operation validated.
