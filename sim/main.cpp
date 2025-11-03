#include <cstdint>
#include <cstdlib>
#include <vector>

#include "Vdut.h"
#include "display.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

class VerilatedContext;
class VerilatedVcdC;
class Vcpu;

uint64_t main_time = 0;
VerilatedContext *contextp;
VerilatedVcdC *tfp;
Vdut *dut;

std::string tests_path;
std::vector<std::string> test_names;

std::vector<uint8_t> program_memory;
int test_failn = 0;
bool test_passed = false;
bool test_stop = 0;

const int dump_frames = 3;

void do_step() {
  dut->clk_i = 1;
  dut->eval();

  if (display_get_frame_idx() < dump_frames)
    tfp->dump(main_time++);

  dut->clk_i = 0;
  dut->eval();

  if (display_get_frame_idx() < dump_frames)
    tfp->dump(main_time++);
}

void do_reset() {
  dut->rstn_i = 0;
  for (int i = 0; i < 4; i++) {
    do_step();
  }
  dut->rstn_i = 1;
}

int main(int argc, char **argv) {
  int fail_count = 0;

  contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  Verilated::traceEverOn(true);

  tfp = new VerilatedVcdC;

  dut = new Vdut{contextp};
  dut->clk_i = 0;
  dut->rstn_i = 0;
  dut->trace(tfp, 99);

  tfp->open("trace.vcd");
  dut->eval();

  tfp->dump(main_time++);
  
  do_reset();
  while (true) {
    if (!display_update()) {
      break;
    }

    do_step();
  }

  tfp->close();
  delete tfp;
  delete dut;
  delete contextp;
  return 0;
}