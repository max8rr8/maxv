$(B)/sim_code.sv $(B)/sim_code.hex: $(PROG_GEN) $(CODE_OUT) $(PROG_CONF_F)
	python3 $(PROG_GEN) $(CODE_OUT) $(B)/sim_code.sv --hex $(B)/sim_code.hex

VERILATOR_SRC := $(SIM)
ifeq ($(USE_PROM_CODE),1)
VERILATOR_SRC += $(B)/sim_code.sv
else
VERILATOR_SRC += sim/sim_code_fast.sv
endif

$(SIM_EXE): $(SRC) $(SIM) $(VERILATOR_SRC)
	$(VERILATOR) --cc --exe --build $(SRC) \
	 	$(VERILATOR_SRC) --top-module dut \
		-LDFLAGS -lSDL3
	cp obj_dir/Vdut $(SIM_EXE)

trace.vcd sim: $(SIM_EXE) $(B)/sim_code.hex
	SIM_CODE_HEX=$(B)/sim_code.hex $(SIM_EXE)