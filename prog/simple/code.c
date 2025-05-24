#include <stdint.h>
#define RAM 0x20000000

static volatile uint8_t *const wr = (volatile uint8_t *)0x40000000;

#define CELL_COUNT_LOG2 5
#define CELL_COUNT (1 << CELL_COUNT_LOG2)
#define CELL_COUNT_MASK ((1 << CELL_COUNT_LOG2) - 1)
static uint8_t *cells = (uint8_t *)RAM;
static uint8_t *next_cells = (uint8_t *)RAM + CELL_COUNT;

static void print_char(char c) {
  *wr = c;
  int i = 0x380;

#pragma clang loop unroll(disable)
  while (i) {
    asm volatile("addi x0, x0, 0");
    i--;
  }
}

static void print_string(const char *str) {
  while (*str != 0) {
    print_char(*str);
    str++;
  }
}


int *get_self() { return (void *)get_self; }


static void print_hex_digit(int d) {
  if (d < 10)
    print_char(d + '0');
  else
    print_char(d + 'a' - 10);
}

static void print_hex(int v) {
  for(int i = 0; i < 8; i++) {
    print_hex_digit((v >> 28) & 0xF);
    v <<= 4;
  }
  print_char(' ');
  print_char(' ');
}

static void print_cells() {
  for (int i = 0; i < CELL_COUNT; i++) {
    print_char(cells[i] ? '#' : ' ');
    // print_char(' ');
  }
}

static void do_step() {
  for (int i = 0; i < CELL_COUNT; i++) {
    int left = (i - 1) & CELL_COUNT_MASK;
    int right = (i + 1) & CELL_COUNT_MASK;
    
    int lv = cells[left];
    int rv = cells[right];
    int cv = cells[i];

    if((lv == 0 && cv == 0) || (lv == 1 && cv == 1 && rv == 0)) {
      next_cells[i] = 1;
    } else {
      next_cells[i] = 0;
    }
  }
  for (int i = 0; i < CELL_COUNT; i++) {
    cells[i] = next_cells[i];
  }
}

int main() {
  for(int i = 0; i < CELL_COUNT; i++)
    cells[i] = 0;

  cells[24] = 1;
  cells[23] = 1;
  cells[10] = 1;
  cells[5] = 1;
  cells[6] = 1;
  cells[7] = 1;
  
  print_char('\n');
  print_char('\r');
  print_char('\n');
  print_char('\r');
  print_hex(*get_self());
  print_char('\n');
  print_char('\r');
  
  int i = 0;
  while(1) {
    print_hex(i++);

    print_cells();
    print_char('\n');
    print_char('\r');
    do_step();
  }
  return 0;
}

