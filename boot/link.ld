OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    rom (rx) : ORIGIN = 0x0000, LENGTH = 2K
    ram (rwx) : ORIGIN = 0x0FF00, LENGTH = 256
}

SECTIONS
{
    .text : { *(.text.init) } > rom
    .text : { *(.text*) } > rom
    .rodata : { *(.rodata*) } > rom
    .data : { *(.data*) } > ram AT > rom
    .bss : { *(.bss*) } > ram

    . = ORIGIN(ram) + LENGTH(ram);
    PROVIDE(_stack_top = .);
}
