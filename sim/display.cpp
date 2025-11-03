
#include <SDL3/SDL.h>
#include <SDL3/SDL_events.h>
#include <SDL3/SDL_pixels.h>
#include <SDL3/SDL_render.h>
#include <SDL3/SDL_surface.h>
#include <cstdint>
#include <iostream>
#include <queue>
#include <unistd.h>

static SDL_Window *window = NULL;
static SDL_Renderer *renderer = NULL;
static SDL_Texture *tex = NULL;
static uint32_t *tex_pixels;
static int tex_pitch;

static const int FRAME_WIDTH = 800;
static const int FRAME_HEIGHT = 525;
static const int SCREEN_WIDTH = 640;
static const int SCREEN_HEIGHT = 480;

static int cx = 0;
static int cy = 0;
static std::queue<uint32_t> pixels_q;

static int frame_idx = 0;

static int missed_pixels = 0;
static int sent_pixels = 0;

bool display_init() {
  if (!SDL_Init(SDL_INIT_VIDEO)) {
    SDL_Log("Couldn't initialize SDL: %s", SDL_GetError());
    return false;
  };

  if (!SDL_CreateWindowAndRenderer("display", 1280, 960, SDL_WINDOW_RESIZABLE,
                                   &window, &renderer)) {
    SDL_Log("Couldn't create window/renderer: %s", SDL_GetError());
    return false;
  }

  SDL_SetRenderLogicalPresentation(renderer, 1280, 960,
                                   SDL_LOGICAL_PRESENTATION_LETTERBOX);

  tex = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_XRGB8888,
                          SDL_TEXTUREACCESS_STREAMING, 640, 480);
  SDL_LockTexture(tex, NULL, (void **)&tex_pixels, &tex_pitch);
  SDL_SetTextureScaleMode(tex, SDL_SCALEMODE_NEAREST);

  return true;
}

bool display_update() {
  SDL_Event e;
  bool quit = false;

  if (cx < SCREEN_WIDTH && cy < SCREEN_HEIGHT) {
    if (!pixels_q.empty()) {
      uint32_t pixel = pixels_q.front();
      pixels_q.pop();
      tex_pixels[tex_pitch / 4 * cy + cx] = pixel;
    } else {
      missed_pixels++;
    }
  }

  cx++;
  if (cx >= FRAME_WIDTH) {
    cx = 0;
    cy++;

    if (cy == SCREEN_HEIGHT) {
      while (SDL_PollEvent(&e) != 0) {
        if (e.type == SDL_EVENT_QUIT) {
          quit = true;
        }
      }

      if (missed_pixels > 0) {
        std::cerr << "FRAME " << frame_idx << " missed " << missed_pixels
                  << " pixels" << std::endl;
      }

      SDL_UnlockTexture(tex);
      SDL_FRect srcRect = {0, 0, 640, 480};
      SDL_FRect destRect = {0, 0, 1280, 960};
      SDL_RenderTexture(renderer, tex, &srcRect, &destRect);

      SDL_RenderPresent(renderer);
      frame_idx++;
      missed_pixels = 0;
      sent_pixels = 0;
      SDL_RenderClear(renderer);

      SDL_LockTexture(tex, NULL, (void **)&tex_pixels, &tex_pitch);
    }

    if (cy >= FRAME_HEIGHT) {
      cy = 0;
    }
  }

  return !quit;
}

static bool was_ready = false;
extern "C" int display_send_pixel(int value) {
  if (was_ready && (value >> 24)) {
    pixels_q.push(value);
    sent_pixels++;
  }
  was_ready = pixels_q.size() < 2;
  return was_ready;
}

extern "C" int display_get_frame_idx() { return frame_idx; }