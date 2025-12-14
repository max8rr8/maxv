#include <stdint.h>

#include "donut.h"

#define USE_MULTIPLIER 1

const int torus_radi = 1000, r1 = 1, r2 = 2;

// HAKMEM 149 - Minsky circle algorithm
#define R(s, x, y)                                                             \
  x -= (y >> (s));                                                             \
  y += (x >> (s))

// CORDIC - Get length of vector (x, y)
// and rotate vector (x2, y2) to angle from initial vector
static int length_cordic(fp_t x, fp_t y, fp_t *x2_, fp_t y2, int iters) {
  int x2 = *x2_;
  if (x < 0) { // start in right half-plane
    x = -x;
    x2 = -x2;
  }
  for (int i = 0; i < iters; i++) {
    int t = x;
    int t2 = x2;
    if (y < 0) {
      x -= y >> i;
      y += t >> i;
      x2 -= y2 >> i;
      y2 += t2 >> i;
    } else {
      x += y >> i;
      y -= t >> i;
      x2 += y2 >> i;
      y2 -= t2 >> i;
    }
  }

  *x2_ = ((int32_t)x2 * 9945) >> 14;
  return ((int32_t)x * 9945) >> 14;
}

static inline fp_t fpmul(fp_t a, fp_t b) { return (a * b) >> 14; }

void donut_render(struct donut_state *state) {
  fp_t sin_A = state->sin_A;
  fp_t cos_A = state->cos_A;
  fp_t sin_B = state->sin_B;
  fp_t cos_B = state->cos_B;

  fp_t p0x = (torus_radi * sin_B) >> 8;
  fp_t p0y = (torus_radi * fpmul(sin_A, cos_B)) >> 8;
  fp_t p0z = (-torus_radi * fpmul(cos_A, cos_B)) >> 8;

  const int r1i = r1 * 256;
  const int r2i = r2 * 256;

  fp_t yincC = (20 * cos_A) >> 8;
  fp_t yincS = (20 * sin_A) >> 8;

  fp_t xincX = (20 * cos_B) >> 8;
  fp_t xincY = (20 * fpmul(sin_A, sin_B)) >> 8;
  fp_t xincZ = (20 * fpmul(cos_A, sin_B)) >> 8;

  fp_t ycA = -20 * yincC;
  fp_t ysA = -20 * yincS;

  fp_t lx0 = sin_B >> 2;
  fp_t ly0 = (fpmul(sin_A, cos_B) - cos_A) >> 2;
  fp_t lz0 = (-fpmul(cos_A, cos_B) - sin_A) >> 2;

  fp_t start_vx = (-20 * xincX) - sin_B;
  fp_t start_vy = -(-20 * xincY) - fpmul(sin_A, cos_B);
  fp_t start_vz = +(-20 * xincZ) + fpmul(cos_A, cos_B);

  uint32_t ray_steps = 0;

  for (int pos_y = 0; pos_y < 39; pos_y++, ycA += yincC, ysA += yincS) {
    fp_t vxi14 = start_vx;
    fp_t vyi14 = ycA + start_vy;
    fp_t vzi14 = ysA + start_vz;

    for (int pos_x = 0; pos_x < 39;
         pos_x++, vxi14 += xincX, vyi14 -= xincY, vzi14 += xincZ) {
      int t = 512; // (256 * dz) - r2i - r1i;

      fp_t px = (p0x + vxi14 + (vxi14 >> 1)) >> 6;
      fp_t py = (p0y + vyi14 + (vyi14 >> 1)) >> 6;
      fp_t pz = (p0z + vzi14 + (vzi14 >> 1)) >> 6;

      for (;;) {
        ray_steps++;

        int t0, t1, t2, d;
        fp_t lx = lx0, ly = ly0, lz = lz0;
        t0 = length_cordic(px, py, &lx, ly, state->r1_iters);

        t1 = t0 - r2i;
        t2 = length_cordic(pz, t1, &lz, lx, state->r2_iters);
        d = t2 - r1i;
        t += d;

        if (t > 8 * 256) {
          donut_emit_bg(pos_x, pos_y);
          break;
        } else if (d < 8) {
          int N = lz < 0 ? 0 : (lz >> 10);

          if (N < 0)
            N = 0;

          donut_emit_pixel(N, pos_x, pos_y);
          break;
        }

        px += fpmul(d, vxi14);
        py += fpmul(d, vyi14);
        pz += fpmul(d, vzi14);
      }
    }
  }
  state->ray_steps = ray_steps;
}

void donut_rotate(struct donut_state *state) {
  for (int i = 0; i < state->speed_A; i++) {
    R(5, state->cos_A, state->sin_A);
  }
  for (int i = 0; i < state->speed_B; i++) {
    R(5, state->cos_B, state->sin_B);
  }
}

void donut_init(struct donut_state *state) {
  state->sin_B = 0;
  state->cos_B = TO_FP(1, 1);
  // state->sin_A = 0;
  // state->cos_A = TO_FP(1,1);
  state->sin_A = FP_SIN_PI4;
  state->cos_A = FP_SIN_PI4;
  state->r1_iters = 8;
  state->r2_iters = 8;
  state->speed_A = 4;
  state->speed_B = 3;
}
