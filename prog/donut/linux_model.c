#include "donut.h"
#include <assert.h>
#include <stdio.h>
#include <unistd.h>

void donut_emit_bg(int x, int y) {
  putchar(' ');
}

void donut_emit_pixel(int N, int x, int y) {
  assert(N <= 11);
  if(N > 5) putchar('X');
  else putchar('.');
  // putchar('0' + N);
}

void donut_finish_line(int y) {
  puts("");
}


int main() {
  struct donut_state state;

  donut_init(&state);
  for (;;) {
    donut_render(&state);
    donut_rotate(&state);
    fflush(stdout);
    usleep(15000);
    printf("\r\x1b[39A");
  }
}