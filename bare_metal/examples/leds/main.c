#include "../../hal/hal.h"

const int n_leds           = 6;
const int led_gpio         = GPIO_0;
const int delay_period_ms  = 60;

int main(void)
{
    for (int i = 0; i < n_leds; i++)
        gpio_set_dir(led_gpio + i, GPIO_OUT);

    bool state = true;
    for ( ;; )
    {
        for (int i = 0; i < n_leds; i++)
        {
            gpio_set(led_gpio + i, state);
            delay_ms(delay_period_ms);
        }
        state = !state;
    }
}