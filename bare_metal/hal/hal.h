#ifndef __HAL_H
#define __HAL_H

#include <stdbool.h>
#include <stdint.h>

#define __REG32(addr) (*((volatile uint32_t*)(addr)))
#define GPIO_DIR  __REG32(0x20000)
#define GPIO_IN   __REG32(0x20004)
#define GPIO_OUT  __REG32(0x20008)
#define UART_DIV  __REG32(0x20010)
#define UART_TX   __REG32(0x20014)
#define UART_RX   __REG32(0x20018)
#define UART_WAIT __REG32(0x2001C)
#define TIMER_DAT __REG32(0x20020)

#define INPUT   false
#define OUTPUT  true
#define GPIO_0  0
#define GPIO_1  1
#define GPIO_2  2
#define GPIO_3  3
#define GPIO_4  4
#define GPIO_5  5
#define GPIO_6  6
#define GPIO_7  7
#define GPIO_8  8
#define GPIO_9  9
#define GPIO_10 10
#define GPIO_11 11
#define GPIO_12 12
#define GPIO_13 13
#define GPIO_14 14
#define GPIO_15 15
#define GPIO_16 16
#define GPIO_17 17
#define GPIO_18 18
#define GPIO_19 19
#define GPIO_20 20
#define GPIO_21 21
#define GPIO_22 22
#define GPIO_23 23
#define GPIO_24 24
#define GPIO_25 25
#define GPIO_26 26
#define GPIO_27 27
#define GPIO_28 28
#define GPIO_29 29
#define GPIO_30 30
#define GPIO_31 31

#ifdef __cplusplus
extern "C" {
#endif

void gpio_set_dir(uint8_t gpio, bool dir);
void gpio_set(uint8_t gpio, bool dir);
bool gpio_get(uint8_t gpio);
void uart_set_div(uint32_t div);
bool uart_get_wait(void);
void uart_wait(void);
void uart_tx(char c);
char uart_rx(void);
uint32_t timer_get(void);
void delay_cycles(uint32_t cycles);
void delay_us(uint32_t us);
void delay_ms(uint32_t ms);

#ifdef __cplusplus
}
#endif

#endif
