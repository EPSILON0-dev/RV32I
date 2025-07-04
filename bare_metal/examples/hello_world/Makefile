# EDIT ME!
GCC_PATH    ?= /home/epsilon/Documents/compilers/riscv/bin
GCC_PREFIX  ?= riscv64-unknown-elf-

CC          := $(GCC_PATH)/$(GCC_PREFIX)gcc
OBJCOPY     := $(GCC_PATH)/$(GCC_PREFIX)objcopy
OBJDUMP     := $(GCC_PATH)/$(GCC_PREFIX)objdump
AS_FLAGS    := -march=rv32i_zicsr -mabi=ilp32
CC_FLAGS    := -march=rv32i_zicsr -mabi=ilp32 --std=c99 -I../hal -Os -g
CC_FLAGS    += -ffunction-sections -fdata-sections -DF_CPU=12000000
LINK_FLAGS  := -march=rv32i_zicsr -mabi=ilp32 -nostartfiles -Tlink.ld
LINK_FLAGS  += -Wl,--gc-sections -Wl,--print-memory-usage

ASM_SOURCES := start.S
C_SOURCES   := main.c
TARGET      := build/hello_world

OBJECTS     := $(patsubst %.c, build/%.o, $(C_SOURCES))
OBJECTS     += $(patsubst %.S, build/%.o, $(ASM_SOURCES))
OBJECTS     += build/hal.o
BINARY      := $(patsubst %, %.hex, $(TARGET))
LISTING     := $(patsubst %, %.lst, $(TARGET))

all: build $(BINARY) $(LISTING)

build:
	mkdir build

build/hal.o:
	$(CC) -c $(CC_FLAGS) -o $@ ../../hal/hal.c

build/%.o: %.S
	$(CC) -c $(AS_FLAGS) -o $@ $<

build/%.o: %.c
	$(CC) -c $(CC_FLAGS) -o $@ $<

$(TARGET): $(OBJECTS)
	$(CC) $(LINK_FLAGS) -o $@ $^

%.hex: %
	$(OBJCOPY) $< $@ -O binary

%.lst: %
	$(OBJDUMP) -S -d $< > $@

clean:
	-rm $(BINARY)
	-rm $(LISTING)
	-rm $(TARGET)
	-rm $(OBJECTS)
	-rmdir build
