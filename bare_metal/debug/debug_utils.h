#ifndef __DEBUG_UTILS_H
#define __DEBUG_UTILS_H

#include "../hal/hal.h"

#ifdef __cplusplus
extern "C" {
#endif

void uart_tx_str(const char *str);
void uart_tx_hexchar(unsigned hex);
void uart_tx_hex8(unsigned hex);

void dump_mem(void);
void dump_stack(void);
void dump_regs(void);
void dump_address(uintptr_t addr);

extern const char* reg_abi_names[32];

#ifdef __cplusplus
}
#endif

#endif
