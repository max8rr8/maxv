.PHONY: load sim

SOURCES := top.sv led.sv cpu.sv code.sv

code.out: code.s
	riscv32-elf-as ./code.s -o code.out

code.sv code.hex: code.out
	python3 ./gen_rom_code.py ./code.out

synth.json: $(SOURCES)
	yowasp-yosys -p "read_verilog -sv $(SOURCES); synth_gowin -top top -json synth.json"

out.svg pnr.json: synth.json tangnano9k.cst
	nextpnr-himbaechel --json synth.json --write pnr.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst --routed-svg out.svg

bitstream.fs: pnr.json
	gowin_pack -d GW1N-9C -o bitstream.fs pnr.json

load: bitstream.fs
	openFPGALoader -b tangnano9k bitstream.fs

obj_dir/Vtb: $(SOURCES) tb.sv
	verilator --exe --binary tb.sv $(SOURCES) --top-module tb -Wno-pinmissing --trace

trace.vcd: obj_dir/Vtb
	./obj_dir/Vtb

sim: trace.vcd