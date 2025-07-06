    .section .init
    .globl  _start
    .align  2
_start:
    /* This processor's start can be a bit rough */
    nop
    nop
    nop
    nop

    /* Setup GP and SP */
    la gp, __global_pointer$
	la sp, _estack - 4

	/* Load data section from flash to RAM */
	la a0, _data_lma
	la a1, _data_vma
	la a2, _edata
	bgeu a1, a2, 2f
1:
	lw t0, (a0)
	sw t0, (a1)
	addi a0, a0, 4
	addi a1, a1, 4
	bltu a1, a2, 1b
2:

    /* Clear bss section */
    la a0, _sbss
    la a1, _ebss
    bgeu a0, a1, 2f
1:
    sw zero, (a0)
    addi a0, a0, 4
    bltu a0, a1, 1b
2:

    /* Call the constructors */
    la t0, __init_array_start
    la t1, __init_array_end
1:
    beq t0, t1, 2f
    lw t2, 0(t0)
    addi t0, t0, 4
    jalr ra, t2, 0
    j 1b
2:

    /* Call main and halt if returned */
    call main
    j .
