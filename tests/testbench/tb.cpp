#include <stdio.h>
#include <stdint.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VCPU.h"

#define MAX_CYCLES 10000

static uint8_t memory[32 * 1024]; // 32KB array

void load_file_to_memory(const char* filename) {
    FILE* file = fopen(filename, "rb");
    fread(memory, 1, sizeof(memory), file);
    fclose(file);
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
    for (int i = 0; i < MAX_CYCLES; i++)
    {
        // Rising edge
        top->Clk = 1;
        top->eval();
        vcd->dump(i * 2 + 0);

        // Falling edge
        top->Input_Data = memory[top->Address & 0x7ffc] |
            (memory[(top->Address & 0x7ffc) + 1] << 8)  |
            (memory[(top->Address & 0x7ffc) + 2] << 16) |
            (memory[(top->Address & 0x7ffc) + 3] << 24);
        if (top->Write_Enable & 0b0001)
            memory[(top->Address & 0x7ffc) + 0] = top->Output_Data & 0xff;
        if (top->Write_Enable & 0b0010)
            memory[(top->Address & 0x7ffc) + 1] = (top->Output_Data >> 8) & 0xff;
        if (top->Write_Enable & 0b0100)
            memory[(top->Address & 0x7ffc) + 2] = (top->Output_Data >> 16) & 0xff;
        if (top->Write_Enable & 0b1000)
            memory[(top->Address & 0x7ffc) + 3] = (top->Output_Data >> 24) & 0xff;
        top->Clk = 0;
        top->eval();
        vcd->dump(i * 2 + 1);
    }

    printf("%d\n", memory[0]);

    delete top;
    delete contextp;
    return 0;
}
