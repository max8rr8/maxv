#include <cstdint>
#include <fstream>
#include <vector>

std::vector<uint32_t> code;

extern "C" long long code_get(long long addr) {
  if (code.size() == 0) {
    std::ifstream code_hex(getenv("SIM_CODE_HEX"));
    while (!code_hex.eof()) {
      uint32_t h;
      code_hex >> std::hex >> h;
      printf("%x\n", h);
      code.push_back(h);
    }
    while (code.size() < 1024)
      code.push_back(0);
  }

  return code[(addr >> 2) & 1023];
}