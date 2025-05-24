# 0 "prog/code.S"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "prog/code.S"
.global _boot
.text

_boot:
  
test_2:
  li a1, 0x40000000
  li a0, 65

  sb a0, 0(a1)

halt:
  j halt

.data
variable:
 .word 0xdeadbeef
