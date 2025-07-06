# CPU Core HDL

This directory contains the VHDL source code for the RV32I CPU core implementation.

## Overview
- Implements a basic RV32I CPU core in VHDL.
- Contains the main CPU logic including instruction fetch, decode, execute, and memory access.
- Implements a simple 3-phase instruction cycle FSM (fetch, decode, execute).
- Includes program counter management with support for branches, jumps, and jalr instructions.
- Implements a register file with 32 registers.
- Contains an arithmetic and logic unit (ALU) supporting RV32I operations.
- Includes a logical and arithmetic shifter unit.
- Supports memory load and store operations with handling for unaligned accesses.

## Features
- Supports the full RV32I base integer instruction set.
- Handles instruction decoding for all RV32I instruction formats (R, I, S, B, U, J).
- Implements branch condition evaluation and branch target calculation.
- Supports load and store instructions with byte, halfword, and word granularity.
- Handles unaligned memory accesses by splitting into multiple memory operations.
- No support for interrupts, CSRs, hardware timers, or performance counters.
- No pipeline beyond the simple 3-phase FSM.
