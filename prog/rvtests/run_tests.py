import serial
import time
import os
import sys
import elftools.elf.elffile

SANITY_CODE = [
    0x20000537,  # lui     a0,0x20000
    0x000015B7,  # lui     a1,0x1
    0x23458593,  # addi    a1,a1,564 # 1234 <_boot-0xfec0>
    0x00B52423,  # sw      a1,8(a0) # 20000008 <variable+0x1ffedefc>
    0x00452083,  # lw      ra,4(a0)
    0x00008067,  # jalr    ra
]

ser = serial.Serial("/dev/ttyUSB1")
print("Opened ", ser.name)

def wait_start():
    print("Waiting S for start")
    while True:
        c = ser.read()
        if int(c[0]) == ord("S"):
            break
        print("Recieved not start", c)

wait_start()

def send_cmd(cmd: str):
    c = ser.read()
    assert int(c[0]) == ord(">"), f"Invalid state before sendind cmd {c}"
    ser.write(cmd.encode("ascii"))
    time.sleep(0.002)


def send_hex(addr: int):
    v = hex(addr)[2:].zfill(8)
    for c in v:
        ser.write(c.encode("ascii"))
        time.sleep(0.0001)


def read_hex():
    p = ""
    for i in range(8):
        ch = ser.read()
        p += ch.decode("ascii")[0]
    return int("0x" + p, 16)


def read_memory(addr: int):
    send_cmd("A")
    send_hex(addr)
    send_cmd("R")
    return read_hex()


def write_memory(addr: int, val: int):
    send_cmd("A")
    send_hex(addr)
    send_cmd("W")
    send_hex(val)


def write_arr(addr: int, vals: list[int]):
    send_cmd("A")
    send_hex(addr)
    # print(len(vals))
    for v in vals:
        send_cmd("W")
        send_hex(v)
        send_cmd("N")

def jump_addr(addr: int):
    send_cmd("A")
    send_hex(addr)
    send_cmd("J")

def sanity_check():
    write_memory(0x20000008, 0xffff)
    write_arr(0x20000400, SANITY_CODE)
    assert read_memory(0x20000408) == SANITY_CODE[2]
    jump_addr(0x20000400)
    assert read_memory(0x20000008) == 0x1234

def load_elf(path: str):
    with open(path, "rb") as f:
        elf = elftools.elf.elffile.ELFFile(f)
        for section in elf.iter_sections():
            if section.name.startswith(".text"):
                d = section.data()
                code_raw = []
                for i in range(0, len(d), 4):
                    code_raw.append(int.from_bytes(d[i:i+4], "little"))
                write_arr(0x20000400, code_raw)
                
                

print("Sanity 1.... ", end="")
sanity_check()
print("OK")

print("Sanity 2.... ", end="")
sanity_check()
print("OK")

# print(sys.argv)
TEST_PATH = sys.argv[1]
TESTS = sys.argv[2].split(" ")
# print(TESTS, TEST_PATH)
errors = 0

for i, t in enumerate(TESTS):
    # if i % 5 == 4:
    #     wait_start()

    print(f"Running {t}... ", end="", flush=True)
    load_elf(TEST_PATH + "/" + t)
    print("Loaded... ", end="", flush=True)
    jump_addr(0x20000400)
    print("Jumped... ", end="", flush=True)
    time.sleep(1)
    res = read_memory(0x20000008)
    test = read_memory(0x2000000c)
    if res == 2:
        print("OK")
    else:
        print(f"FAIL: {res} {test}")
        errors += 1
    # test = 
    # assert read_memory(0x20000008) == 0x1234
    # print("Checked... ", end="
    # print("OK")

print("Total errors: ", errors)