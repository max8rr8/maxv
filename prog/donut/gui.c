#include "gui.h"
#include "hal.h"

static void menu_row_clear(int row_i) {
  vde_set_map(row_i + MENU_Y, 48, 0x0);

  vde_set_map(row_i + MENU_Y, MENU_VAL_X - 2, 0);
  vde_set_map(row_i + MENU_Y, MENU_VAL_X + 2, 0);
}

static void menu_row_refresh(struct gui_state *state) {
  if (state->menu_mode == 0) {
    vde_set_map(state->menu_pos + MENU_Y, 48, 0x4);
  } else {
    vde_set_map(state->menu_pos + MENU_Y, MENU_VAL_X - 2, 0x11);
    vde_set_map(state->menu_pos + MENU_Y, MENU_VAL_X + 2, 0x10);
  }
}

void gui_init(struct gui_state *state) {
  vde_set_color(0, 0, 0, 0);
  vde_set_color(1, 255, 255, 255);

  state->menu_pos = 0;
  state->menu_mode = 0;

  menu_row_refresh(state);

  vde_set_string(0, 0, "  ");
  vde_set_string(1, 0, "  ");

  vde_set_string(0, 2, "Time");
  vde_set_string(0, 14, "Rendered");
  vde_set_string(0, 26, "Displayed");
  vde_set_string(0, 38, "FPS*1000");
  vde_set_string(0, 50, "RaySteps");

  vde_set_string(MENU_Y + 0, 50, "Colors");
  vde_set_string(MENU_Y + 1, 50, "R1 Steps");
  vde_set_string(MENU_Y + 2, 50, "R2 Steps");
  vde_set_string(MENU_Y + 3, 50, "Speed A");
  vde_set_string(MENU_Y + 4, 50, "Speed B");
  vde_set_string(MENU_Y + 5, 50, "Crash");
}

static uint32_t calc_fps(uint32_t time, uint32_t rendered) {
  uint32_t rendered_low = rendered & 255;
  uint32_t rendered_hi = rendered >> 8;

  uint32_t fps_lo = rendered_low * 1000000 / time;
  uint32_t fps_hi = (256 * 1000000 / time) * rendered_hi;

  return fps_hi + fps_lo;
}

void gui_update_counters(struct gui_state *state, uint32_t rendered,
                         uint32_t ray_steps) {
  uint32_t time = get_time_ms();
  uint32_t frame_cnt = vde_read_frame_cnt(&state->vde_framecnt);

  vde_set_dec(1, 2, get_time_ms());
  vde_set_dec(1, 14, rendered);
  vde_set_dec(1, 26, frame_cnt);
  vde_set_dec(1, 38, calc_fps(time, rendered));
  vde_set_dec(1, 50, ray_steps);
}

void gui_handle_key(struct gui_state *state, int key, int is_long) {
  menu_row_clear(state->menu_pos);
  if (!is_long) {
    if (state->menu_mode == 0) {
      vde_set_map(state->menu_pos + MENU_Y, 48, 0x0);

      state->menu_pos += key;
      if (state->menu_pos < 0)
        state->menu_pos = MENU_ROWS - 1;

      if (state->menu_pos >= MENU_ROWS)
        state->menu_pos = 0;

      vde_set_map(state->menu_pos + MENU_Y, 48, 0x4);
    } else {
      gui_row_change(state->menu_pos, key);
    }
  } else {
    if (state->menu_mode == 0) {
      state->menu_mode = 1;
    } else {
      state->menu_mode = 0;
    }
  }
  menu_row_refresh(state);
}

void gui_update_menu(struct gui_state *state) {
  // for (int i = 0; i < 5; i++) {
  //   if (state->menu_pos == i) {
  //     vde_set_map(state->menu_pos + 5, 48, 0x4);
  //   } else {
  //     vde_set_map(state->menu_pos + 5, 48, 0x0);
  //   }
  // }
}