#pragma once

#include "stdint.h"

typedef int32_t fp_t;
#define TO_FP(x, div) (fp_t)((x << 14) / div)
#define FP_SIN_PI4 11583

struct donut_state {
  fp_t sin_A;
  fp_t cos_A;

  fp_t sin_B;
  fp_t cos_B;

  uint32_t ray_steps;

  int r1_iters;
  int r2_iters;
  int speed_A;
  int speed_B;
};

void donut_render(struct donut_state *state);
void donut_rotate(struct donut_state *state);
void donut_init(struct donut_state *state);

void donut_emit_pixel(int N, int x, int y);
void donut_emit_bg(int x, int y);
void donut_finish_line(int y);
