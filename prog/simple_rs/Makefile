PSRC := prog/simple_rs/

$(B)/code_$(PROG).out: $(PSRC)/code.rs $(PSRC)/code.S
	rustc $(PSRC)/code.rs --target=riscv32i-unknown-none-elf -Copt-level=2 --emit=obj --crate-type lib -o $(B)/simple_rs.o
	clang -O2 -target riscv32 -march=rv32i -nostdlib $(B)/simple_rs.o $(PSRC)/code.S -o $@
