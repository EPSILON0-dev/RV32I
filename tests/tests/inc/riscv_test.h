// See LICENSE for license details.

#ifndef _ENV_PHYSICAL_SINGLE_CORE_H
#define _ENV_PHYSICAL_SINGLE_CORE_H

//-----------------------------------------------------------------------
// Begin Macro
//-----------------------------------------------------------------------

// This macro identifies as 32 bit
#define RVTEST_RV64U                                                    \
  .macro init;                                                          \
  .endm

# define CHECK_XLEN li a0, 1; slli a0, a0, 31; bltz a0, 1f; RVTEST_PASS; 1:

#define INIT_XREG                                                       \
  li x1, 0;                                                             \
  li x2, 0;                                                             \
  li x3, 0;                                                             \
  li x4, 0;                                                             \
  li x5, 0;                                                             \
  li x6, 0;                                                             \
  li x7, 0;                                                             \
  li x8, 0;                                                             \
  li x9, 0;                                                             \
  li x10, 0;                                                            \
  li x11, 0;                                                            \
  li x12, 0;                                                            \
  li x13, 0;                                                            \
  li x14, 0;                                                            \
  li x15, 0;                                                            \
  li x16, 0;                                                            \
  li x17, 0;                                                            \
  li x18, 0;                                                            \
  li x19, 0;                                                            \
  li x20, 0;                                                            \
  li x21, 0;                                                            \
  li x22, 0;                                                            \
  li x23, 0;                                                            \
  li x24, 0;                                                            \
  li x25, 0;                                                            \
  li x26, 0;                                                            \
  li x27, 0;                                                            \
  li x28, 0;                                                            \
  li x29, 0;                                                            \
  li x30, 0;                                                            \
  li x31, 0;

#define RVTEST_CODE_BEGIN                                               \
        .section .text.init;                                            \
        .align  6;                                                      \
        .globl _start;                                                  \
_start:                                                                 \
        .align 2;                                                       \
        INIT_XREG;                                                      \
        li TESTNUM, 0;

//-----------------------------------------------------------------------
// End Macro
//-----------------------------------------------------------------------

#define RVTEST_CODE_END

//-----------------------------------------------------------------------
// Pass/Fail Macro
//-----------------------------------------------------------------------

#define RVTEST_PASS                                                     \
        li TESTNUM, 1;                                                  \
        sw TESTNUM, 0(zero);                                            \
        1: j 1b

#define TESTNUM gp
#define RVTEST_FAIL                                                     \
        sw TESTNUM, 0(zero);                                            \
        1: j 1b

//-----------------------------------------------------------------------
// Data Section Macro
//-----------------------------------------------------------------------

#define EXTRA_DATA

#define RVTEST_DATA_BEGIN                                               \
        EXTRA_DATA                                                      \
        .pushsection .tohost,"aw",@progbits;                            \
        .align 6; .global tohost; tohost: .dword 0; .size tohost, 8;    \
        .align 6; .global fromhost; fromhost: .dword 0; .size fromhost, 8;\
        .popsection;                                                    \
        .align 4; .global begin_signature; begin_signature:

#define RVTEST_DATA_END .align 4; .global end_signature; end_signature:

#endif
