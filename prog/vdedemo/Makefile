PSRC := prog/vdedemo/

$(B)/code_$(PROG).out: $(PSRC)/code.c $(PSRC)/code.S
	clang -O0 -fPIE -target riscv32 -march=rv32im -nostdlib $(PSRC)/code.S $(PSRC)/code.c -o $@
