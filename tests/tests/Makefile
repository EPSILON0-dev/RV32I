SRC_DIR := src
BIN_DIR := bin
SOURCES := $(wildcard $(SRC_DIR)/*.S)
ELFS := $(patsubst $(SRC_DIR)/%.S, $(BIN_DIR)/%.elf, $(SOURCES))
BINARIES := $(patsubst $(BIN_DIR)/%.elf, $(BIN_DIR)/%.hex, $(ELFS))
LISTINGS := $(patsubst $(BIN_DIR)/%.elf, $(BIN_DIR)/%.lst, $(ELFS))

CC := $(GCC_PATH)/$(GCC_PREFIX)gcc
OBJCOPY := $(GCC_PATH)/$(GCC_PREFIX)objcopy
OBJDUMP := $(GCC_PATH)/$(GCC_PREFIX)objdump
AS_FLAGS := -nostartfiles -march=rv32i -mabi=ilp32 -Iinc -Tinc/link.ld

all: $(BIN_DIR) $(ELFS) $(BINARIES) $(LISTINGS)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(BIN_DIR)/%.elf: $(SRC_DIR)/%.S
	$(CC) $(AS_FLAGS) -o $@ $<

$(BIN_DIR)/%.hex: $(BIN_DIR)/%.elf
	$(OBJCOPY) $< $@ -O binary

$(BIN_DIR)/%.lst: $(BIN_DIR)/%.elf
	$(OBJDUMP) -d $< > $@

clean:
	-rm -r $(BIN_DIR)
