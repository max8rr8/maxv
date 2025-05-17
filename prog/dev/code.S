# 0 "prog/code.S"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "prog/code.S"
.global _boot
.text

_boot:
  li t0, 0xD
  slli t0, t0, 5
  srli t0, t0, 5

  slli t0, t0, 31
  srai t0, t0, 29

  
.data
variable:
 .word 0xdeadbeef
