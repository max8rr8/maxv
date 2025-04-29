from elftools.elf.elffile import ELFFile
import sys

def fix_order(t):
   return ''.join([t[6], t[7], t[4], t[5], t[2], t[3], t[0], t[1]])

with open(sys.argv[1], "rb") as f:
    elffile = ELFFile(f)

    for section in elffile.iter_sections():
        if section.name.startswith(".text"):
          code_raw = section.data().hex()
          code_commands = [fix_order(code_raw[i:i+8]) for i in range(0, len(code_raw), 8)] 
            # print()
            # print("  " + section.name)

print(f"Total: {len(code_commands)} instruction")
code_bits = len(code_commands) * 32

CODE = f"""
`default_nettype none

module code (
    input [31:0] addr_i,
    output [31:0] instr_o
);
  // verilator lint_off ASCRANGE
  logic [0:{len(code_commands) - 1}][31:0] INSTR  = {code_bits}'h{''.join(code_commands)};

  assign instr_o = addr_i < {len(code_commands) * 4} ? INSTR[addr_i >> 2] : 32'h00000013;
endmodule
"""

with open("code.sv", "w") as f:
   f.write(CODE)

with open("code.hex", "w") as f:
   f.write("\n".join(code_commands))