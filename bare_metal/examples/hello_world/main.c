#include "../../hal/hal.h"

const char *message          = "Hello, World!\n\r";
const int baud_rate          = 9600;
const int led_gpio           = GPIO_0;
const int message_period_ms  = 1000;

void print_str(const char *str)
{
    while (*str) uart_tx(*(str++));
}

int main(void)
{
    gpio_set_dir(led_gpio, GPIO_OUT);
    uart_set_div(F_CPU / baud_rate);
    delay_ms(10);

    for ( ;; )
    {
        gpio_set(led_gpio, true);
        print_str(message);
        gpio_set(led_gpio, false);
        delay_ms(message_period_ms);
    }
}