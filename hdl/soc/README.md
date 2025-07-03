# SOC 

## Memory Map

|\||     Start    |  Size  |   Type  |         Description           |\||
|--|:------------:|:------:|:-------:|:------------------------------|--|
|\|| `0x00000000` | `512B` |  `R-X`  | Bootloader area               |\||
|\|| `0x00008000` | `16KB` |  `RWX`  | Closely coupled memory        |\||
|\|| `0x00020000` | ` 4B ` |  `RW-`  | GPIO direction reg (gpio_en)  |\||
|\|| `0x00020004` | ` 4B ` |  `R--`  | GPIO in reg (gpio_in)         |\||
|\|| `0x00020008` | ` 4B ` |  `RW-`  | GPIO out reg (gpio_out)       |\||
|\|| `0x00020010` | ` 4B ` |  `RW-`  | UART div reg                  |\||
|\|| `0x00020014` | ` 4B ` |  `RW-`  | UART tx reg                   |\||
|\|| `0x00020018` | ` 4B ` |  `RW-`  | UART rx reg                   |\||
|\|| `0x0002001C` | ` 4B ` |  `R--`  | UART wait reg                 |\||
|\|| `0x00020020` | ` 4B ` |  `R--`  | Timer reg                     |\||

## GPIOs

|\||  Pin  |   Loc  |   Function   |\||  Pin  |   Loc  |   Function   |\||
|--|:-----:|:------:|:-------------|--|:-----:|:------:|:-------------|--|
|\|| `G0 ` |  `--`  | LED 0        |\|| `G16` |  `30`  | GPIO         |\||
|\|| `G1 ` |  `--`  | LED 1        |\|| `G17` |  `33`  | GPIO         |\||
|\|| `G2 ` |  `--`  | LED 2        |\|| `G18` |  `34`  | GPIO         |\||
|\|| `G3 ` |  `--`  | LED 3        |\|| `G19` |  `40`  | GPIO         |\||
|\|| `G4 ` |  `--`  | LED 4        |\|| `G20` |  `35`  | GPIO         |\||
|\|| `G5 ` |  `--`  | LED 5        |\|| `G21` |  `41`  | GPIO         |\||
|\|| `G6 ` |  `--`  | User Button  |\|| `G22` |  `42`  | GPIO         |\||
|\|| `G7 ` |  `38`  | TF_CS        |\|| `G23` |  `51`  | GPIO         |\||
|\|| `G8 ` |  `37`  | TF_MOSI      |\|| `G24` |  `53`  | GPIO         |\||
|\|| `G9 ` |  `36`  | TF_SCLK      |\|| `G25` |  `57`  | GPIO         |\||
|\|| `G10` |  `39`  | TF_MISO      |\|| `G26` |  `68`  | GPIO         |\||
|\|| `G11` |  `25`  | GPIO         |\|| `G27` |  `69`  | GPIO         |\||
|\|| `G12` |  `26`  | GPIO         |\|| `G28` |  `63`  | GPIO         |\||
|\|| `G13` |  `27`  | GPIO         |\|| `G29` |  `77`  | GPIO         |\||
|\|| `G14` |  `28`  | GPIO         |\|| `G30` |  `76`  | GPIO         |\||
|\|| `G15` |  `29`  | GPIO         |\|| `G31` |  `48`  | GPIO         |\||

 1) LEDs are active high
 2) User button is active low