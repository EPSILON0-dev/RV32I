#include "debug_utils.h"

void uart_tx_str(const char *str)
{
    while (*str) uart_tx(*(str++));
}

void uart_tx_hexchar(unsigned hex)
{
    uart_tx(hex < 10 ? hex + '0' : hex + 'a' - 10);
}

void uart_tx_hex8(unsigned hex)
{
    uart_tx('0');
    uart_tx('x');
    for (unsigned i = 0; i < 8; i++)
    {
        uart_tx_hexchar(hex >> 28);
        hex <<= 4;
    }
}

void dump_mem()
{
    uintptr_t _sdata = 0xe000;
    uintptr_t _edata = 0xe6d8;

    uart_tx_str("\n\r.data section (_sdata: ");
    uart_tx_hex8(_sdata);
    uart_tx_str(", _edata: ");
    uart_tx_hex8(_edata);
    uart_tx_str(")\n\r");

    unsigned wrap_cnt = 0;
    for (uintptr_t addr = _sdata; addr < _edata; addr += 4)
    {
        if (!wrap_cnt) 
        {
            uart_tx_str("\n\r");
            uart_tx_hex8(addr);
            uart_tx_str(": ");
        }
        else
        {
            uart_tx_str(", ");
        }
        uart_tx_hex8(*((uint32_t*)(addr)));
        wrap_cnt = (wrap_cnt + 1) & 3;
    }
}

void dump_stack()
{
    uintptr_t _sstack;
    uintptr_t _estack = 0x10000 - 4;

    asm volatile ("mv %0, sp" : "=r" (_sstack));

    _sstack += 32;  // 32 bytes used by the current stack frame

    uart_tx_str("\n\r.stack section (_sstack: ");
    uart_tx_hex8(_sstack);
    uart_tx_str(", _estack: ");
    uart_tx_hex8(_estack);
    uart_tx_str(")\n\r");

    for (uintptr_t addr = _estack - 4; addr >= _sstack; addr -= 4)
    {
        uart_tx_hex8(addr);
        uart_tx_str(": ");
        uart_tx_hex8(*((uint32_t*)(addr)));
        uart_tx_str("\n\r");
    }
}

const char* reg_abi_names[32] = {
    "x0 (zero): ", "x1   (ra): ", "x2   (sp): ", "x3   (gp): ", "x4   (tp): ",
    "x5   (t0): ", "x6   (t1): ", "x7   (t2): ", "x8   (s0): ", "x9   (s1): ",
    "x10  (a0): ", "x11  (a1): ", "x12  (a2): ", "x13  (a3): ", "x14  (a4): ",
    "x15  (a5): ", "x16  (a6): ", "x17  (a7): ", "x18  (s2): ", "x19  (s3): ",
    "x20  (s4): ", "x21  (s5): ", "x22  (s6): ", "x23  (s7): ", "x24  (s8): ",
    "x25  (s9): ", "x26 (s10): ", "x27 (s11): ", "x28  (t3): ", "x29  (t4): ",
    "x30  (t5): ", "x31  (t6): "
};

void dump_regs()
{
    static uint32_t reg_values[32];

    // If compiler changes this WILL break
    asm volatile (
        "sw  x0,   0(%0)\n sw  x1,   4(%0)\n sw  x2,   8(%0)\n sw  x3,  12(%0)\n" 
        "sw  x4,  16(%0)\n sw  x5,  20(%0)\n sw  x6,  24(%0)\n sw  x7,  28(%0)\n" 
        "sw  x8,  32(%0)\n sw  x9,  36(%0)\n sw x10,  40(%0)\n sw x11,  44(%0)\n" 
        "sw x12,  48(%0)\n sw x13,  52(%0)\n sw x14,  56(%0)\n sw x15,  60(%0)\n" 
        "sw x16,  64(%0)\n sw x17,  68(%0)\n sw x18,  72(%0)\n sw x19,  76(%0)\n" 
        "sw x20,  80(%0)\n sw x21,  84(%0)\n sw x22,  88(%0)\n sw x23,  92(%0)\n" 
        "sw x24,  96(%0)\n sw x25, 100(%0)\n sw x26, 104(%0)\n sw x27, 108(%0)\n" 
        "sw x28, 112(%0)\n sw x29, 116(%0)\n sw x30, 120(%0)\n sw x31, 124(%0)\n" 
        : : "r" (reg_values) : "memory"
    );

    asm volatile (
        "lw s1, 24(sp)\n sw s1, 32(%0)"
        : : "r" (reg_values) : "s1", "memory"
    );

    uart_tx_str("\n\rcpu registers:\n\r");
    for (unsigned i = 0; i < 32; i++)
    {
        uart_tx_str(reg_abi_names[i]);
        uart_tx_hex8(reg_values[i]);
        if (i % 4 == 3) uart_tx_str("\n\r"); else uart_tx_str(", ");
    }
}

void dump_address(uintptr_t addr)
{
    uart_tx_hex8(addr);
    uart_tx_str(": ");
    uart_tx_hex8(*((uint32_t*)(addr)));
    uart_tx_str("\n\r");
}
