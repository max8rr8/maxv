.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
  li a0, 0x1234
	li t0, 0x3c
  sb t0, 0(a0) 

# li t0, 0x540
# loop:
#   srli t1, t0, 22
#   sb t1, 0(a0) 
#   addi t0, t0, 1
#   j loop

.data
variable:
	.word 0xdeadbeef
                    