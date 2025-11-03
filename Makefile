.PHONY: load sim

PROG ?= dev
PROG_CONF ?= 

B ?= build
B_CONF := $(B)/conf/
CODE_OUT := $(B)/code_$(PROG).out

$(shell mkdir -p $(B))
$(shell mkdir -p $(B_CONF))
$(shell mkdir -p $(B)/prog)

ifneq (,$(wildcard prog/$(PROG)/conf.mk))
	include prog/$(PROG)/conf.mk
endif

PROG_CONF_F := $(B_CONF)/$(PROG)__$(PROG_CONF).prog.conf

$(PROG_CONF_F):
	rm -f $(B_CONF)/*.prog.conf
	touch $(PROG_CONF_F)

VERILATOR := verilator --trace -Wno-pinmissing

include src/cpu/Makefile
include sim/Makefile
include fpga/Makefile

SRC := $(CPU_SRC) src/soc.sv src/led.sv src/uart.sv src/bsmem.sv
PROG_GEN := prog/gen_code.py
B_CODE_SV := $(B)/code.sv

include prog/$(PROG)/Makefile

include sim/rules.mk
include fpga/rules.mk
