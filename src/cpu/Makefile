$(shell mkdir -p $(B)/cpu)

CPU_SRC := src/cpu/cpu.sv src/cpu/alu.sv src/cpu/shifter.sv src/cpu/regfile.sv src/cpu/divider.sv
CPU_MICROCODE_COMPILER_BLD := $(B)/cpu/microcode_compiler_bld
CPU_MICROCODE_COMPILER := $(CPU_MICROCODE_COMPILER_BLD)/debug/microcode-compiler

$(CPU_MICROCODE_COMPILER): $(wildcard src/cpu/microcode/src/**) src/cpu/microcode/Cargo.toml
	mkdir -p $(CPU_MICROCODE_COMPILER_BLD)
	cd src/cpu/microcode && CARGO_TARGET_DIR=../../../$(CPU_MICROCODE_COMPILER_BLD) cargo build

$(B)/cpu/microcode.sv: src/cpu/microcode/code.toml $(CPU_MICROCODE_COMPILER)
	@rm -f $@
	$(CPU_MICROCODE_COMPILER) src/cpu/microcode/code.toml $@

CPU_SRC += $(B)/cpu/microcode.sv
