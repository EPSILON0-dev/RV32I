/*
  TwoWire.h - TWI/I2C library for Arduino & Wiring
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

  Modified 2012 by Todd Krein (todd@krein.org) to implement repeated starts
  Modified 2020 by Greyson Christoforo (grey@christoforo.net) to implement timeouts

  Modified 2025 by EPSILON0-dev
*/

#ifndef TwoWire_h
#define TwoWire_h

#include <inttypes.h>
#include "Stream.h"

#define BUFFER_LENGTH 32

// WIRE_HAS_END means Wire has end()
#define WIRE_HAS_END 1

class TwoWire : public Stream
{
  private:
    static uint8_t rxBuffer[];
    static uint8_t rxBufferIndex;
    static uint8_t rxBufferLength;

    static uint8_t txAddress;
    static uint8_t txBuffer[];
    static uint8_t txBufferIndex;
    static uint8_t txBufferLength;

    static uint8_t transmitting;
    static void (*user_onRequest)(void);
    static void (*user_onReceive)(int);
    static void onRequestService(void) {}
    static void onReceiveService(uint8_t*, int) {}

  public:
    TwoWire() {}

    void begin() {}
    void begin(uint8_t address) { (void)address; }
    void begin(int address) { (void)address; }
    void end() {}

    void setClock(uint32_t clock) { (void)clock; }
    void setWireTimeout(uint32_t timeout = 25000, bool reset_with_timeout = false) { (void)timeout; (void)reset_with_timeout; }
    bool getWireTimeoutFlag(void) { return false; }
    void clearWireTimeoutFlag(void) {}

    void beginTransmission(uint8_t address) { (void)address; }
    void beginTransmission(int address) { (void)address; }
    uint8_t endTransmission(void) { return 0; }
    uint8_t endTransmission(uint8_t sendStop) { (void)sendStop; return 0; }

    uint8_t requestFrom(uint8_t address, uint8_t quantity) { (void)address; (void)quantity; return 0; }
    uint8_t requestFrom(uint8_t address, uint8_t quantity, uint8_t sendStop) { (void)address; (void)quantity; (void)sendStop; return 0; }
    uint8_t requestFrom(uint8_t address, uint8_t quantity, uint32_t iaddress, uint8_t isize, uint8_t sendStop) { (void)address; (void)quantity; (void)iaddress; (void)isize; (void)sendStop; return 0; }
    uint8_t requestFrom(int address, int quantity) { (void)address; (void)quantity; return 0; }
    uint8_t requestFrom(int address, int quantity, int sendStop) { (void)address; (void)quantity; (void)sendStop; return 0; }

    virtual size_t write(uint8_t data) { (void)data; return 0; }
    virtual size_t write(const uint8_t *data, size_t quantity) { (void)data; (void)quantity; return 0; }

    virtual int available(void) { return 0; }
    virtual int read(void) { return 0; }
    virtual int peek(void) { return 0; }
    virtual void flush(void) {}

    void onReceive( void (*function)(int) ) { (void)function; }
    void onRequest( void (*function)(void) ) { (void)function; }

    inline size_t write(unsigned long n) { return write((uint8_t)n); }
    inline size_t write(long n) { return write((uint8_t)n); }
    inline size_t write(unsigned int n) { return write((uint8_t)n); }
    inline size_t write(int n) { return write((uint8_t)n); }
    using Print::write;
};

extern TwoWire Wire;

#endif
