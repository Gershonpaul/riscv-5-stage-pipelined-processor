\# 5-Stage Pipelined RISC-V Processor (Verilog) - Simulation and Verification



A 32-bit RISC-V (RV32I subset) processor with a classic 5-stage pipeline (IF, ID, EX, MEM, WB), written in Verilog.



\## Credits



The RTL design in `rtl/` is the open-source core by \*\*MERL-DSU\*\* (Apache License 2.0), taken from: https://github.com/merldsu/RISCV\_Pipeline\_Core



All original copyright headers are kept in the source files.



\## My contribution



\- Set up the toolchain (Icarus Verilog + GTKWave) and ran the design from scratch

\- Wrote a \*\*self-checking testbench\*\* (`tb/pipeline\_results\_tb.v`) that logs every write-back and checks the final register values (PASS/FAIL)

\- Analyzed the waveforms, including \*\*data forwarding\*\*, and documented the results

\- Documented the architecture and the limitations found while reading the code



\## Architecture



| Stage | File |

|---|---|

| Instruction Fetch (IF) | `Fetch\_Cycle.v`, `PC.v`, `PC\_Adder.v`, `Instruction\_Memory.v` |

| Instruction Decode (ID) | `Decode\_Cyle.v`, `Control\_Unit\_Top.v`, `Main\_Decoder.v`, `ALU\_Decoder.v`, `Register\_File.v`, `Sign\_Extend.v` |

| Execute (EX) | `Execute\_Cycle.v`, `ALU.v` |

| Memory (MEM) | `Memory\_Cycle.v`, `Data\_Memory.v` |

| Write-Back (WB) | `Writeback\_Cycle.v` |

| Hazard handling | `Hazard\_unit.v` |

| Top level | `Pipeline\_Top.v` |



\*\*Supported instructions (from the decoder):\*\* R-type (add, sub, slt, or, and), I-type ALU (addi), `lw`, `sw`, and `beq` decoding.



\*\*Hazard handling:\*\* data forwarding only (from the MEM and WB stages to the EX stage). There is no stall or flush logic.



\*\*Known limitations (found while reading the code):\*\*

\- `Sign\_Extend.v` only handles I-type and S-type immediates, so the branch immediate (`ImmSrc = 10`) is not generated. Branches are therefore not verified here.

\- No load-use stall and no branch flush.



\## Test program



`sim/memfile.hex` holds a 6-instruction program:



| # | Hex | Instruction | Expected result |

|---|---|---|---|

| 1 | `00500293` | `addi x5, x0, 5` | x5 = 5 |

| 2 | `00300313` | `addi x6, x0, 3` | x6 = 3 |

| 3 | `006283B3` | `add x7, x5, x6` | x7 = 8 (needs forwarding) |

| 4 | `00002403` | `lw x8, 0(x0)` | x8 = 0 |

| 5 | `00100493` | `addi x9, x0, 1` | x9 = 1 |

| 6 | `00940533` | `add x10, x8, x9` | x10 = 1 (needs forwarding) |



\## How to simulate



Tools: \[Icarus Verilog](https://bleyer.org/icarus/) and GTKWave.



```

cd sim

iverilog -I ..\\rtl -o pipeline\_results.vvp ..\\tb\\pipeline\_results\_tb.v ..\\rtl\\Pipeline\_Top.v

vvp pipeline\_results.vvp > sim\_log.txt

gtkwave dump.vcd pipeline.gtkw

```



Run from the `sim` folder, because `Instruction\_Memory.v` loads `memfile.hex` by relative path.



\## Results



The log is in `sim/sim\_log.txt`. All six register checks pass:



```

x5 = 5, x6 = 3, x7 = 8, x8 = 0, x9 = 1, x10 = 1

==== RESULT: ALL TESTS PASSED ====

```



Waveforms (`sim/waveforms/`):



!\[Terminal result](sim/waveforms/terminal\_result.png)

!\[Full waveform](sim/waveforms/full\_waveform.png)

!\[Forwarding](sim/waveforms/forwarding.png)



\## License



Apache License 2.0 (see `LICENSE`). Original design copyright 2023 MERL-DSU.

