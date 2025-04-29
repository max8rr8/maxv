.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
  li a0, 0x1234
	li t0, 42
loop:
  sb t0, 0(a0)   
  addi t0, t0, 1
  

.data
variable:
	.word 0xdeadbeef
                    