// Not much to init around here, is there?
    .section .text.init
    .globl  _start
    .align  2
_start:
    la sp, _stack_top
    call main
    1: j 1b
