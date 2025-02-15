# In general march=rv32i should be used but I don't have a multilib configured
#  for it rn.
CC          := $(GCC_PATH)/$(GCC_PREFIX)gcc
OBJCOPY     := $(GCC_PATH)/$(GCC_PREFIX)objcopy
OBJDUMP     := $(GCC_PATH)/$(GCC_PREFIX)objdump
AS_FLAGS    := -march=rv32i_zicsr -mabi=ilp32
CC_FLAGS    := -march=rv32i_zicsr -mabi=ilp32 -I../hal -O2
CC_FLAGS    += -ffunction-sections -fdata-sections
LINK_FLAGS  := -march=rv32i_zicsr -mabi=ilp32 -nostartfiles -Tlink.ld
LINK_FLAGS  += -Wl,--gc-sections -Wl,--print-memory-usage

ASM_SOURCES := start.S
C_SOURCES   := bootloader.c
TARGET      := bootloader

OBJECTS     := $(patsubst %.c, %.o, $(C_SOURCES))
OBJECTS     += $(patsubst %.S, %.o, $(ASM_SOURCES))
BINARY      := $(patsubst %, %.hex, $(TARGET))
LISTING     := $(patsubst %, %.lst, $(TARGET))

build: $(BINARY) $(LISTING)

%.o: %.S
	$(CC) -c $(AS_FLAGS) -o $@ $<

%.o: %.c
	$(CC) -c $(CC_FLAGS) -o $@ $<

$(TARGET): $(OBJECTS)
	$(CC) $(LINK_FLAGS) -o $@ $^

%.hex: %
	$(OBJCOPY) $< $@ -O binary

%.lst: %
	$(OBJDUMP) -d $< > $@

clean:
	-rm $(BINARY)
	-rm $(LISTING)
	-rm $(OBJECTS)
