#include <stdint.h>

#include "donut.h"
#include "gui.h"
#include "hal.h"

#define COLOR_FG1 100
#define COLOR_FG2 101
#define COLOR_BG1 102
#define COLOR_BG2 103

#define SPRITE_DONUT 280
#define SPRITE_BACK 300

struct app_state {
  struct donut_state donut;
  struct gui_state gui;

  uint32_t color_idx;
  uint32_t crash_mode;
};

struct app_state *const app = (struct app_state *)0x20000000;

volatile static const char strr[] = " .,-~:;!*=#$@";

static char get_n_char(int N) { return strr[N]; }

static const uint8_t sprite_half[] = {0xaa, 0x55, 0xaa, 0x55,
                                      0xaa, 0x55, 0xaa, 0x55};
static const uint8_t sprite_quarter[] = {0, 0x55, 0, 0x55, 0, 0x55, 0, 0x55};
static const uint8_t sprite_eigth[] = {0, 0x11, 0, 0x44, 0, 0x11, 0, 0x44};

void donut_emit_bg(int x, int y) {
  int bg_pat = (x & 1) * 2 + (y & 1);
  vde_set_map(y + 4, x, SPRITE_BACK + bg_pat);
}

void donut_emit_pixel(int N, int x, int y) {
  vde_set_map(y + 4, x, N < 5 ? SPRITE_DONUT + N : SPRITE_DONUT + 5);
}

struct color_cfg {
  uint8_t bg1[3];
  uint8_t bg2[3];
  uint8_t fg1[3];
  uint8_t fg2[3];
};

static const struct color_cfg colors[] = {
    {
        {128, 0, 128}, // Purple
        {32, 0, 32},   // Dark Purple
        {255, 128, 0}, // Orange
        {167, 64, 40}  // Dark orange
    },

    {
        {64, 64, 64},    // Dark Gray
        {192, 192, 192}, // Light Gray
        {255, 0, 0},     // Red
        {0, 255, 0}      // Green
    },

    {
        {255, 0, 0},     // Red
        {0, 255, 0},     // Green
        {192, 192, 192}, // Light Gray
        {64, 64, 64},    // Dark Gray
    },

    {
        {0, 0, 0},   // Black
        {0, 0, 0},   // Black
        {255, 0, 0}, // Red
        {60, 0, 0}   // Darkest red
    },
};

void update_color() {
  const struct color_cfg *entry = &colors[app->color_idx & 0x3];

  vde_set_color(COLOR_FG1, entry->fg1[0], entry->fg1[1], entry->fg1[2]);
  vde_set_color(COLOR_FG2, entry->fg2[0], entry->fg2[1], entry->fg2[2]);
  vde_set_color(COLOR_BG1, entry->bg1[0], entry->bg1[1], entry->bg1[2]);
  vde_set_color(COLOR_BG2, entry->bg2[0], entry->bg2[1], entry->bg2[2]);
}

static void redraw_menu() {
  vde_set_map(MENU_Y + 1, MENU_VAL_X, '0' + app->donut.r1_iters);
  vde_set_map(MENU_Y + 2, MENU_VAL_X, '0' + app->donut.r2_iters);
  vde_set_map(MENU_Y + 3, MENU_VAL_X, '0' + app->donut.speed_A);
  vde_set_map(MENU_Y + 4, MENU_VAL_X, '0' + app->donut.speed_B);
  vde_set_map(MENU_Y + 5, MENU_VAL_X, " IMLS"[app->crash_mode]);
}

static inline int next_value(int cur_value, int dir, int min, int max) {
  int range = max - min + 1;
  return ((cur_value + range + dir - min) % range) + min;
}

void gui_row_change(int row, int direction) {
  if (row == 0) {
    app->color_idx++;
    update_color();
  } else if (row == 1) {
    app->donut.r1_iters = next_value(app->donut.r1_iters, direction, 1, 8);
  } else if (row == 2) {
    app->donut.r2_iters = next_value(app->donut.r2_iters, direction, 1, 8);
  } else if (row == 3) {
    app->donut.speed_A = next_value(app->donut.speed_A, direction, 0, 9);
  } else if (row == 4) {
    app->donut.speed_B = next_value(app->donut.speed_B, direction, 0, 9);
  } else if (row == 5) {
    app->crash_mode = next_value(app->crash_mode, direction, 0, 4);
  }
  redraw_menu();
}

