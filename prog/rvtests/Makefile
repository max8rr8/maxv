.SECONDEXPANSION:

RVTESTS ?= lui auipc jal jalr \
					 beq bne blt bge bltu bgeu \
					 addi slti sltiu xori ori andi \
					 slli srli srai \
					 add sub sll slt sltu xor or and \
					 srl sra

PSRC := prog/rvtests
RVTEST_SRC := $(PSRC)/dep/riscv-tests/
PROG_SRCF := $(PSRC)/code.S $(PSRC)/harness.c 

$(B)/code_$(PROG).out: $(PROG_SRCF) $(PROG_CONF_F)
	clang -Oz -target riscv32 -fno-PIC -march=rv32i -nostdlib -o $@ \
		$(PROG_SRCF) -I$(PSRC) -I$(RVTEST_SRC)/isa/macros/scalar -T $(PSRC)/harness.ld

RVTEST_B := $(B)/rvtests/
$(shell mkdir -p $(RVTEST_B))

RVTEST_B_TESTS :=  $(addprefix $(RVTEST_B),$(RVTESTS))

$(RVTEST_B_TESTS): $(RVTEST_B)%: $(RVTEST_SRC)/isa/rv32ui/%.S $(PSRC)/riscv_test.h $(PSRC)/test.ld
	clang -Oz -target riscv32 -fno-PIC -march=rv32i -nostdlib -o $@ \
		$< -I$(PSRC) -I$(RVTEST_SRC)/isa/macros/scalar -T $(PSRC)/test.ld

run_rvtests_fpga: $(RVTEST_B_TESTS) load
	cd $(PSRC) && python3 ./run_tests.py $(abspath $(RVTEST_B)) "$(RVTESTS)"

$(B)/rvtest_verilated: $(SIM_CORE) $(CPU_SRC) $(PSRC)/verilated/main.cpp $(PSRC)/verilated/dut.sv
	$(VERILATOR) --cc --exe --build $(SIM_CORE) $(CPU_SRC) $(PSRC)/verilated/main.cpp $(PSRC)/verilated/dut.sv --top-module dut
	cp obj_dir/Vdut $(B)/rvtest_verilated

run_rvtests_sim: $(RVTEST_B_TESTS) $(B)/rvtest_verilated
	$(B)/rvtest_verilated $(abspath $(RVTEST_B)) $(RVTESTS)