# 0 "prog/code.S"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "prog/code.S"
.global _boot
.text

_boot:
  li gp, 0x20000008
  
  li t0, 0x48
  sb t0, 0(gp)

  li t0, 0x2069
  sh t0, 1(gp)
  
  li t0, 0x0a0d333c
  sw t0, 3(gp)

  li t0, 0x00
  sb t0, 7(gp)
  

loop:
  lb a0, 0(gp)
  addi gp, gp, 1
  bne a0, x0, cont
  j stuck

cont:
  call print_char
  j loop

stuck:
  j stuck


# ======================
print_char:
  li t0, 0x1234
  sb a0, 0(t0)

  li t1, 0x2000
print_char_wait:
  addi t1, t1, -1
  bne t1, x0, print_char_wait
  ret

.data
variable:
 .word 0xdeadbeef
