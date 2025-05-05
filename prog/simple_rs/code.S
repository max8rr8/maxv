# 0 "prog/code.S"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "prog/code.S"
.global _boot
.global main
.text

_boot:
  li a1, 70
  call r_main

.data
variable:
 .word 0xdeadbeef
