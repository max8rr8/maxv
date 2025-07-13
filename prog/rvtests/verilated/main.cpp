#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>

#include "Vdut.h"
#include "Vdut__Dpi.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

const std::string RED_CODE = "\e[31m";
const std::string GREEN_CODE = "\e[32m";
const std::string RESET_CODE = "\e[0m";


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

int access_memory(int address, int wvalue, int wstrb) {
  if (address < program_memory.size()) {
    uint64_t v0 = program_memory[address + 0];
    uint64_t v1 = program_memory[address + 1];
    uint64_t v2 = program_memory[address + 2];
    uint64_t v3 = program_memory[address + 3];
    return (v3 << 24) | (v2 << 16) | (v1 << 8) | v0;
  }

  if (address == 0x20000008) {
    test_passed = wvalue == 0x2;
    return wvalue;
  }

  if (address == 0x2000000c) {
    test_failn = wvalue;
    return wvalue;
  }

  if (address == 0x20000004) {
    test_stop = true;
    return 0xdeadbeef;
  }

  std::cout << "Unhandled memory access at address: " << std::hex << address
            << std::endl;

  test_passed = false;
  test_stop = true;
  test_failn = -1;
  return 0xdeadbeef;
}

void do_step() {
  dut->clk_i = 1;
  dut->eval();
  tfp->dump(main_time++);

  dut->clk_i = 0;
  dut->eval();
  tfp->dump(main_time++);
}

void do_reset() {
  dut->rstn_i = 0;
  for (int i = 0; i < 4; i++) {
    do_step();
  }
  dut->rstn_i = 1;
}

void load_test(std::string name) {
  std::string path = tests_path + "/" + name;
  std::ifstream input(path, std::ios::in | std::ios::binary);
  program_memory.reserve(8);

  input.seekg(0, std::ios::end);
  std::streampos fileSize = input.tellg();
  input.seekg(0, std::ios::beg);

  program_memory.resize(fileSize);
  input.read((char *)program_memory.data(), fileSize);
}

int main(int argc, char **argv) {
  int fail_count = 0;

  tests_path = argv[1];

  for (int i = 2; i < argc; i++) {
    test_names.push_back(argv[i]);
  }

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

  for (auto test_name : test_names) {
    load_test(test_name);
    do_reset();

    test_failn = -2;
    test_passed = false;
    test_stop = false;
    for (int i = 0; i < 64 * 1024; i++) {
      do_step();

      if (test_stop)
        break;
    }

    if (test_passed) {
      std::cout << std::setw(18) << test_name << GREEN_CODE << " PASS" << RESET_CODE << std::endl;
    } else {
      std::cout << std::setw(18) << test_name << RED_CODE << " FAIL " << test_failn << RESET_CODE << std::endl;
      fail_count++;
    }
  }

  if(fail_count > 0) {
    std::cout << RED_CODE << "Found " << fail_count << " failed tests" << RESET_CODE << std::endl;
  } else {
    std::cout << GREEN_CODE << "All tests passed" << RESET_CODE << std::endl;
  }

  tfp->close();
  delete tfp;
  delete dut;
  delete contextp;
  return 0;
}