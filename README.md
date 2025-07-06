# RV32I CPU softcore 🎉

This project implements a RISC-V compatible RV32I CPU designed specifically for the **Sipeed Tang Nano 9k** FPGA platform.

## 🚀 Key Features
- Complete RV32I instruction set architecture implementation
- Compact design using only **1779 LUTs** on the **Sipeed Tang Nano 9k**
- UART interface for program uploading and serial communication
- CoreMark benchmark: **6.08 Coremark/s** at **18MHz** (**0.338 Coremark/s/MHz**)
- Compatible with the Arduino framework

## 🛠️ Dependencies
- Verilator (for CPU simulation)
- GHDL (for VHDL to Verilog conversion)
- Python 3 and pyserial
- Make
- GCC
- riscv-unknown-elf-gcc (RISC-V cross compiler toolchain)
- Gowin IDE (or another FPGA synthesis tool)

## 📚 Project Structure & Documentation
- `arduino/`: Arduino core and example sketches for RV32I
- `bare_metal/`: Bare metal firmware including bootloader, HAL, and debugging utilities
- `gowin/`: FPGA project files for Gowin FPGA toolchain
- `hdl/`: Hardware description language source code for CPU core and SoC
- `tests/`: CPU ISA tests and testbenches

## ⚡ Benchmark Summary
```
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
```

## 📦 Getting Started

### 1. Consider carefully before proceeding

_This design is unverified and intended for educational use only. It lacks debugging features, memory protection, interrupts, and CSRs. Use at your own risk._

### 2. Build the bootloader

_Optional: skip if you want to use the default bootloader._

Edit the `Makefile` in `bare_metal/boot` to set your compiler path and prefix. Adjust `F_CPU` if you want a different core frequency than **18MHz**.
```Makefile
GCC_PATH    ?= /home/epsilon/Documents/compilers/riscv/bin
GCC_PREFIX  ?= riscv64-unknown-elf-

...

GCC_PATH    ?= <YOUR PATH>
GCC_PREFIX  ?= <YOUR PREFIX>
```

Compile the bootloader:
```bash
make -C bare_metal/boot
```

Generate the bootloader ROM file:
```bash
cd hdl/soc
python3 gen.py ../../bare_metal/boot/build/bootloader.hex
```

### 3. Synthesize the design

_For non-Gowin FPGAs, synthesis steps and top module modifications may differ._

Open `gowin/soc.gprj` in **Gowin IDE** and run synthesis.

### 4. Upload to FPGA

_For platforms other than **Sipeed Tang Nano 9k**, upload steps may vary._

Upload using openFPGALoader:
```bash
cd gowin/impl/pnr
openFPGALoader -b tangnano9k -f soc.fs
```

### 5. Fix serial port issue

The serial port may stop working after upload. Fix by connecting first to `/dev/ttyUSB0` (upload port), then to `/dev/ttyUSB1` (serial and upload port).

### 6. Setup Arduino IDE

Copy or symlink the `arduino` directory to your Arduino sketches hardware folder:
```bash
ln -s ./arduino <ARDUINO_DIRECTORY>/hardware/rv32i/rv32i
```

### 7. Start programming!

Launch Arduino IDE, select the board, set clock to **18MHz**, and begin development.

## Project backstory

This project started as my very first processor softcore design back in high school (April 2021). It was super basic — just the base RV32I instruction set, no CSRs, no interrupts, not even memory wait states. I didn’t even know what cache was back then! Despite all that, I managed to get some fun stuff running like Conway’s Game of Life and the classic donut.c demo. 

Over time, I kept tinkering with it, learning more about CPU design and FPGA development. Recently, I came back to give it some much-needed polish: the startup code now works properly, and the core no longer crashes because the .bss section wasn’t zeroed at boot (a pretty big deal). 

I never gave it a fancy name, just called it "the processor", but since the repo’s been called RV32I for so long, that name stuck and feels just right. It was also super interesting to revisit an old project of mine and see what I was capable of with my very lacking skills at the time.

## 📫 Contact

For questions or support, feel free to open an issue on the GitHub repository.
