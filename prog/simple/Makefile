PSRC := prog/simple/

$(B)/code_$(PROG).out: $(PSRC)/code.c $(PSRC)/code.S
	clang -O2 -target riscv32 -march=rv32i -nostdlib $(PSRC)/code.c $(PSRC)/code.S -o $@
