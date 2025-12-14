PSRC := prog/donut/

DONUT_C := $(PSRC)/code.c $(PSRC)/hal.c $(PSRC)/gui.c 
DONUT_H := $(PSRC)/donut.h $(PSRC)/hal.h $(PSRC)/gui.h

$(B)/code_$(PROG).out: $(PSRC)/donut.c $(DONUT_C) $(DONUT_H) $(PSRC)/linker.ld $(PSRC)/code.S 
	clang -O3 -flto=full -fPIE -target riscv32 -march=rv32im -nostdlib \
		-o $(B)/donut.c.o -c $(PSRC)/donut.c

	clang -fuse-ld=lld -Oz -flto=full -fPIE -target riscv32 -march=rv32im -nostdlib \
		-o $@ -T$(PSRC)/linker.ld \
		$(B)/donut.c.o $(PSRC)/code.S $(DONUT_C)  

$(B)/donut.out: $(PSRC)/donut.c $(PSRC)/linux_model.c 
	clang -O2 $(PSRC)/donut.c $(PSRC)/linux_model.c -o $@

run_donut_linux: $(B)/donut.out
	$(B)/donut.out