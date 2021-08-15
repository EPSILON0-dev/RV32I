#include <stdlib.h>
asm("li sp, 0xFFFF");

int main() {
  char *alloc_space;
  alloc_space = malloc(10);
  *(alloc_space    ) = 't';
  *(alloc_space + 1) = 'e';
  *(alloc_space + 2) = 's';
  *(alloc_space + 3) = 't';
  *(alloc_space + 4) = '\0';
  while (*alloc_space != '\0')
    *(char*)0x10010 = *(alloc_space++);
  while (1) {}
}
