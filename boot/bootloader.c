#define F_CPU 27000000ULL
#include <hal.h>
#define LED GPIO_0

int main(void)
{
    bool state = false;
    gpio_set_dir(LED, OUTPUT);
    for (;;)
    {
        gpio_set(LED, state);
        state = !state;
        delay_ms(500);
    }
}
