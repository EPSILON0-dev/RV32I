#include "core_arduino.h"

void setup()
{
    Serial.begin(9600);
}

void loop()
{
    startCoremark();
    delay(5000);
}
