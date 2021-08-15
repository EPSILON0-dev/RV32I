MEMORY
{
  rom      (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00007000
  ram      (rwx) : ORIGIN = 0x00007000, LENGTH = 0x00009000
}

STACK_SIZE = 0x5F00;

/* Section Definitions */
SECTIONS
{
    .text :
    {
        KEEP(*(.vectors .vectors.*))
        *(.text*)
        *(.rodata*)
        *(.sdata*)
    } > rom

    /* .bss section which is used for uninitialized data */
    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > ram

    .data :
    {
        *(.data*);
    } > ram AT >rom

    /* stack section */
    .stack (NOLOAD):
    {
        . = ALIGN(8);
        . = . + STACK_SIZE;
        . = ALIGN(8);
    } > ram

    _end = . ;
}
