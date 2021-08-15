// Config
#define MAX_PRIME 1000

// Core startup
asm("li sp, 0xFFFF; j main");

// Global pointers
volatile static char *tx = (char *)0x10010;
volatile static char *sx = (char *)0x10018;

void wait_tx() {
  while (!(*sx&4)) {}
}

void print(char str[]) {
  wait_tx();
  int cnt = 0;
  while (!(*sx&4)) {}
  while (str[cnt] != 0)
    *tx = str[cnt++];
}

void print_num(int val) {
  wait_tx(); *tx = ' ';
  if (val >= 100000) *tx = val / 100000 % 10 + '0'; else *tx = ' ';
  if (val >= 10000) *tx = val / 10000 % 10 + '0'; else *tx = ' ';
  if (val >= 1000) *tx = val / 1000 % 10 + '0'; else *tx = ' ';
  if (val >= 100) *tx = val / 100 % 10 + '0'; else *tx = ' ';
  if (val >= 10) *tx = val / 10 % 10 + '0'; else *tx = ' ';
  *tx = val % 10 + '0'; *tx = '\n'; *tx = '\r';
}

int main() {
  char cnt = 0;
  print("\x1b[H");
  for (int num = 2; num <= MAX_PRIME; num++) {
    char prm = 1;
    for (int div = 2; div <= num>>1; div++) {
      if (!(num % div)) {
        prm = 0;
        break;
      }
    }
    if (prm) {
      print_num(num);
      cnt++;
    }
    if (10 == cnt) {
      *tx = '\n';
      *tx = '\r';
      cnt = 0;
    }
  }
  while (1) {}
}
