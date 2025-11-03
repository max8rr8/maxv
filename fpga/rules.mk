
$(B)/synth.json: $(SRC) $(FPGA_SRC) prog/code_base.sv
	yowasp-yosys -p "read_verilog -sv $(FPGA_SRC) $(SRC) prog/code_base.sv; synth_gowin -top top -json $(B)/synth.json"

$(B)/pnr.json: $(B)/synth.json $(FPGA_CST)
	nextpnr-himbaechel --json $(B)/synth.json --write $(B)/pnr.json \
		--device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C \
		--vopt cst=$(FPGA_CST)

$(B)/pnr_code.json $(B)/code.hex: $(PROG_GEN) $(CODE_OUT) $(PROG_CONF_F) $(B)/pnr.json
	python3 $(PROG_GEN) $(CODE_OUT) $(B)/pnr_code.json --pnr $(B)/pnr.json --hex $(B)/code.hex

$(B)/bitstream.fs: $(B)/pnr_code.json
	gowin_pack -d GW1N-9C -o $(B)/bitstream.fs $(B)/pnr_code.json

load: $(B)/bitstream.fs
	openFPGALoader -b tangnano9k $(B)/bitstream.fs
