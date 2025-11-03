
bool display_init();
bool display_update();

extern "C" int display_send_pixel(int value);
extern "C" int display_get_frame_idx();