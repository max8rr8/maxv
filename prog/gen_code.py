from elftools.elf.elffile import ELFFile
import sys
import argparse

parser = argparse.ArgumentParser(prog="Code generator")
parser.add_argument("source")
parser.add_argument("dest")

parser.add_argument("--pnr")
parser.add_argument("--hex")

args = parser.parse_args()

print(args)


def fix_order(t):
    return "".join([t[6], t[7], t[4], t[5], t[2], t[3], t[0], t[1]])


with open(args.source, "rb") as f:
    elffile = ELFFile(f)

    for section in elffile.iter_sections():
        if section.name.startswith(".text"):
            code_raw = section.data().hex()
            code_commands = [
                fix_order(code_raw[i : i + 8]) for i in range(0, len(code_raw), 8)
            ]

print(f"Total: {len(code_commands)} instruction")
code_bits = len(code_commands) * 32

if args.hex:
    with open(args.hex, "w") as f:
        f.write("\n".join(code_commands))

if len(code_commands) > 1024:
    raise Exception("Too many")

while len(code_commands) < 1024:
    code_commands.append("00000013")


def construct_bitstring(parts):
    val = int("".join(parts), 16)
    return f'{bin(val)[2:].zfill(256)}'


fills = {}
for i in range(0, 1024, 16):
    parts_lo = []
    parts_hi = []
    for k in range(16):
        parts_lo.append(code_commands[i - k + 15][:4])
        parts_hi.append(code_commands[i - k + 15][4:])

    name = f"INIT_RAM_{hex(i//16).zfill(2).upper()[2:].zfill(2)}"
    fills[name] = (
        construct_bitstring(parts_hi),
        construct_bitstring(parts_lo),
    )


if args.pnr:
    with open(args.pnr) as f:
        pnr_raw = f.readlines()

    pnr_full = []
    is_hi = False
    for l in pnr_raw:
        if "prom_inst_hi" in l:
            is_hi = True
        if "prom_inst_lo" in l:
            is_hi = False

        for k, v in fills.items():
            if k in l:
                pnr_full.append(f'"{k}": "{v[1] if is_hi else v[0]}",\n')
                break
        else:
            pnr_full.append(l)

    with open(args.dest, "w") as f:
        f.writelines(pnr_full)

else:
    lo_wr = ''.join([f".{k}(256'b{v[0]}),\n" for k, v in fills.items()])
    hi_wr = ''.join([f".{k}(256'b{v[1]}),\n" for k, v in fills.items()])

    templ = f"""
`default_nettype none

module code (
    input clk_i,
    input [31:0] addr_i,
    output [31:0] instr_o
);
  /* verilator lint_off WIDTHEXPAND */
  pROM #(
    .BIT_WIDTH(16),
    {lo_wr}
    .READ_MODE(0),
    .RESET_MODE("SYNC")
  ) prom_inst_lo (
      .AD({{1'b0, addr_i[10:0], 2'b0}}),
      .CE(1'b1),
      .CLK(clk_i),
      .DO(instr_o[15:0]),
      .OCE(1'b1),
      .RESET(1'b0)
  );

  pROM #(
    .BIT_WIDTH(16),
    {hi_wr}
    .READ_MODE(0),
    .RESET_MODE("SYNC")
  ) prom_inst_hi (
      .AD({{1'b0, addr_i[10:0], 2'b0}}),
      .CE(1'b1),
      .CLK(clk_i),
      .DO(instr_o[31:16]),
      .OCE(1'b1),
      .RESET(1'b0)
  );
endmodule
"""
    with open(args.dest, "w") as f:
        f.write(templ)
