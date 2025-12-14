#include "hal.h"

void print_string(const char *str) {
  while (*str != 0) {
    print_char(*str);
    str++;
  }
}

void print_hex_digit(int d) {
  if (d < 10)
    print_char(d + '0');
  else
    print_char(d + 'a' - 10);
}

void print_hex(int v) {
  for (int i = 0; i < 8; i++) {
    print_hex_digit((v >> 28) & 0xF);
    v <<= 4;
  }
  print_char(' ');
  print_char(' ');
}

volatile static const char strr[] = " .,-~:;!*=#$@";

static char get_n_char(int N) { return strr[N + 1]; }

void vde_set_string(uint8_t y, uint8_t x, const char *str) {
  while (*str) {
    vde_set_map(y, x, *str);
    str++;
    x++;
  }
  while (x < 80) {
    vde_set_map(y, x, ' ');
    x++;
  }
}

void vde_set_hex(uint8_t y, uint8_t x, uint32_t v) {
  for (int i = 0; i < 8; i++) {
    uint8_t d = (v >> 28) & 0xF;
    if (d <= 9)
      vde_set_map(y, x + i, '0' + d);
    else
      vde_set_map(y, x + i, 'a' - 10 + d);
    v <<= 4;
  }
}

void vde_set_dec(uint8_t y, uint8_t x, uint32_t v) {
  for (int i = 0; i < 8; i++) {
    uint8_t d = (v % 10);
    vde_set_map(y, x + 7 - i, '0' + d);
    v /= 10;
  }
}

void vde_write_mono_sprite(uint16_t id, const uint8_t *vals, uint8_t color_zero,
                           uint8_t color_one) {

  vde_spritemap[(id << 2) + 0] =
      ((uint32_t)vals[0]) | ((uint32_t)vals[1] << 8) |
      ((uint32_t)vals[2] << 16) | ((uint32_t)vals[3] << 24);
  vde_spritemap[(id << 2) + 1] =
      ((uint32_t)vals[4]) | ((uint32_t)vals[5] << 8) |
      ((uint32_t)vals[6] << 16) | ((uint32_t)vals[7] << 24);
  vde_spritemap[(id << 2) + 3] =
      (0b10000000 << 0) | (color_zero << 8) | (color_one << 16);
}

void vde_write_color_sprite(uint16_t id, const uint8_t *vals) {
  for (int i = 0; i < 4; i++)
    vde_spritemap[(id << 2) + i] =
        ((uint32_t)vals[i * 4 + 0]) | ((uint32_t)vals[i * 4 + 1] << 8) |
        ((uint32_t)vals[i * 4 + 2] << 16) | ((uint32_t)vals[i * 4 + 3] << 24);
}

uint32_t vde_read_frame_cnt(struct vde_frame_counter *state) {
  uint32_t cur = vde_regmap->frame;
  if (cur < state->prev_frame) {
    state->over_adder += 0x100;
  }
  state->prev_frame = cur;
  return state->over_adder + cur;
}
