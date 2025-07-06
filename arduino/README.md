# Arduino Core for **RV32I**

This directory contains the Arduino core implementation for the **RV32I** CPU architecture.

## Overview
- Provides essential Arduino core functionality such as serial communication, digital and analog I/O, and timing functions.
- Implements hardware abstraction layers tailored for the **RV32I** CPU.

## Features
- **UART** serial communication support
- **GPIO** digital and analog I/O handling
- Basic timing and delay functions
- Compatibility with Arduino sketches targeting **RV32I**
- Stub files for `SPI.h` and `Wire.h`

## GPIO mappings

|  Pin  |   Loc  |   Function   |
|:-----:|:------:|:-------------|
| `G0 ` |  `--`  | LED 0        |
| `G1 ` |  `--`  | LED 1        |
| `G2 ` |  `--`  | LED 2        |
| `G3 ` |  `--`  | LED 3        |
| `G4 ` |  `--`  | LED 4        |
| `G5 ` |  `--`  | LED 5        |
| `G6 ` |  `--`  | User Button  |
| `G7 ` |  `38`  | TF_CS        |
| `G8 ` |  `37`  | TF_MOSI      |
| `G9 ` |  `36`  | TF_SCLK      |
| `G10` |  `39`  | TF_MISO      |
| `G11` |  `25`  | GPIO         |
| `G12` |  `26`  | GPIO         |
| `G13` |  `27`  | GPIO         |
| `G14` |  `28`  | GPIO         |
| `G15` |  `29`  | GPIO         |
| `G16` |  `30`  | GPIO         |
| `G17` |  `33`  | GPIO         |
| `G18` |  `34`  | GPIO         |
| `G19` |  `40`  | GPIO         |
| `G20` |  `35`  | GPIO         |
| `G21` |  `41`  | GPIO         |
| `G22` |  `42`  | GPIO         |
| `G23` |  `51`  | GPIO         |
| `G24` |  `53`  | GPIO         |
| `G25` |  `57`  | GPIO         |
| `G26` |  `68`  | GPIO         |
| `G27` |  `69`  | GPIO         |
| `G28` |  `63`  | GPIO         |
| `G29` |  `77`  | GPIO         |
| `G30` |  `76`  | GPIO         |
| `G31` |  `48`  | GPIO         |

### Notes

- LEDs are configured to always be `OUTPUT` and are active high
- User button is configured to always be `INPUT` and is active low
- The rest are GPIOs and can be configured to be either `INPUT` or `OUTPUT`
- In `INPUT` mode the pullup resistor is always enabled

## Notes
- This core is designed specifically for the **RV32I** CPU on the **Sipeed Tang Nano 9k** FPGA.
- Some Arduino features may be limited or adapted due to hardware constraints.

## Usage
Copy or link this directory to `<arduino directory>/hardware/rv32i/rv32i`.<br>
It should now show up in the boards tab in arduino IDE.