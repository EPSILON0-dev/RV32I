#include <Arduino.h>
#include <stdarg.h>
#include "core_arduino.h"

extern "C" CORETIMETYPE barebones_clock()
{
    return millis();
}

extern "C" int ee_printf(const char *format, ...)
{
    va_list args;

    va_start(args, format);
    for (; *format; format++) {
        if (*format == '%') {
            bool islong = false;
            format++;
            if (*format == '%') {
                Serial.print(*format);
                continue;
            }
            if (*format == '-') {
                format++; // ignore size
            }
            while (*format >= '0' && *format <= '9') {
                format++; // ignore size
            }
            if (*format == 'l') {
                islong = true;
                format++;
            }
            if (*format == '\0') {
                break;
            }
            if (*format == 's') {
                Serial.print((char *) va_arg(args, int));
            } else if (*format == 'f') {
                Serial.print(va_arg(args, double));
            } else if (*format == 'd') {
                if (islong) {
                    Serial.print(va_arg(args, long));
                } else {
                    Serial.print(va_arg(args, int));
                }
            } else if (*format == 'u') {
                if (islong) {
                    Serial.print(va_arg(args, unsigned long));
                } else {
                    Serial.print(va_arg(args, unsigned int));
                }
            } else if (*format == 'x') {
                if (islong) {
                    Serial.print(va_arg(args, unsigned long), HEX);
                } else {
                    Serial.print(va_arg(args, unsigned int), HEX);
                }
            } else if (*format == 'c') {
                Serial.print(va_arg(args, int));
            }
        } else {
            if (*format == '\n') {
                Serial.print('\r');
            }
            Serial.print(*format);
        }
    }
    va_end(args);

    return 1;
}
