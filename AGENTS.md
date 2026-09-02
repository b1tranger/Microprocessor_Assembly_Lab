# Agent Guidelines: Microprocessor & Assembly Theory Documentation

## Purpose
This document provides instructions for automatically documenting assembly theory notes whenever code files in this repository are discussed, debugged, or analyzed.

---

## Theory Note Generation & Update Rules

### 1. File Naming & Destination
* **Target Directory**: Always save theory notes in the `Learning` folder under `LabCodes/` (i.e., `LabCodes/Learning/`).
* **Naming Convention**: Use the base name of the assembly file being discussed, followed by `-theory.md`.
  - Example: `5.1.asm` $\rightarrow$ `LabCodes/Learning/5.1-theory.md`
  - Example: `A4.asm` $\rightarrow$ `LabCodes/Learning/A4-theory.md`
  - Example: `6.asm` $\rightarrow$ `LabCodes/Learning/6-theory.md`

### 2. Automatic Updates
* Whenever new concepts, questions, clarifications, or code improvements regarding a specific assembly file are discussed in the chat, immediately create or update its corresponding `<filename>-theory.md` file.
* Ensure existing content is preserved while integrating new explanations, diagrams, and code snippets.

---

## Content & Formatting Standards

Follow the format, depth, and presentation demonstrated in `LabCodes/Learning/A4-theory.md` and `LabCodes/Learning/6-theory.md`:

1. **Clear Architectural & Hardware Explanations**:
   - Explain what the 8086 CPU and registers (`AX`, `BX`, `CX`, `DX`, `SP`, `BP`, `SI`, `DI`, `IP`, `FLAGS`) are doing under the hood.
   - Clarify the stack operations (`PUSH`, `POP`, `CALL`, `RET`) and memory segmentation.

2. **Procedures, Control Flow & Directives**:
   - Differentiate between assembler directives (`PROC`, `ENDP`, `.MODEL`, `.DATA`, `.CODE`) and CPU machine instructions.
   - Clarify jumps (`JMP`, conditional jumps like `JE`, `JNE`, `JB`, `JBE`, `JA`, `JAE`) vs. subroutine calls (`CALL` / `RET`).

3. **Comparative Analysis & Visuals**:
   - Include comparison tables (e.g., `CALL` vs `JMP`, register aliasing mappings).
   - Use ASCII register/stack diagrams where helpful.
   - Provide equivalent High-Level Language (C/C++) snippets to bridge understanding.

4. **Step-by-Step Code Traces & Mathematics**:
   - Detail numerical conversions (e.g., ASCII/Hex conversion math `+48` vs `+7`, BCD, bitwise shifts/masks).
   - Trace register states line by line for complex logic.

5. **Pitfalls & Best Practices**:
   - Highlight common bugs (e.g., uninitialized `AH` before `DIV`, missing `RET`, stack imbalance, flag clobbering).
