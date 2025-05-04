#include <stdint.h>

volatile uint8_t *const wr = (volatile uint8_t *)0x1234;

void print_char(char c) {
  *wr = c;
  int i = 0x2000;

#pragma clang loop unroll(disable)
  while (i) {
    asm volatile("addi x0, x0, 0");
    i--;
  }
}

void print_string(const char *str) {
  while (*str != 0) {
    print_char(*str);
    str++;
  }
}

int main() {
  print_string("Hi!");
  while (1) {
    asm volatile("addi x0, x0, 0");
  }
  return 0;
}
