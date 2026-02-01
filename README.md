# MaxV - A small RISC-V core and SoC for Tang Nano 9K

## SoC Features

- Written for Tang Nano 9K (GW1NR-9) synthesized with [Yosys](https://github.com/YosysHQ/apicula)
- Can be almost fully simulated with [Verilator](https://www.veripool.org/verilator/)
- RV32IM basic RISC-V core
  - Simple multi-cycle core with microcode
  - `lui`/`auipc`/`add`/`addi`/Logic/Branch/Jump instructions done in 3 cycles
  - Multiplication/Shifting/Memory done in 4 cycles
  - Division in 36 cycles
  - Passes [riscv-tests](https://github.com/riscv-software-src/riscv-tests/tree/master/isa) for `rv32ui` and `rv32um` sets
- Basic periphery
  - 4 kilobytes of ROM
  - 8 kilobytes of RAM
  - timer
  - uart
  - button controller
  - watchdog
  - error handler: will reset SoC and record it if any module reports error
- Old-game-console-like Video Engine
  - Outputs video to HDMI in 640x480 resolution
  - Splits screen into 80 by 60 map of tiles
  - In each tile there can be one of 512 sprites
  - Supports monochrome high-definition sprites (useful for text)
  - Supports multicolor smaller-resolution sprites
  - Contains palette for fast color switching

## How to run

- Run donut program on FPGA: `make PROG=dount load`
  - After loading use short button presses to navigate menu
  - Long button press selects entry in menu or exits from one
- Run donut program in SW simulation: `make PROG=donut sim`
  - Left and right arrows can be used to emulate Tang Nano buttons
- Run riscv-tests in SW simulation: `make PROG=rvtests run_rvtests_sim`
- Run riscv-tests on FPGA: `make PROG=rvtests run_rvtests_fpga`
