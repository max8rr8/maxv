# 0 "prog/code.S"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "prog/code.S"
.global _boot
.text

_boot:
  li a0, 0x1234
 li t0, 72
  sb t0, 0(a0)

  li t1, 0x2000
wait:
  addi t1, t1, -1
  bne t1, x0, wait

 li t0, 105
  sb t0, 0(a0)


  li t1, 0x2000
wait2:
  addi t1, t1, -1
  bne t1, x0, wait2

  j _boot

# li t0, 0x540
# loop:
# srli t1, t0, 22
# sb t1, 0(a0)
# addi t0, t0, 1
# j loop

.data
variable:
 .word 0xdeadbeef
