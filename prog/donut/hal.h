#pragma once

#include <stdint.h>

struct lsio_hw {
  volatile uint32_t uart_tx;
  volatile uint32_t uart_rx;
  volatile uint32_t timer_ms;
  volatile uint32_t button;
  volatile uint32_t watchdog;
  volatile uint32_t err;
};

static volatile struct lsio_hw *const lsio_mmio =
    (volatile struct lsio_hw *)0x40000000;

// ======================= UART
static void print_char(char c) {
  // while (lsio_mmio->uart_tx != 0xffffffff) {
  // };

  // lsio_mmio->uart_tx = c;
}

void print_string(const char *str);
void print_hex_digit(int d);
void print_hex(int v);

// ======================== OTHER LSIO

static inline uint32_t get_time_ms() { return lsio_mmio->timer_ms; }

static inline uint32_t read_button() { return lsio_mmio->button; }

// ======================= VDE
struct vde_map {
  uint8_t frame;
  uint8_t pad_0[3];
  uint32_t color_change;
  uint32_t map_change;
};

static volatile struct vde_map *const vde_regmap =
    (volatile struct vde_map *)0x80000000;

static volatile uint32_t *const vde_spritemap = (volatile uint32_t *)0x80010000;

static void vde_set_color(uint8_t idx, uint8_t r, uint8_t g, uint8_t b) {
  vde_regmap->color_change = (idx << 24) | (r << 16) | (g << 8) | (b << 0);
}

static void vde_set_map(uint8_t y, uint8_t x, uint16_t newc) {
  vde_regmap->map_change = (x << 15) | (y << 9) | newc;
}

void vde_set_string(uint8_t y, uint8_t x, const char *str);

void vde_set_hex(uint8_t y, uint8_t x, uint32_t v);
void vde_set_dec(uint8_t y, uint8_t x, uint32_t v);

void vde_write_mono_sprite(uint16_t id, const uint8_t *vals, uint8_t color_zero,
                           uint8_t color_one);

void vde_write_color_sprite(uint16_t id, const uint8_t *colors);

struct vde_frame_counter {
  uint32_t prev_frame;
  uint32_t over_adder;
};

uint32_t vde_read_frame_cnt(struct vde_frame_counter *state);

void vde_clear_screen(uint16_t c);

// ======================= ERR

#define ERR_IS_SW 0x10
#define ERR_MASK 0xf

static inline uint32_t err_read_last() {  
  return lsio_mmio->err;
};

static inline uint32_t err_trigger(uint32_t err) {  
  lsio_mmio->err = err;
};

static inline uint32_t watchdog_set(uint32_t new_time) {
  lsio_mmio->watchdog = new_time;
}