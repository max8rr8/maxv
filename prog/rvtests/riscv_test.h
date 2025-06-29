#pragma once

#define RVTEST_RV64U                                                           \
  .macro init;                                                                 \
  .endm

#define RVTEST_RV32U                                                           \
  .macro init;                                                                 \
  .endm

#define TESTNUM gp

#define RVTEST_CODE_BEGIN                                                      \
  .text;                                                                       \
  .globl _start;                                                               \
  _start:;

#define RVTEST_PASS                                                            \
  fence;                                                                       \
  li a1, 0x2;                                                                  \
  j finish_test;

#define RVTEST_FAIL                                                            \
  fence;                                                                       \
  li a1, 0x3;                                                                  \
  j finish_test;

#define RVTEST_CODE_END                                                        \
  li a1, 0x3;                                                                  \
finish_test:;                                                                \
  li a0, 0x20000000;                                                           \
  sw a1, 8(a0);                                                                \
  sw gp, 12(a0);                                                                \
  lw ra, 4(a0);                                                                \
  jalr x0, ra;

#define RVTEST_DATA_BEGIN .data
#define RVTEST_DATA_END
