Video display engine provides functionality to offload creation of display frames from cpu and avoid storing whole 900kB of frame image in memory. This is done by two means:
1. Color palletes, the value of color is now represented as 8-bit index in pallete
2. Splitting frame into repeating sprites (each 8 by 8 pixels).

Each sprite takes 16 bytes (128bits) in memory, and can be in one of two modes:

- 4x4 7-bit Colored block
- 8x8 Monochrome (consists of two colors)

This gives 128 sprites per BRAM block, let's use 4 BRAMs, this gives us 512 sprites.

Thus we need 9bits per sprite selector, in 640 by 480 res we want at least 
82 by 62 grid (5084 blocks). To simplify position calculations let's use 82 by 64,
thus the address of tile is formed as (x << 6 | y).

This can be fit in 3 brams, 28 columns in each, for selecting right memory 

And we need one more block to large async fifo to synchronise pixel clock domain and cpu domain.

TOTAL: 8 bsrams, manu lut's
