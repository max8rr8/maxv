#include <stdint.h>
#define RAM 0x20000000

static volatile uint8_t *const uart_wr = (volatile uint8_t *)0x40000000;

static void print_char(char c) {
  *uart_wr = c;
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

int *get_self() { return (int *)get_self; }

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
  print_char(' ');
  print_char(' ');
}

struct vde_map {
  uint8_t frame;
  uint8_t pad_0[3];
  uint32_t color_change;
  uint32_t map_change;
};

static volatile struct vde_map *const vde_regmap =
    (volatile struct vde_map *)0x80000000;

static volatile uint32_t *const vde_spritemap = (volatile uint32_t *)0x80010000;

void vde_set_color(uint8_t idx, uint8_t r, uint8_t g, uint8_t b) {
  vde_regmap->color_change = (idx << 24) | (r << 16) | (g << 8) | (b << 0);
}

void vde_set_map(uint8_t x, uint8_t y, uint16_t newc) {
  vde_regmap->map_change = (x << 15) | (y << 9) | newc;
}

void vde_set_string(uint8_t y, const char *str) {
  uint8_t x = 0;
  while (*str) {
    vde_set_map(x, y, *str);
    str++;
    x++;
  }
  while (x < 80) {
    vde_set_map(x, y, ' ');
    x++;
  }
}

void vde_write_mono_sprite(uint16_t id, uint8_t *vals,
                                  uint8_t color_zero, uint8_t color_one) {

  vde_spritemap[(id << 2) + 0] =
      ((uint32_t)vals[0]) | ((uint32_t)vals[1] << 8) |
      ((uint32_t)vals[2] << 16) | ((uint32_t)vals[3] << 24);
  print_hex(vde_spritemap[(id << 2) + 0]);
  vde_spritemap[(id << 2) + 1] =
      ((uint32_t)vals[4]) | ((uint32_t)vals[5] << 8) |
      ((uint32_t)vals[6] << 16) | ((uint32_t)vals[7] << 24);

  print_char('\n');
  vde_spritemap[(id << 2) + 3] =
      (0b10000000 << 0) | (color_zero << 8) | (color_one << 16);
}


int main() {
  print_char('\n');
  print_char('\r');
  print_char('\n');
  print_char('\r');
  print_hex(*get_self());
  print_char('\n');
  print_char('\r');

  
  uint32_t i = 0;
  while (1) {
    int cnt = 0;
    uint8_t start_frame = vde_regmap->frame;
    while (vde_regmap->frame == start_frame)
      cnt++;

    vde_set_map(5, 5, 258);

    uint8_t sprite[] = {
        0b00000000, 0b00100100, 0b00011000, 0b00100100,
        0b00100100, 0b00111100, 0b00000000, 0b00000000,
    };
    vde_write_mono_sprite(258, sprite, 1, 2);

    if (i % 32 == 4) {
      vde_set_string(2, "  Love");
    }

    if (i % 32 == 20) {
      vde_set_string(2, "  You <3");
    }

    i++;
  }
  return 0;
}
