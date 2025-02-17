#include "hal.h"

#ifndef F_CPU
#error F_CPU must be set in the makefile
#endif

void gpio_set_dir(uint8_t gpio, bool dir)
{
    uint16_t t = GPIO_DIR & ~(1 << gpio) | (dir << gpio);
    GPIO_DIR = t;
}

void gpio_set(uint8_t gpio, bool val)
{
    uint16_t t = GPIO_OUT & ~(1 << gpio) | (val << gpio);
    GPIO_OUT = t;
}

bool gpio_get(uint8_t gpio)
{
    return !!(GPIO_OUT & (1 << gpio));
}

void uart_set_div(uint32_t div)
{
    UART_DIV = div;
    delay_ms(1);
}

bool uart_get_wait(void)
{
    return !!UART_WAIT;
}

void uart_wait(void)
{
    while (uart_get_wait()) { ;; }
}

void uart_tx(char c)
{
    uart_wait();
    UART_TX = c;
}

char uart_rx(void)
{
    return UART_RX;
}

uint32_t timer_get(void)
{
    return TIMER_DAT;
}

void delay_cycles(uint32_t cycles)
{
    const uint32_t end_time = timer_get() + cycles;
    while (timer_get() < end_time) { ;; }
}

void delay_us(uint32_t us)
{
    const uint32_t end_time = timer_get() + (us * (F_CPU / 1000000));
    while (timer_get() < end_time) { ;; }
}

void delay_ms(uint32_t ms)
{
    const uint32_t end_time = timer_get() + (ms * (F_CPU / 1000));
    while (timer_get() < end_time) { ;; }
}
