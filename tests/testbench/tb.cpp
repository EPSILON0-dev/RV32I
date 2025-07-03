#include <stdio.h>
#include <stdint.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VCPU.h"

#define DEBUG_WRITES 0

#if DEBUG_WRITES != 0
#define MAX_CYCLES 100000
#else
#define MAX_CYCLES 10000
#endif

static int cycle;
static uint8_t memory[64 * 1024]; // 64KB array

void load_file_to_memory(const char* filename) {
    FILE* file = fopen(filename, "rb");
    fread(memory, 1, sizeof(memory), file);
    fclose(file);
}

void read_memory(VCPU *top)
{
    if (top->Address < 0x10000)
        top->Input_Data = memory[top->Address & 0xfffc] |
            (memory[(top->Address & 0xfffc) + 1] << 8)  |
            (memory[(top->Address & 0xfffc) + 2] << 16) |
            (memory[(top->Address & 0xfffc) + 3] << 24);
    else if (top->Address == 0x20020)
        top->Input_Data = cycle * 200;
    else
        top->Input_Data = 0;
}

void write_memory(VCPU *top)
{
    if (top->Address < 0x10000 && top->Write_Enable & 0b0001)
        memory[(top->Address & 0xfffc) + 0] = top->Output_Data & 0xff;
    if (top->Address < 0x10000 && top->Write_Enable & 0b0010)
        memory[(top->Address & 0xfffc) + 1] = (top->Output_Data >> 8) & 0xff;
    if (top->Address < 0x10000 && top->Write_Enable & 0b0100)
        memory[(top->Address & 0xfffc) + 2] = (top->Output_Data >> 16) & 0xff;
    if (top->Address < 0x10000 && top->Write_Enable & 0b1000)
        memory[(top->Address & 0xfffc) + 3] = (top->Output_Data >> 24) & 0xff;
#if DEBUG_WRITES != 0
    if (top->Write_Enable)
        printf("0x%08X ---> 0x%08X\n", top->Output_Data, top->Address);
#endif
}

int main(int argc, char** argv)
{
    load_file_to_memory(argv[1]);
    VerilatedContext* contextp = new VerilatedContext;

    Verilated::traceEverOn(true);
    VCPU* top = new VCPU{contextp};
    VerilatedVcdC* vcd = new VerilatedVcdC;
    top->trace(vcd, 99);
    vcd->open("CPU.vcd");

    // Reset the CPU
    top->Clk = 0;
    top->Reset = 1;
    for (int i = 0; i < 10; i++) {
        top->Clk ^= 1;
        top->eval();
    }

    // Run the test
    top->Reset = 0;
    for (cycle = 0; cycle < MAX_CYCLES; cycle++)
    {
        // Rising edge
        top->Clk = 1;
        top->eval();
        vcd->dump(cycle * 2 + 0);

        // Falling edge
        read_memory(top);
        write_memory(top);
        top->Clk = 0;
        top->eval();
        vcd->dump(cycle * 2 + 1);
    }

    printf("%d\n", memory[0]);

    delete vcd;
    delete top;
    delete contextp;
    return 0;
}
