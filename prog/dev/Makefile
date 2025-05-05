PSRC := prog/dev/

$(B)/code_$(PROG).out: $(PSRC)/code.S
	clang -O2 -target riscv32 -march=rv32i -nostdlib $(PSRC)/code.S -o $@
