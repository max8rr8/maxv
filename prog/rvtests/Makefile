.SECONDEXPANSION:

RVTESTS ?= rv32ui/lui rv32ui/auipc rv32ui/jal rv32ui/jalr \
					 rv32ui/beq rv32ui/bne rv32ui/blt rv32ui/bge rv32ui/bltu rv32ui/bgeu \
					 rv32ui/addi rv32ui/slti rv32ui/sltiu rv32ui/xori rv32ui/ori rv32ui/andi \
					 rv32ui/slli rv32ui/srli rv32ui/srai \
					 rv32ui/add rv32ui/sub rv32ui/sll rv32ui/slt rv32ui/sltu rv32ui/xor rv32ui/or rv32ui/and \
					 rv32ui/srl rv32ui/sra \
					 rv32um/mul rv32um/mulh rv32um/mulhsu rv32um/mulhu \
					 rv32um/remu rv32um/divu rv32um/rem rv32um/div

PSRC := prog/rvtests
RVTEST_SRC := $(PSRC)/dep/riscv-tests/
PROG_SRCF := $(PSRC)/code.S $(PSRC)/harness.c 

$(B)/code_$(PROG).out: $(PROG_SRCF) $(PROG_CONF_F)
	clang -Oz -target riscv32 -fno-PIC -march=rv32i -nostdlib -o $@ \
		$(PROG_SRCF) -I$(PSRC) -I$(RVTEST_SRC)/isa/macros/scalar -T $(PSRC)/harness.ld

RVTEST_B := $(B)/rvtests/
$(shell mkdir -p $(RVTEST_B)/rv32ui $(RVTEST_B)/rv32um)

RVTEST_B_TESTS :=  $(addprefix $(RVTEST_B),$(RVTESTS))

$(RVTEST_B_TESTS): $(RVTEST_B)%: $(RVTEST_SRC)/isa/%.S $(PSRC)/riscv_test.h $(PSRC)/test.ld
	clang -Oz -target riscv32 -fno-PIC -march=rv32im -nostdlib -o $@ \
		$< -I$(PSRC) -I$(RVTEST_SRC)/isa/macros/scalar -T $(PSRC)/test.ld

run_rvtests_fpga: $(RVTEST_B_TESTS) load
	cd $(PSRC) && python3 ./run_tests.py $(abspath $(RVTEST_B)) "$(RVTESTS)"

$(B)/rvtest_verilated: $(SIM_CORE) $(CPU_SRC) $(PSRC)/verilated/main.cpp $(PSRC)/verilated/dut.sv
	$(VERILATOR) --cc --exe --build $(SIM_CORE) $(CPU_SRC) $(PSRC)/verilated/main.cpp $(PSRC)/verilated/dut.sv --top-module dut
	cp obj_dir/Vdut $(B)/rvtest_verilated

run_rvtests_sim: $(RVTEST_B_TESTS) $(B)/rvtest_verilated
	$(B)/rvtest_verilated $(abspath $(RVTEST_B)) $(RVTESTS)