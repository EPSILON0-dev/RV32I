#ifndef __RV32I_CORE_COMMON_H
#define __RV32I_CORE_COMMON_H

#include <stdint.h>

// Ignore progmem directive
#define PROGMEM

// Change pgm_reads into normal dereferences
#define pgm_read_byte(x) (uint8_t*)

#endif