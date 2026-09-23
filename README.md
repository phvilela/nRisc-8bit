# nRisc — 8-bit Educational Processor (Verilog)

A compact 8-bit processor (nRisc) implemented in Verilog for the **Computer
Architecture and Organization I (AOC1)** lab at CEFET-MG. The processor is a
single-instruction-per-cycle machine: state elements update on clock edges,
while instruction fetch, operand read, ALU and memory read are combinational.

Documentation in this README was extracted from the course/reference PDFs
(`intrucoes.pdf` — instruction set and Fibonacci example; `SinaisDeControle.pdf`
— control signal table) and from the bit-level specification in
`instrucoes.nrisc`.

## Architecture

| Element | Size | Notes |
|---|---|---|
| Data width | 8 bits | two's complement |
| General registers `$t0`–`t3` | 4 × 8 bits | selected by 2-bit codes `00`–`11` |
| Internal flag `$c1` | 1 bit | comparison result, used by `jc` |
| Instruction memory | 256 × 8 bits | combinational read, addressed by PC |
| Data memory | 256 × 8 bits | combinational read, write on clock negedge |
| Program counter | 8 bits | increments on clock posedge |

Register codes: `$t0 = 00`, `$t1 = 01`, `$t2 = 10`, `$t3 = 11`.

### Clocking discipline

| Event | When | What happens |
|---|---|---|
| Posedge | `clock ↑` | `PC ← proxPC` |
| Negedge | `clock ↓` | register-file write, data-memory write, `$c1` update |
| Combinational | always | instruction fetch, register read, data-memory read, ALU |

This discipline guarantees that every instruction fetches, computes and
commits its result within one clock cycle (write at the negedge, PC advance at
the next posedge).

### Datapath overview

```
        ┌──────────┐   instrucao   ┌──────────────┐
 PC ───▶│  meminst │─────────────▶│ UniControle  │──▶ control signals
        └──────────┘              └──────────────┘
             ▲                          │
             │                          ▼
        ┌──────┐   dado1/dado2    ┌───────────┐   saida_ula
 proxPC │  PC  │◀──────────┐      │  mux inA  │──────────────┐
        └──────┘            │      │  mux inB  │              ▼
             ▲              ▼      └────▶ ULA ─┘        ┌──────────┐
             │        ┌──────────┐   (out, zero)        │ writeback│──▶ BancoReg
             └─(c1&&desvio)       │ BancoReg  │◀─────────│   mux    │      ▲
                ? PC+1+imm       │  (4×8)    │  memOut  └──────────┘      │
                : PC+1           └──────────┘       ▲                     │
                                  ▲   ▲             └── saida_mem         │
                        endereco/dado│ │            ┌──────────┐         │
                                   ┌─┴─┴───────────▶ │ DadosMem │─────────┘
                                   └───────────────▶│ (256×8)  │
                                                     └──────────┘
```

## Instruction Set

Source: `intrucoes.pdf` (assembly and binary listings) and `instrucoes.nrisc`
(bit-level description). Bits are written MSB first, e.g. `101 rr fff` means
opcode `[7:5]`, register `[4:3]` and funct `[2:0]`.

### Formats

