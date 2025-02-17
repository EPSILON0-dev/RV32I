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

#endif
