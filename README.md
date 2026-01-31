# MIPS32 Pipelined Processor – Verilog HDL

A 5-stage pipelined MIPS32 processor implemented in Verilog HDL, supporting arithmetic, memory, and branch instructions.

The design follows a classic RISC pipeline with clearly separated stages and pipeline registers, verified through multiple targeted testbenches.

## Pipeline Stages
- Instruction Fetch (IF)
- Instruction Decode / Register Fetch (ID)
- Execute (EX)
- Memory Access (MEM)
- Write Back (WB)

## Supported Instructions
- R-type: ADD, SUB, AND, OR, SLT, MUL
- Immediate: ADDI, SUBI, SLTI
- Memory: LW, SW
- Branch: BEQZ, BNEQZ
- Control: HLT

## Design Highlights
- Fully pipelined architecture
- Separate pipeline registers between stages
- Centralized control logic
- Branch handling using EX-stage condition evaluation
- Synthesizable RTL design

## Verification Strategy
The processor was verified using multiple focused testbenches:
- **ALU Testbench:** Arithmetic and logic instruction validation
- **Memory Testbench:** Load/store correctness and data memory behavior
- **Branch Testbench:** Control flow and PC update verification

Each testbench loads a dedicated instruction memory program and validates correct pipeline execution using waveform analysis.

## Repository Structure
rtl/ - MIPS32 processor RTL
tb/ - Instruction-class-specific testbenches
docs/ - Pipeline diagrams and testbench results


## Tools Used
- Vivado Simulator
- GTKWave
- Vivado (RTL synthesis and analysis)

## Author
Lokesh Kumar A
