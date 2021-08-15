CC = riscv32-unknown-elf-gcc
OC = riscv32-unknown-elf-objcopy
OS = riscv32-unknown-elf-size

CFLAGS  = -Wall -O2 -march=rv32i -mabi=ilp32
LFLAGS  = -Wall -nostartfiles -lm -lc -lgcc
LFLAGS += -march=rv32i -mabi=ilp32 -T./linker.ld
CSRC  = ./hello_world.c ./game_of_life.c ./primes.c
CSRC += ./donut.c ./led.c ./malloc.c 
ADBG  = $(CSRC:.c=.S)
OBJS  = $(CSRC:.c=.o)
ELFS  = $(OBJS:.o=.elf)
BINS  = $(OBJS:.o=.bin)

.PHONY: all
all: $(BINS) cleanup

%.o: %.c
	$(CC) -c $(CFLAGS) $(INCLUDE) $< -o $@

%.S: %.c
	$(CC) -S $(CFLAGS) $(INCLUDE) $< -o $@

%.elf: %.o
	$(CC) $< $(LFLAGS) -o $@

%.bin: %.elf
	$(OC) -S -O binary $< $@
	$(OS) $<

.PHONY: debug
debug: $(ADBG) $(ELFS)

.PHONY: clean
clean:
	rm -f $(OBJS) $(ADBG) $(ELFS) $(BINS)

.PHONY: cleanup
cleanup:
	rm -f $(ELFS) $(OBJS)
