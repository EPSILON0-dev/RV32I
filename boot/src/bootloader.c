#include <ctype.h>
#include <hal.h>

#define ISP_BUTTON_GPIO      GPIO_6
#define ALLOWED_REGION_START 0x08000
#define ALLOWED_REGION_END   0x10000
#define CMDBUFF_SIZE         128
#define WORDS_PER_LINE       4
#define WRITE_LOOP_LIMIT     16
#define BAUD_RATE            9600

// Run "function"
void (*run)(void) = (void (*)(void))(ALLOWED_REGION_START);

// Messages
const char *intro = "\r\n\nRV32I bootloader v1.0, written by EPSILON0\r\n";
const char *error_command = "I don't know this command :c\r\n";
const char *error_misaligned = "Misaligned access :c\r\n";
const char *error_region = "Can't access this region :c\r\n";

// Buffer
static char cmdbuff[CMDBUFF_SIZE];

void print_str(const char *str)
{
    while (*str) uart_tx(*(str++));
}

void print_hex(uint32_t val, uint8_t digs)
{
    const char *hexdigs = "0123456789ABCDEF";
    const uint8_t shift_right = (digs - 1) * 4;
    for (int i = 0; i < digs; i++)
    {
        uart_tx(hexdigs[(val >> shift_right) & 0xff]);
        val <<= 4;
    }
}

int hex_to_int(char c)
{
    if (c >= '0' && c <= '9')
        return c - '0';
    if (c >= 'A' && c <= 'F')
        return c - 'A' + 10;
    if (c >= 'a' && c <= 'f')
        return c - 'a' + 10;
    return 0;
}

uint32_t str_to_hex(const char *ptr)
{
    uint32_t val = 0;
    while (isxdigit(*ptr))
    {
        val <<= 4;
        val |= hex_to_int(*ptr);
        ptr ++;
    }
    return val;
}

bool check_access(size_t addr)
{
    if (addr & 0b11)
    {
        print_str(error_misaligned);
        return false;
    }

    if (addr < ALLOWED_REGION_START || addr >= ALLOWED_REGION_END)
    {
        print_str(error_region);
        return false;
    }

    return true;
}

uint32_t mem_read(size_t addr)
{
    return check_access(addr) ? *((uint32_t*)(addr)) : 0;
}

void mem_write(size_t addr, uint32_t dat)
{
    if (check_access(addr)) *((uint32_t*)(addr)) = dat;
}

void exec_cmd(void)
{
    size_t index = 0;

    // Handle run command
    if ((cmdbuff[0] == 'r' || cmdbuff[0] == 'R') && cmdbuff[1] == '\r')
        run();

    // Get the first address
    const size_t addr_1 = str_to_hex(cmdbuff);
    while (isxdigit(cmdbuff[index])) index ++;

    // Handle single read
    if (cmdbuff[index] == '\r')
    {
        print_hex(addr_1, 8);
        print_str(": ");
        print_hex(mem_read(addr_1), 8);
        print_str("\r\n");
        return;
    }

    // Handle multiple read
    else if (cmdbuff[index] == '.')
    {
        const size_t addr_2 = str_to_hex(&cmdbuff[index + 1]);
        if (addr_2 & 0b11)
        {
            print_str(error_misaligned);
            return;
        }

        size_t addr = addr_1;
        uint8_t break_counter = 0;
        while (addr < addr_2)
        {
            if (break_counter == 0)
            {
                print_str("\r\n");
                print_hex(addr, 8);
                print_str(": ");
            }

            print_hex(mem_read(addr), 8);
            uart_tx(' ');
            addr += 4;
            break_counter = (break_counter + 1) % WORDS_PER_LINE;
        }
        print_str("\r\n");
        return;
    }

    // Handle write
    else if (cmdbuff[index] == ':')
    {
        uint8_t loopcnt = 0;
        size_t addr = addr_1;
        index ++;
        while (loopcnt++ < WRITE_LOOP_LIMIT)
        {
            while (cmdbuff[index] == ' ') index ++;
            if (cmdbuff[index] == '\r') break;
            mem_write(addr, str_to_hex(&cmdbuff[index]));
            while (isxdigit(cmdbuff[index])) index ++;
            addr += 4;
        }
        return;
    }

    // Handle error
    else
    {
        print_str(error_command);
        return;
    }
}

int main(void)
{
    // Go straight to the code if ISP button not pressed 
    gpio_set_dir(ISP_BUTTON_GPIO, INPUT);
    if (gpio_get(ISP_BUTTON_GPIO) == true)
        run();

    // Say haiii
    uart_set_div(F_CPU / BAUD_RATE);
    delay_ms(10);
    print_str(intro);

    // Run the command loop
    uint32_t buff_index = 0;
    print_str("> ");
    for (;;)
    {
        char c = uart_rx();
        if (c == 0xff) continue;

        cmdbuff[buff_index++] = c;
        if (c == '\r')
        {
            cmdbuff[buff_index] = '\0';
            buff_index = 0;
            exec_cmd();
            print_str("> ");
        }
    }
}
