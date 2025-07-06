/*
  HardwareSerial.cpp - Hardware serial library for Wiring
  Copyright (c) 2006 Nicholas Zambetti.  All right reserved.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  
  Modified 23 November 2006 by David A. Mellis
  Modified 28 September 2010 by Mark Sproul
  Modified 14 August 2012 by Alarus
  Modified 3 December 2013 by Matthijs Kooijman

  Modified by EPSILON0-dev on 04.07.2025
*/

#include <stdlib.h>
#include <inttypes.h>
#include "Arduino.h"

#include "HardwareSerial.h"
#include "defs_rv32i.h"

// Public Methods //////////////////////////////////////////////////////////////

void HardwareSerial::begin(unsigned long baud, byte config)
{
  (void)config;
#if __SERIAL_FORCE_9600 == 1
  UART_DIV = F_CPU / 9600;
#else
  UART_DIV = F_CPU / baud;
#endif
}

void HardwareSerial::end() { ;; }

int HardwareSerial::available(void)
{
  last_char = UART_RX;
  return (last_char != 0xff);
}

int HardwareSerial::peek(void)
{
  return -1;
}

// We're crossing our fingers user calls this after the available
int HardwareSerial::read(void)
{
  return last_char;
}

int HardwareSerial::availableForWrite(void)
{
  return 1;
}

size_t HardwareSerial::write(uint8_t c)
{
  while (!!UART_WAIT) { ;; }
  UART_TX = c;
  return 1;
}

size_t HardwareSerial::write(const uint8_t *buffer, size_t size)
{
  while (size--)
    write(*(buffer++));
  return size;
}

void HardwareSerial::flush()
{
  ;;  // Our buffers are always flushed!
}
