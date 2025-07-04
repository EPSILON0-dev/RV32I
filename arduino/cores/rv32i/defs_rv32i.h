#ifndef __RV32I_CORE_DEFINES_H
#define __RV32I_CORE_DEFINES_H

#include <stdint.h>

#define __RV32I_REG32(addr) (*((volatile uint32_t*)(addr)))
#define GPIO_DIR  __RV32I_REG32(0x20000)
#define GPIO_IN   __RV32I_REG32(0x20004)
#define GPIO_OUT  __RV32I_REG32(0x20008)
#define UART_DIV  __RV32I_REG32(0x20010)
#define UART_TX   __RV32I_REG32(0x20014)
#define UART_RX   __RV32I_REG32(0x20018)
#define UART_WAIT __RV32I_REG32(0x2001C)
#define TIMER_DAT __RV32I_REG32(0x20020)

#endif