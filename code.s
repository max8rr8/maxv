.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
  li a0, 0x1234
	li t0, 60
  sb t0, 0(a0)

  li t1, 0x2000
wait:
  addi t1, t1, -1
  bne t1, x0, wait

	li t0, 51
  sb t0, 0(a0)


  li t1, 0x2000
wait2:
  addi t1, t1, -1
  bne t1, x0, wait2

  j _boot 

# li t0, 0x540
# loop:
#   srli t1, t0, 22
#   sb t1, 0(a0) 
#   addi t0, t0, 1
#   j loop

.data
variable:
	.word 0xdeadbeef
                    