.PHONY: load sim

B ?= build
SRC := src/top.sv src/led.sv src/cpu.sv src/uart.sv
SIM := sim/tb.sv
PROG := prog/code.s
PROG_GEN := prog/gen_rom_code.py

B_CODE_SV := $(B)/code.sv

$(shell mkdir -p $(B))

$(B)/code.out: $(PROG)
	riscv32-elf-as $(PROG) -o $@

$(B_CODE_SV) $(B)/code.hex: $(B)/code.out $(PROG_GEN)
	python3 $(PROG_GEN) $(B)/code.out $(B)/

$(B)/synth.json: $(SRC) $(B_CODE_SV)
	yowasp-yosys -p "read_verilog -sv $(SRC) $(B_CODE_SV); synth_gowin -top top -json $(B)/synth.json"

$(B)/pnr.json: $(B)/synth.json tangnano9k.cst
	nextpnr-himbaechel --json $(B)/synth.json --write $(B)/pnr.json \
		--device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C \
		--vopt cst=tangnano9k.cst

$(B)/bitstream.fs: $(B)/pnr.json
	gowin_pack -d GW1N-9C -o $(B)/bitstream.fs $(B)/pnr.json

load: $(B)/bitstream.fs
	openFPGALoader -b tangnano9k $(B)/bitstream.fs

obj_dir/Vtb: $(SRC) $(SIM) $(B_CODE_SV)
	verilator --exe --binary $(SIM) $(SRC) $(B_CODE_SV) --top-module tb -Wno-pinmissing --trace

trace.vcd: obj_dir/Vtb
	./obj_dir/Vtb

sim: trace.vcd