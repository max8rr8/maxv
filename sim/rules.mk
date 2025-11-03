$(B)/sim_code.sv $(B)/sim_code.hex: $(PROG_GEN) $(CODE_OUT) $(PROG_CONF_F)
	python3 $(PROG_GEN) $(CODE_OUT) $(B)/sim_code.sv --hex $(B)/sim_code.hex

$(SIM_EXE): $(SRC) $(SIM) $(B)/sim_code.sv
	$(VERILATOR) --cc --exe --build $(SRC) \
	 	$(SIM) $(B)/sim_code.sv --top-module dut \
		-LDFLAGS -lSDL3
	cp obj_dir/Vdut $(SIM_EXE)

trace.vcd sim: $(SIM_EXE)
	$(SIM_EXE)