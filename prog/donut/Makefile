PSRC := prog/donut/

DONUT_C := $(PSRC)/code.c $(PSRC)/donut.c $(PSRC)/hal.c $(PSRC)/gui.c 
DONUT_H := $(PSRC)/donut.h $(PSRC)/hal.h $(PSRC)/gui.h

$(B)/code_$(PROG).out: $(DONUT_C) $(DONUT_H) $(PSRC)/linker.ld $(PSRC)/code.S 
	clang -Oz -flto=full -fPIE -target riscv32 -march=rv32im -nostdlib \
		-o $@ -T$(PSRC)/linker.ld \
		$(PSRC)/code.S $(DONUT_C)  

$(B)/donut.out: $(PSRC)/donut.c $(PSRC)/linux_model.c 
	clang -O2 $(PSRC)/donut.c $(PSRC)/linux_model.c -o $@

run_donut_linux: $(B)/donut.out
	$(B)/donut.out