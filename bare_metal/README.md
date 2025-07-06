# Bootloader Documentation

## Overview

The bootloader uses a protocol identical to the well-known WozMon monitor protocol. This protocol supports basic memory operations such as reading, writing, block reading, and block writing. It is designed to facilitate loading and debugging code on the target hardware.

## Protocol Features

### Read

The read feature allows reading a single byte from a specified memory address.

**Example:**

To read a byte from address `0x8000`:

```
> 8000
00008000: 78563412
```

The bootloader responds with the 32-bit word value at that address.

### Write

The write feature allows writing a single byte to a specified memory address.

**Example:**

To write the word `0x55aa55aa` to address `0x8000`:

```
> 8000: 55aa55aa
>
```

### Block Read

The block read feature allows reading multiple bytes starting from a specified address.

**Example:**

To read 64 bytes starting from address `0x8000`:

```
> 8000.8040
00008000: 49662079 6F752072 65616C6C 7920626F 
00008010: 74686572 65642074 6F207472 616E736C 
00008020: 61746520 74686174 20796F75 2073686F 
00008030: 756C6420 67657420 61206C69 66650000
>
```

The bootloader responds with the requested block of data.

### Block Write

The block write feature allows writing multiple bytes starting from a specified address.

**Example:**

To write the words `0x55aa55aa`, `0x00ff00ff` to address `0x8000`:

```
> 8000: 55aa55aa 00ff00ff
>
```

### Running the program

The run feature allows starting the program execution. Bootloader jumps to address `0x8000`. 

**Example:**
```
> r
Starting...

```

## Baud Rate and Performance

Due to hardware limitations, the bootloader operates at a fixed baud rate of **9600**. This low speed results in painfully slow data transfers, especially for block operations. Users should be aware of this limitation when using the bootloader for programming or debugging.

## Accessible Memory

In the current configuration only **32KB** at `[0x8000:0x10000]` is accessible to the bootloader. All the accesses have to be aligned to a **4-byte** word boundry. Acccesses outside that range or unaligned to a word boundry will result in an access error.