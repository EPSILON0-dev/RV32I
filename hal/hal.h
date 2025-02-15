#ifndef __HAL_H
#define __HAL_H

#include <stdbool.h>
#include <stdint.h>

#ifndef F_CPU
#error F_CPU must be set before "hal.h" is included
#endif

#define __REG32(addr) (*((volatile uint32_t*)(addr)))
#define GPIO_DIR  __REG32(0x20000)
#define GPIO_IN   __REG32(0x20004)
#define GPIO_OUT  __REG32(0x20008)
#define UART_DIV  __REG32(0x20010)
#define UART_DAT  __REG32(0x20014)
#define UART_WAIT __REG32(0x20018)
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

void gpio_set_dir(uint8_t gpio, bool dir)
{
    uint16_t t = GPIO_DIR & ~(1 << gpio) | (dir << gpio);
    GPIO_DIR = t;
}

void gpio_set(uint8_t gpio, bool dir)
{
    uint16_t t = GPIO_DIR & ~(1 << gpio) | (dir << gpio);
    GPIO_DIR = t;
}

bool gpio_get(uint8_t gpio)
{
    return !!(GPIO_DIR & (1 << gpio));
}

// TODO: Make those not inline
uint32_t timer_get(void)
{
    return TIMER_DAT;
}

void delay_ms(uint32_t ms)
{
    const uint32_t start_time = timer_get();
    const uint32_t end_time = start_time + (ms * (F_CPU / 1000));
    while (timer_get() < end_time) { ;; }
}

#endif
