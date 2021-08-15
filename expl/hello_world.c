asm("li sp, 0xFFFF; j main");

static const char str[] = "Hello, world!\n\r";
volatile static char *led = (char *)0x10000;
volatile static char *tx = (char *)0x10010;
volatile static char *rx = (char *)0x10014;
volatile static char *sx = (char *)0x10018;

int main() {
  while (1) {
    while (!(*sx&4)) {}
    int cnt = 0;
    while (cnt <= 15)
      *tx = str[cnt++];
    while (*sx&1) {}
    *led = *rx;
  }
}
