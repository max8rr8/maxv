.PHONY: load sim

PROG ?= dev

B ?= build
B_CONF := $(B)/conf/
CODE_OUT := $(B)/code_$(PROG).out
SRC := src/top.sv src/led.sv src/uart.sv src/bsmem.sv
SRC += src/cpu/cpu.sv src/cpu/alu.sv src/cpu/shifter.sv
SIM := sim/tb.sv sim/prom.sv
PROG_GEN := prog/gen_code.py

PROG_CONF_F := $(B_CONF)/$(PROG).prog.conf

B_CODE_SV := $(B)/code.sv

$(shell mkdir -p $(B))
$(shell mkdir -p $(B_CONF))
$(shell mkdir -p $(B)/prog)

$(PROG_CONF_F):
	rm -f $(B_CONF)/*.prog.conf
	touch $(PROG_CONF_F)

include prog/$(PROG)/Makefile

$(B)/synth.json: $(SRC) prog/code_base.sv
	yowasp-yosys -p "read_verilog -sv $(SRC) prog/code_base.sv; synth_gowin -top top -json $(B)/synth.json"

$(B)/pnr.json: $(B)/synth.json tangnano9k.cst
	nextpnr-himbaechel --json $(B)/synth.json --write $(B)/pnr.json \
		--device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C \
		--vopt cst=tangnano9k.cst

$(B)/pnr_code.json $(B)/code.hex: $(PROG_GEN) $(CODE_OUT) $(PROG_CONF_F) $(B)/pnr.json
	python3 $(PROG_GEN) $(CODE_OUT) $(B)/pnr_code.json --pnr $(B)/pnr.json --hex $(B)/code.hex

$(B)/bitstream.fs: $(B)/pnr_code.json
	gowin_pack -d GW1N-9C -o $(B)/bitstream.fs $(B)/pnr_code.json

load: $(B)/bitstream.fs
	openFPGALoader -b tangnano9k $(B)/bitstream.fs


$(B)/sim_code.sv $(B)/sim_code.hex: $(PROG_GEN) $(CODE_OUT) $(PROG_CONF_F)
	python3 $(PROG_GEN) $(CODE_OUT) $(B)/sim_code.sv --hex $(B)/sim_code.hex

obj_dir/Vtb: $(SRC) $(SIM) $(B)/sim_code.sv
	verilator --exe --binary $(SIM) $(SRC) $(B)/sim_code.sv --top-module tb -Wno-pinmissing --trace

trace.vcd sim: obj_dir/Vtb
	./obj_dir/Vtb
