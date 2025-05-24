# RV32I

Status:

- TODO: Planned, not implemented
- IMPL: Implemented
- FAIL: Implemented test failed
- DONE: Implemented and tested

| Instruction | Description                         | Status |
| ----------- | ----------------------------------- | ------ |
| LUI         | Load Upper Immediate                | DONE   |
| AUIPC       | Add Upper Immediate to PC           | DONE   |
| JAL         | Jump and Link                       | DONE   |
| JALR        | Jump and Link Register              | DONE   |
| BEQ         | Branch if Equal                     | DONE   |
| BNE         | Branch if Not Equal                 | DONE   |
| BLT         | Branch if Less Than                 | DONE   |
| BGE         | Branch if Greater or Equal          | DONE   |
| BLTU        | Branch if Less Than Unsigned        | DONE   |
| BGEU        | Branch if Greater or Equal Unsigned | DONE   |
| LB          | Load Byte                           | IMPL   |
| LH          | Load Halfword                       | IMPL   |
| LW          | Load Word                           | IMPL   |
| LBU         | Load Byte Unsigned                  | IMPL   |
| LHU         | Load Halfword Unsigned              | IMPL   |
| SB          | Store Byte                          | IMPL   |
| SH          | Store Halfword                      | IMPL   |
| SW          | Store Word                          | IMPL   |
| ADDI        | Add Immediate                       | DONE   |
| SLTI        | Set Less Than Immediate             | DONE   |
| SLTIU       | Set Less Than Immediate Unsigned    | DONE   |
| XORI        | XOR Immediate                       | DONE   |
| ORI         | OR Immediate                        | DONE   |
| ANDI        | AND Immediate                       | DONE   |
| SLLI        | Shift Left Logical Immediate        | DONE   |
| SRLI        | Shift Right Logical Immediate       | DONE   |
| SRAI        | Shift Right Arithmetic Immediate    | DONE   |
| ADD         | Add                                 | DONE   |
| SUB         | Subtract                            | DONE   |
| SLL         | Shift Left Logical                  | DONE   |
| SLT         | Set Less Than                       | DONE   |
| SLTU        | Set Less Than Unsigned              | DONE   |
| XOR         | XOR                                 | DONE   |
| SRL         | Shift Right Logical                 | DONE   |
| SRA         | Shift Right Arithmetic              | DONE   |
| OR          | OR                                  | DONE   |
| AND         | AND                                 | DONE   |
| FENCE       | Fence                               | TODO   |
| EBREAK      | Environment Break                   | TODO   |
| ECALL       | Environment Call                    | TODO   |
