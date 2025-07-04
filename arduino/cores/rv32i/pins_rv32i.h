/*
  pins_arduino.h - Pin definition functions for Arduino
  Part of Arduino - http://www.arduino.cc/

  Copyright (c) 2007 David A. Mellis

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

  Modified by EPSILON0-dev on 04.07.2025
*/

// Damn... That's quite some deleting I had to do in this file

#ifndef Pins_Arduino_h
#define Pins_Arduino_h

#define NUM_DIGITAL_PINS            32
#define NUM_ANALOG_INPUTS           0
#define analogInputToDigitalPin(p)  0

#define digitalPinHasPWM(p) 0

#define LED_BUILTIN 0

#define SERIAL_PORT_MONITOR   Serial
#define SERIAL_PORT_HARDWARE  Serial

#endif