#include <stdint.h>
#define RAM 0x20000000

static volatile uint32_t *const wr = (volatile uint32_t *)0x40000000;

static void *const RAM_BASE = (void *)0x20000000;

struct GLOBALS {
  uint32_t *addr;
  void (*entr)();
  uint32_t stat;
  uint32_t failn;
};

static struct GLOBALS *const g = RAM_BASE;

static void print_char(char c) {
  while (*wr != 0xffffffff) {
  };

  *wr = c;
}

static char read_char() {
  while (1) {
    uint32_t c = *(wr + 0x1);
    if (c > 0xfff)
      return c & 0xff;
  }
}

static void print_hex_digit(int d) {
  if (d < 10)
    print_char(d + '0');
  else
    print_char(d + 'a' - 10);
}

static void print_hex(int v) {
  for (int i = 0; i < 8; i++) {
    print_hex_digit((v >> 28) & 0xF);
    v <<= 4;
  }
}

static int read_hex_digit() {
  char c = read_char();

  if (c < 'a')
    return c - '0';
  else
    return c - 'a' + 10;
}

static uint32_t read_hex() {
  int v = 0;
  for (int i = 0; i < 8; i++) {
    int d = read_hex_digit();
    v = v << 4;
    v = v | d;
  }

  return v;
}

void harness(int pass, int code) {
  if (pass) {
    print_char('P');
  } else {
    print_char('F');
  }

  while (1) {
    asm volatile("addi x0, x0, 0");
  }
}

static void hex_entry() {
  int g = read_hex();
  print_hex(g);
}

void root_main() {
  print_char('>');
  char cmd = read_char();

  switch (cmd) {
  case 'A':
    g->addr = (uint32_t *)read_hex();
    break;

  case 'N':
    g->addr++;
    break;

  case 'R':
    print_hex(*g->addr);
    break;

  case 'W':
    *g->addr = read_hex();
    break;

  case 'J':
    g->failn = 0;
    g->stat = 1;
    ((void (*)(void))g->addr)();
    break;
  }

  return;
}