void gui_row_finish(int row) {
  if (row == 5) {
    if (app->crash_mode == 1) {
      asm volatile("ecall");
    } else if (app->crash_mode == 2) {
      volatile uint32_t *ptr = (volatile uint32_t *)0xfffffff0;
      (void)*ptr;
    } else if (app->crash_mode == 3) {
      volatile uint32_t i = 0;
      while (1) {
        asm volatile("nop" ::: "memory");
      }
    } else if (app->crash_mode == 4) {
      err_trigger(4);
    }
  }
}

const uint8_t colorSprite[] = {100, 100, 101, 101, 100, 100, 101, 101,
                               102, 102, 103, 103, 102, 102, 103, 103};

static const uint8_t sprite_bg0[] = {0, 0, 0, 0, 0, 0, 0, 0};
static const uint8_t sprite_bg1[] = {0xf0, 0xf0, 0xf0, 0xf0,
                                     0xf,  0xf,  0xf,  0xf};

int main() {
  watchdog_set(2000);
  vde_clear_screen(0);

  uint32_t last_err = err_read_last();

  if (last_err & ERR_MASK) {
    vde_set_color(0, 255, 0, 0);
    vde_set_color(1, 0, 0, 0);

    vde_set_string(2, 2, "Restarted due to ERROR!");
    vde_set_string(3, 3, "W error code: ");
    vde_set_map(3, 2, (last_err & ERR_IS_SW) ? 'S' : 'H');
    vde_set_hex(3, 17, last_err & ERR_MASK);

    while (get_time_ms() < 8000) {
      watchdog_set(1200);
    }

    watchdog_set(2000);
    vde_clear_screen(0);
  }

  vde_set_color(0, 0, 0, 0);
  vde_set_color(1, 0, 0, 0);

  struct vde_frame_counter vde_frame_cnt = {};

  gui_init(&app->gui);

  app->color_idx = 0;
  app->crash_mode = 0;
  update_color();

  vde_write_mono_sprite(SPRITE_DONUT + 0, sprite_eigth, COLOR_FG2, COLOR_FG1);
  vde_write_mono_sprite(SPRITE_DONUT + 1, sprite_quarter, COLOR_FG2, COLOR_FG1);
  vde_write_mono_sprite(SPRITE_DONUT + 2, sprite_half, COLOR_FG2, COLOR_FG1);
  vde_write_mono_sprite(SPRITE_DONUT + 3, sprite_quarter, COLOR_FG1, COLOR_FG2);
  vde_write_mono_sprite(SPRITE_DONUT + 4, sprite_eigth, COLOR_FG1, COLOR_FG2);
  vde_write_mono_sprite(SPRITE_DONUT + 5, sprite_half, COLOR_FG1, COLOR_FG1);

  uint64_t count = 0;
  donut_init(&app->donut);

  vde_write_color_sprite(400, colorSprite);
  vde_set_map(MENU_Y, MENU_VAL_X, 400);
  redraw_menu();

  for (;;) {
    watchdog_set(1000);
    uint32_t btn = read_button();
    uint32_t right_btn = btn & 0x20;
    uint32_t left_btn = btn & 0x2000;
    if (right_btn || left_btn) {
      vde_set_hex(50, 1, btn);

      if (right_btn) {
        gui_handle_key(&app->gui, 1, (btn & 0x1f) > 0x6);
      } else {
        gui_handle_key(&app->gui, -1, (btn & 0x1f00) > 0x600);
      }
    }

    gui_update_menu(&app->gui);

    donut_render(&app->donut);
    donut_rotate(&app->donut);

    count++;
    gui_update_counters(&app->gui, count, app->donut.ray_steps);

    uint8_t sprite_info[8];
    uint64_t bg_pos = (count + 5) % 8;
    for (int i = 0; i < 8; i++) {
      sprite_info[i] = (0xff00 >> bg_pos) & 0xff;
      if (i < bg_pos)
        sprite_info[i] ^= 0xff;
    }
    vde_write_mono_sprite(SPRITE_BACK + 0, sprite_info, COLOR_BG1, COLOR_BG2);
    vde_write_mono_sprite(SPRITE_BACK + 1, sprite_info, COLOR_BG2, COLOR_BG1);
    vde_write_mono_sprite(SPRITE_BACK + 2, sprite_info, COLOR_BG2, COLOR_BG1);
    vde_write_mono_sprite(SPRITE_BACK + 3, sprite_info, COLOR_BG1, COLOR_BG2);
  }
}
