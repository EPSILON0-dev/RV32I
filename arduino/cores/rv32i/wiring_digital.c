/*
  wiring_digital.c - digital input and output functions
  Part of Arduino - http://www.arduino.cc/

  Copyright (c) 2005-2006 David A. Mellis

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA

  Modified 28 September 2010 by Mark Sproul

  Modified by EPSILON0-dev on 04.07.2025
*/

#define ARDUINO_MAIN

#include "Arduino.h"
#include "pins_rv32i.h"
#include "defs_rv32i.h"

void pinMode(uint8_t pin, uint8_t mode)
{
	if (pin >= NUM_DIGITAL_PINS) 
		return;

	if (mode == OUTPUT)
		GPIO_DIR |= (1 << pin);
	else if (mode == INPUT)
		GPIO_DIR &= ~(1 << pin);
}

static void turnOffPWM(uint8_t timer)
{
	// No need to ask twice B)
	(void)timer;
}

void digitalWrite(uint8_t pin, uint8_t val)
{
	if (pin >= NUM_DIGITAL_PINS) 
		return;

	if (val)
		GPIO_OUT |= (1 << pin);
	else
		GPIO_OUT &= ~(1 << pin);
}

int digitalRead(uint8_t pin)
{
	return !!(GPIO_IN & (1 << pin));
}