| Format | Layout | Used by |
|---|---|---|
| ALU | `ooo r1 r2 fff` — opcode `[7:5]`, reg1 `[4:3]`, reg2 `[2:1]`, funct `[2:0]` | soma, sub, menor, igual |
| Memory | `011 rdata raddr l` — data reg `[4:3]`, address reg `[2:1]`, bit 0 = load(1)/store(0) | lw, sw |
| Set | `11 rd iiii` — bits `[7:6] = 11`, destination `[5:4]`, 4-bit immediate `[3:0]` | set |
| Branch | `010 ooooo` — signed 5-bit offset `[4:0]` (two's complement) | jc |
| Other | opcode `[7:5]` + funct `[2:0]`, operand reg `[4:3]` | atr, cmp0, sub1, setc1 |

### Instructions

| Mnemonic | Encoding (example) | Operation |
|---|---|---|
| `soma $r1,$r2` | `000 r1 r2 xx0` (e.g. `0x0C`: `000 01 10 0`) | `$t0 ← $r1 + $r2` |
| `sub $r1,$r2` | `000 r1 r2 xx1` | `$t0 ← $r1 − $r2` |
| `menor $r1,$r2` | `001 r1 r2 xx0` | `$c1 ← ($r1 ≤ $r2)` (sign or zero of `$r1−$r2`) |
| `igual $r1,$r2` | `001 r1 r2 xx1` | `$c1 ← ($r1 == $r2)` |
| `jc offset` | `010 ooooo` | if `$c1`: `PC ← PC + 1 + sext(offset)` |
| `sw $rd,$ra` | `011 rd ra xx0` (e.g. `0x6E`: `011 01 11 0`) | `mem[$ra] ← $rd` |
| `lw $rd,$ra` | `011 rd ra xx1` (e.g. `0x7F`: `011 11 11 1`) | `$rd ← mem[$ra]` |
| `atr $rd,$rs` | `100 rd rs xx0` (e.g. `0x8C`: `100 01 10 0`) | `$rd ← $rs` |
| `cmp0 $r` | `101 r xx 000` (e.g. `0xB8`: `101 11 000`) | `$c1 ← ($r == 0)` |
| `sub1 $r` | `101 r xx 001` (e.g. `0xB9`: `101 11 001`) | `$r ← $r − 1` |
| `setc1` | `101 xx xx 010` (e.g. `0xA2`: `101 xx 010`) | `$c1 ← 1` (makes the next `jc` unconditional) |
| `set $rd,imm` | `11 rd iiii` (e.g. `0xF0`: `11 11 0000`) | `$rd ← imm` (4-bit immediate) |

## Control Signals

Source: `SinaisDeControle.pdf`, updated for the 2-bit `RegDst` implementation.

| Signal | Effect |
|---|---|
| `memWrite` / `memRead` | enable data-memory write (negedge) / read |
| `memOut` | writeback mux: `0` = ALU output, `1` = data-memory output |
| `Opc1` | source of `$c1`: `00` = `zero` (equal), `01` = `zero` or sign (less-or-equal), `10` = constant 1 |
| `WriteC1` | enable `$c1` write (negedge) |
| `inA` | ALU input A mux: `0` = register, `1` = immediate |
| `inB` | ALU input B mux: `00` = register, `01` = 0, `10` = 1 |
| `atribui` | routes reg2 (`[2:1]`) into ALU input A (assign instruction) |
| `ULAop` | `00` = subtract, `01` = add |
| `desvio` | enables `PC + 1 + sext(imm5)` when `$c1` is set |
| `RegDst` | write destination mux: `00` = reg field `[2:1]`, `01` = reg field `[4:3]`, `10` = `$t0`, `11` = reg field `[5:4]` (set) |
| `regWrite` | enable register-file write (negedge) |

### Control table per instruction

| Op | memWrite | memRead | memOut | Opc1 | WriteC1 | inA | inB | atribui | ULAop | desvio | RegDst | regWrite |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| SOMA | 0 | 0 | 0 | 00 | 0 | 0 | 00 | 0 | 01 (+) | 0 | 10 | 1 |
| SUB | 0 | 0 | 0 | 00 | 0 | 0 | 00 | 0 | 00 (−) | 0 | 10 | 1 |
| MENOR | 0 | 0 | 0 | 01 | 1 | 0 | 00 | 0 | 00 (−) | 0 | 00 | 0 |
| IGUAL | 0 | 0 | 0 | 00 | 1 | 0 | 00 | 0 | 00 (−) | 0 | 00 | 0 |
| JC (DESVIO) | 0 | 0 | 0 | 00 | 0 | 0 | 00 | 0 | 00 | 1 | 00 | 0 |
| SW (STORE) | 1 | 0 | 0 | 00 | 0 | 0 | 00 | 0 | 00 | 0 | 00 | 0 |
| LW (LOAD) | 0 | 1 | 1 | 00 | 0 | 0 | 00 | 0 | 00 | 0 | 01 | 1 |
| ATR (ATRIBUI) | 0 | 0 | 0 | 00 | 0 | 0 | 01 | 1 | 01 (+) | 0 | 01 | 1 |
| CMP0 | 0 | 0 | 0 | 00 | 1 | 0 | 01 | 0 | 00 (−) | 0 | 00 | 0 |
| SUB1 | 0 | 0 | 0 | 00 | 0 | 0 | 10 | 0 | 00 (−) | 0 | 01 | 1 |
| SET $C1 | 0 | 0 | 0 | 10 | 1 | 0 | 00 | 0 | 00 | 0 | 00 | 0 |
| SET (DEFINE) | 0 | 0 | 0 | 00 | 0 | 1 | 01 | 0 | 01 (+) | 0 | 11 | 1 |

## Project Structure

```
src/
  Processador.v      # top level: datapath wiring and muxes
  UniControle.v      # control unit (decodes opcode/funct)
  BancoReg.v         # register file: 4 × 8 bits, combinational read, negedge write
  ULA.v              # ALU: add/subtract + zero flag
  MemInstrucoes.v    # instruction memory: 256 × 8 bits, combinational
  MemDados.v         # data memory: 256 × 8 bits, combinational read, negedge write
  PC.v               # program counter (posedge)
  CompReg.v          # $c1 comparison flag register (negedge)
test/
  fib-test.v         # Fibonacci program + processor testbench
  ULA-test.v         # ALU unit test
  UniControle.v      # control unit signal dump
  Wave_RegMem.v      # register file test (generates ondas.vcd)
instrucoes.nrisc     # bit-level ISA specification (course material)
run.sh               # compiles and runs the Fibonacci simulation (./run.sh [n])
```

## How to Run

Requirements: [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`, `vvp`).

```bash
./run.sh                  # Fibonacci with n = 10 (default)
./run.sh 13               # Fibonacci with n = 13
# or manually — n is a runtime plusarg, no recompilation needed:
iverilog src/*.v test/fib-test.v && vvp a.out +N=12
```

### Choosing `n` from the command line

The Fibonacci testbench accepts the sequence index as a **plusarg**:

```bash
vvp a.out +N=<n>
```

- `n` defaults to `10` when omitted (`$value$plusargs`).
- Valid range: `0 ≤ n ≤ 13`. The testbench loads `n` into data-memory
  address `0x00`, scales the simulation time with `n` (`8n + 8` clock
  cycles) and prints a summary line: `fib(n) = <result> (mem[1])`.
- Values above `13` are rejected with an explicit error: `fib(14) = 377`
  does not fit in the nRisc's 8-bit datapath (`fib(13) = 233` is the
  largest representable value).

Unit tests:

```bash
iverilog src/*.v test/ULA-test.v     && vvp a.out   # ALU
iverilog src/*.v test/UniControle.v && vvp a.out   # control unit table
iverilog src/*.v test/Wave_RegMem.v && vvp a.out   # register file (ondas.vcd)
```

## Example Program: Fibonacci

`test/fib-test.v` loads the program below. It reads `n` from data-memory
address `0x00` (configurable on the command line — see [How to Run](#how-to-run))
and stores `fib(n)` at address `0x01` (the first data word is the sequence
index, the second receives the computed value).

| Addr | Word | Instruction | Comment |
|---|---|---|---|
| 0x00 | `0xF0` | `set $t3, 0` | `$t3 = 0` |
| 0x01 | `0x7F` | `lw $t3, $t3` | `$t3 = mem[0] = n` |
| 0x02 | `0xD0` | `set $t1, 0` | `$t1 = 0` (fib(0)) |
| 0x03 | `0xE1` | `set $t2, 1` | `$t2 = 1` (fib(1)) |
| 0x04 | `0xB8` | `cmp0 $t3` | loop: `$c1 = ($t3 == 0)` |
| 0x05 | `0x46` | `jc +6` | if `$c1` jump to `fim` |
| 0x06 | `0x0C` | `soma $t1, $t2` | `$t0 = $t1 + $t2` |
| 0x07 | `0x8C` | `atr $t1, $t2` | `$t1 = $t2` |
| 0x08 | `0x90` | `atr $t2, $t0` | `$t2 = $t0` |
| 0x09 | `0xB9` | `sub1 $t3` | `$t3 = $t3 − 1` |
| 0x0A | `0xA2` | `setc1` | `$c1 = 1` |
| 0x0B | `0x58` | `jc −8` | jump back to `loop` |
| 0x0C | `0xF1` | `set $t3, 1` | fim: `$t3 = 1` (result address) |
| 0x0D | `0x6E` | `sw $t1, $t3` | `mem[1] = $t1 = fib(n)` — the only data-memory write |

With `n = 10` (default) the simulation ends with:

```
fib(10) = 55 (mem[1])
```

Other examples: `./run.sh 12` → `fib(12) = 144`, `./run.sh 13` → `fib(13) = 233`.
