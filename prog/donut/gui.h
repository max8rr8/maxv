#pragma once

#include <stdint.h>
#include "hal.h"

#define MENU_ROWS 5
#define MENU_Y 5
#define MENU_VAL_X 64

struct gui_state {
  struct vde_frame_counter vde_framecnt;
  
  int menu_pos;
  int menu_mode;
};


void gui_init(struct gui_state *state);

void gui_update_counters(struct gui_state *state, uint32_t rendered, uint32_t ray_steps);

void gui_update_menu(struct gui_state *state);

void gui_handle_key(struct gui_state *state, int key, int is_long);

void gui_row_change(int row, int direction);