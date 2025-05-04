.PHONY: load sim

B ?= build
SRC := src/top.sv src/led.sv src/cpu.sv src/uart.sv
SIM := sim/tb.sv sim/prom.sv
PROG := prog/code.S prog/code.c
PROG_GEN := prog/gen_code.py
# PROG_SIM_GEN := prog/gen_sim_code.py

B_CODE_SV := $(B)/code.sv

$(shell mkdir -p $(B))

$(B)/code.out: $(PROG)
	clang -O2 -target riscv32 -march=rv32i -nostdlib $(PROG) -o $@

$(B)/synth.json: $(SRC) prog/code_base.sv
	yowasp-yosys -p "read_verilog -sv $(SRC) prog/code_base.sv; synth_gowin -top top -json $(B)/synth.json"

$(B)/pnr.json: $(B)/synth.json tangnano9k.cst
	nextpnr-himbaechel --json $(B)/synth.json --write $(B)/pnr.json \
		--device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C \
		--vopt cst=tangnano9k.cst

$(B)/pnr_code.json $(B)/code.hex: $(PROG_GEN) $(B)/code.out $(B)/pnr.json
	python3 $(PROG_GEN) $(B)/code.out $(B)/pnr_code.json --pnr $(B)/pnr.json --hex $(B)/code.hex

$(B)/bitstream.fs: $(B)/pnr_code.json
	gowin_pack -d GW1N-9C -o $(B)/bitstream.fs $(B)/pnr_code.json

load: $(B)/bitstream.fs
	openFPGALoader -b tangnano9k $(B)/bitstream.fs


$(B)/sim_code.sv $(B)/sim_code.hex: $(PROG_GEN) $(B)/code.out
	python3 $(PROG_GEN) $(B)/code.out $(B)/sim_code.sv --hex $(B)/sim_code.hex

obj_dir/Vtb: $(SRC) $(SIM) $(B)/sim_code.sv
	verilator --exe --binary $(SIM) $(SRC) $(B)/sim_code.sv --top-module tb -Wno-pinmissing --trace

trace.vcd: obj_dir/Vtb
	./obj_dir/Vtb

sim: trace.vcd