# 0 "prog/code.S"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "prog/code.S"
.global _boot
.global root_main
.text

_boot:
  li t0, 0x40000000
  li t1, 'S'
  sb t1, 0(t0)
  
root:
  auipc ra, 0x0
  li sp, 0x20000200
  li gp, 0x0
  li tp, 0x0
  li t0, 0x20000000
  li t1, 0x0
  li t2, 0x0
  li s0, 0x0
  li s1, 0x0
  li a0, 0x0
  li a1, 0x0
  li a2, 0x0
  li a3, 0x0
  li a4, 0x0
  li a5, 0x0
  li a6, 0x0
  li a7, 0x0
  li s2, 0x0
  li s3, 0x0
  li s4, 0x0
  li s5, 0x0
  li s6, 0x0
  li s7, 0x0
  li s8, 0x0
  li s9, 0x0
  li s10, 0x0
  li s11, 0x0
  li t3, 0x0
  li t4, 0x0
  li t5, 0x0
  li t6, 0x0
  
  sw ra, 4(t0)
  jal x0, root_main

.data
variable:
 .word 0xdeadbeef
