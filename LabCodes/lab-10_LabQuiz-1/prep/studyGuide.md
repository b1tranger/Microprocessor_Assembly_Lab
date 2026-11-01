# 8086 Assembly Socrative Lab Quiz 1: Comprehensive Study Guide & Question Bank

This study guide provides an exhaustive, exam-focused preparation resource for the upcoming 8086 Assembly Language Lab Quiz (administered via Socrative). It synthesizes all core concepts from **Lab 1 through Lab 9**, integrates high-yield insights from [`doc/note/0.mustKnows.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/doc/note/0.mustKnows.md) and [`LabCodes/Learning/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning), incorporates rigorous architectural research on 8086 microprocessors, and delivers an extensive bank of Socrative-style Multiple Choice Questions (MCQs), True/False challenges, and code execution output tracing problems.

---

## Table of Contents
1. [Official Quiz Syllabus & Scope](#1-official-quiz-syllabus--scope)
2. [Lab-by-Lab Concept Breakdown & Quiz Takeaways (Labs 1–9)](#2-lab-by-lab-concept-breakdown--quiz-takeaways-labs-19)
   - [Lab 1: String Display & Program Structure](#lab-1-string-display--program-structure)
   - [Lab 2: Single-Character I/O & DOS Services](#lab-2-single-character-io--dos-services)
   - [Lab 3: Arithmetic Operations & Decimal Separation](#lab-3-arithmetic-operations--decimal-separation)
   - [Lab 4: Marks Calculation & Accumulator Workflows](#lab-4-marks-calculation--accumulator-workflows)
   - [Lab 5: Bitwise Operations & Hexadecimal Conversion](#lab-5-bitwise-operations--hexadecimal-conversion)
   - [Lab 6: Character Case Conversion & Bit Toggling](#lab-6-character-case-conversion--bit-toggling)
   - [Lab 7: Loops, Counters, and Indexed Arrays](#lab-7-loops-counters-and-indexed-arrays)
   - [Lab 8: Dedicated Lab Test 1 Prep (Shifts, Rotates & Register Hygiene)](#lab-8-dedicated-lab-test-1-prep-shifts-rotates--register-hygiene)
   - [Lab 9: Number Comparison & Conditional Branching](#lab-9-number-comparison--conditional-branching)
3. [The "Must-Knows" Quiz Cheat Sheet (High-Yield Traps)](#3-the-must-knows-quiz-cheat-sheet-high-yield-traps)
   - [1. The 8086 Shift/Rotate Hardware Constraint (The CL Rule)](#1-the-8086-shiftrotate-hardware-constraint-the-cl-rule)
   - [2. ALU Instructions Never Require INT 21h](#2-alu-instructions-never-require-int-21h)
   - [3. Division Dividend & Register Hygiene (Zeroing AH / DX)](#3-division-dividend--register-hygiene-zeroing-ah--dx)
   - [4. Implicit Sizing for Multiplication (MUL / IMUL)](#4-implicit-sizing-for-multiplication-mul--imul)
   - [5. The INC / DEC Carry Flag Exemption](#5-the-inc--dec-carry-flag-exemption)
   - [6. Non-Destructive Comparisons: CMP vs SUB and TEST vs AND](#6-non-destructive-comparisons-cmp-vs-sub-and-test-vs-and)
   - [7. Logical Shift vs. Arithmetic Shift (SHR vs. SAR)](#7-logical-shift-vs-arithmetic-shift-shr-vs-sar)
   - [8. Shift vs. Rotate Bit Conservation](#8-shift-vs-rotate-bit-conservation)
   - [9. Unsigned (Above/Below) vs. Signed (Greater/Less) Jumps](#9-unsigned-abovebelow-vs-signed-greaterless-jumps)
   - [10. Conditional Jump Aliases (Same Machine Opcode)](#10-conditional-jump-aliases-same-machine-opcode)
   - [11. The LOOP Instruction Hardware Mechanics](#11-the-loop-instruction-hardware-mechanics)
   - [12. Memory Segmentation & Register Architecture](#12-memory-segmentation--register-architecture)
4. [In-Depth Syllabus Technical Reference](#4-in-depth-syllabus-technical-reference)
   - [4.1 Arithmetic Operations (ADD, ADC, SUB, SBB, MUL, DIV, INC, DEC, NEG)](#41-arithmetic-operations-add-adc-sub-sbb-mul-div-inc-dec-neg)
   - [4.2 Bitwise Logic Operations (AND, OR, XOR, NOT, TEST)](#42-bitwise-logic-operations-and-or-xor-not-test)
   - [4.3 Shift and Rotate Operations (SHL, SHR, SAL, SAR, ROL, ROR, RCL, RCR)](#43-shift-and-rotate-operations-shl-shr-sal-sar-rol-ror-rcl-rcr)
   - [4.4 Jump Conditions, Flag Mechanics & Flow Control](#44-jump-conditions-flag-mechanics--flow-control)
5. [Extensive Socrative-Style Question Bank](#5-extensive-socrative-style-question-bank)
   - [Category A: CPU Architecture, Segments & Registers (Q1–Q12)](#category-a-cpu-architecture-segments--registers-q1q12)
   - [Category B: Arithmetic Operations & Flag Effects (Q13–Q25)](#category-b-arithmetic-operations--flag-effects-q13q25)
   - [Category C: Bitwise AND, OR, XOR, Shift & Rotate (Q26–Q40)](#category-c-bitwise-and-or-xor-shift--rotate-q26q40)
   - [Category D: Comparisons, Jump Conditions & Loops (Q41–Q55)](#category-d-comparisons-jump-conditions--loops-q41q55)
   - [Category E: Complex Code Output Prediction Challenges (Q56–Q65)](#category-e-complex-code-output-prediction-challenges-q56q65)
6. [Summary Checklist for the Exam](#6-summary-checklist-for-the-exam)

---

## 1. Official Quiz Syllabus & Scope

The Socrative quiz focuses on fundamental microprocessor operations, instruction mechanics, status flag updates, and code output evaluation.

```
+-----------------------------------------------------------------------------+
|                            QUIZ SYLLABUS                                    |
|                                                                             |
| 1. Arithmetic Operations:                                                   |
|    - ADD, SUB, INC, DEC, NEG, ADC, SBB                                      |
|    - MUL / IMUL (8-bit and 16-bit register mappings)                        |
|    - DIV / IDIV (Dividend sizing, quotient/remainder placement, #DE trap)   |
|                                                                             |
| 2. Bitwise Logic & Shifting:                                                |
|    - AND, OR, XOR, NOT, TEST                                                |
|    - SHL / SAL, SHR, SAR (Logical vs Arithmetic)                            |
|    - ROL, ROR, RCL, RCR (Bit wrapping vs Carry-through)                    |
|    - 8086 CL register shift-count constraint                                |
|                                                                             |
| 3. Jump Conditions & Control Flow:                                          |
|    - Unconditional JMP                                                      |
|    - Unsigned Jumps: JA, JNBE, JAE, JNB, JB, JNAE, JC, JBE, JNA, JNC       |
|    - Signed Jumps: JG, JNLE, JGE, JNL, JL, JNGE, JLE, JNG                   |
|    - Equality & Flag Jumps: JE, JZ, JNE, JNZ, JO, JNO, JS, JNS, JP, JPE     |
|    - LOOP, LOOPE, LOOPNE, JCXZ mechanics                                    |
|                                                                             |
| Question Format: Multiple Choice Questions (MCQs), True/False, and          |
|                  Code Output Tracing (Given a code snippet, find result).   |
+-----------------------------------------------------------------------------+
```

---

## 2. Lab-by-Lab Concept Breakdown & Quiz Takeaways (Labs 1–9)

### Lab 1: String Display & Program Structure
* **Source Files**: [`1.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-1_String_Display/1.1.asm), [`lab-1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-1_String_Display/lab-1.asm)
* **Theory Note**: [`1.1-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/1.1-theory.md)
* **Key Quiz Concepts**:
  - **Memory Model**: `.MODEL SMALL` sets up a 64 KB code segment and a 64 KB data segment.
  - **Data Segment Initialization**: `MOV AX, @DATA` followed by `MOV DS, AX`. Direct moves to segment registers (`MOV DS, @DATA`) are **illegal** on the 8086.
  - **String Printing Service**: `INT 21H` with `AH = 09H`.
  - **Sentinel Terminator**: String buffers must end with the dollar sign character (`$` = ASCII `24H`). Without `$`, DOS prints consecutive memory bytes indefinitely until a random `$` byte is encountered.
  - **Pointer Loading**: `LEA DX, msg` (Load Effective Address) or `MOV DX, OFFSET msg`.

### Lab 2: Single-Character I/O & DOS Services
* **Source Files**: [`2.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2_Character_IO/2.1.asm), [`2.2.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2_Character_IO/2.2.asm), [`2.3.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2_Character_IO/2.3.asm)
* **Theory Note**: [`2.1-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/2.1-theory.md)
* **Key Quiz Concepts**:
  - **Character Input (`AH = 01H`)**: Waits for keyboard input, echoes character to screen, returns ASCII code in register **`AL`**.
  - **Character Output (`AH = 02H`)**: Transmits the byte in register **`DL`** to the screen. Returns `AL = DL`.
  - **Program Exit (`AH = 4CH`)**: Hands control back to MS-DOS. Often paired with `AL = 00H` (exit code) or written as `MOV AX, 4C00H; INT 21H`.
  - **Newline Sequence (CRLF)**: ASCII `13` (`0DH` - Carriage Return) moves cursor to column 0; ASCII `10` (`0AH` - Line Feed) moves cursor down one line.

### Lab 3: Arithmetic Operations & Decimal Separation
* **Source Files**: [`3.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-3_Arithmetic_Operations/3.1.asm), [`3.2.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-3_Arithmetic_Operations/3.2.asm)
* **Theory Note**: [`3.2-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/3.2-theory.md)
* **Key Quiz Concepts**:
  - **ASCII to Integer**: Subtract `48` (or `'0'` or `30H`). Example: `'5'` (`35H`) $- 48 = 5$.
  - **Integer to ASCII**: Add `48` (or `'0'` or `30H`). Example: $7 + 48 = 55$ (`'7'`).
  - **Radix-10 Decomposition for 2-Digit Display**: To print a number $N \in [0, 99]$:
    1. Place number in `AX` (with `AH = 0`).
    2. Divide by `10` via `DIV BL` (where `BL = 10`).
    3. Quotient in `AL` = Tens digit $\rightarrow$ add `48` and print via `AH = 02H`.
    4. Remainder in `AH` = Units digit $\rightarrow$ add `48` and print via `AH = 02H`.

### Lab 4: Marks Calculation & Accumulator Workflows
* **Source Files**: [`4.1_CP.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-4_Marks_Calculation/4.1_CP.asm)
* **Theory Note**: [`4.1_CP-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/4.1_CP-theory.md)
* **Key Quiz Concepts**:
  - **Accumulator Chaining**: Using registers (such as `BL` or `AL`) to accumulate running totals of user grades.
  - **Intermediate Input Conversion**: Input read via `INT 21H, AH=01H` yields ASCII digits in `AL`. You **must** subtract `'0'` before arithmetic addition, otherwise summing ASCII codes results in rapid byte overflow.

### Lab 5: Bitwise Operations & Hexadecimal Conversion
* **Source Files**: [`5.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-5_Bitwise_Hex_Display/5.1.asm)
* **Theory Note**: [`5.1-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/5.1-theory.md)
* **Key Quiz Concepts**:
  - **Nibble Isolation**: An 8-bit byte consists of two 4-bit nibbles:
    - Upper Nibble: `SHR AL, 4` (or `MOV CL, 4; SHR AL, CL`).
    - Lower Nibble: `AND AL, 0FH`.
  - **Hexadecimal ASCII Conversion Rule**:
    - If nibble $\le 9$: Add `48` (`'0'`).
    - If nibble $\ge 10$ (`0AH` to `0FH`): Add $48 + 7 = 55$ (producing ASCII `'A'` through `'F'`).

### Lab 6: Character Case Conversion & Bit Toggling
* **Source Files**: [`6.1_CP.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-6_Case_Conversion/6.1_CP.asm), [`6.1_CP-alt.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-6_Case_Conversion/6.1_CP-alt.asm)
* **Theory Note**: [`6-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/6-theory.md)
* **Key Quiz Concepts**:
  - **Bit 5 Alignment**: Uppercase letters `'A'`–`'Z'` (`41H`–`5AH`) and lowercase letters `'a'`–`'z'` (`61H`–`7AH`) differ **only at Bit 5** ($2^5 = 32 = 20\text{H}$).
  - **To Lowercase**: `OR AL, 20H` (sets bit 5 to 1).
  - **To Uppercase**: `AND AL, 0DFH` (clears bit 5 to 0; `0DFH` = `1101 1111B`).
  - **Toggle Case**: `XOR AL, 20H` (inverts bit 5).

### Lab 7: Loops, Counters, and Indexed Arrays
* **Source Files**: [`7.1_loop.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7_Loops_and_Arrays/7.1_loop.asm), [`7.2_task.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7_Loops_and_Arrays/7.2_task.asm), [`7.3_Array.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7_Loops_and_Arrays/7.3_Array.asm), [`7.4_Array_sum.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7_Loops_and_Arrays/7.4_Array_sum.asm)
* **Theory Note**: [`7.1-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/7.1-theory.md), [`7.2_task-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/7.2_task-theory.md)
* **Key Quiz Concepts**:
  - **`LOOP` Register**: Always uses the **`CX`** register as its implicit hardware iteration counter.
  - **`LOOP` Execution Cycle**:
    1. Automatically decrements `CX` by 1 ($CX = CX - 1$).
    2. Checks if $CX \ne 0$.
    3. If $CX \ne 0$, jumps to the target label; if $CX = 0$, falls through.
  - **Flags**: `LOOP` **does NOT affect any CPU flags** (unlike `DEC CX; JNZ label`, which modifies `ZF`).
  - **Base/Index Addressing**: `MOV DL, [SI]` reads the byte pointed to by Source Index `SI`. Array traversal uses `INC SI` (or `ADD SI, 2` for word arrays).

### Lab 8: Dedicated Lab Test 1 Prep (Shifts, Rotates & Register Hygiene)
* **Source Files**: [`arithmetic_operations.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-8_Labtest-1/prep/arithmetic_operations.asm), [`bitwise_and_or_shift_rotate.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-8_Labtest-1/prep/bitwise_and_or_shift_rotate.asm), [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-8_Labtest-1/prep/CSE55-096/shl_Semim.asm), [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-8_Labtest-1/prep/CSE55-096/shr_Semim.asm)
* **Theory Note**: [`shl_shr_Semim-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/shl_shr_Semim-theory.md), [`summary.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-8_Labtest-1/prep/summary.md)
* **Key Quiz Concepts**:
  - **Hardware Count Constraint**: For shifts/rotates $> 1$, the count must be loaded into **`CL`** (`MOV CL, 4; SHR AL, CL`).
  - **`SHL AL, 1` vs `SHR AL, 1`**:
    - `SHL` multiplies unsigned numbers by 2. Bit 7 moves into Carry Flag (`CF`), `0` enters Bit 0.
    - `SHR` divides unsigned numbers by 2. Bit 0 moves into `CF`, `0` enters Bit 7.
  - **Bit Wrapping in `ROL` / `ROR`**: Bits rotated out of one end are copied into both `CF` and the opposite end. Bits are **never lost**.

### Lab 9: Number Comparison & Conditional Branching
* **Source Files**: [`9.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/9.1.asm), [`9.2_assignment.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/9.2_assignment.asm), [`3value_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/3value_Semim.asm)
* **Theory Note**: [`9.1-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/9.1-theory.md)
* **Key Quiz Concepts**:
  - **`CMP dest, src` Mechanics**: Computes $(dest - src)$, sets CPU flags (`ZF`, `SF`, `CF`, `OF`, `PF`, `AF`), and **discards the arithmetic result**. Operands remain completely unchanged.
  - **Signed Jumps**: Use `JG`, `JL`, `JGE`, `JLE` (evaluate $SF$ and $OF$).
  - **Unsigned Jumps**: Use `JA`, `JB`, `JAE`, `JBE` (evaluate $CF$ and $ZF$).
  - **Fallthrough Trap**: Omitting an unconditional `JMP exit` causes code execution to fall directly into subsequent branch blocks.

---

## 3. The "Must-Knows" Quiz Cheat Sheet (High-Yield Traps)

This section compiles essential traps, hardware rules, and common distractors that frequently appear in Socrative MCQs.

### 1. The 8086 Shift/Rotate Hardware Constraint (The CL Rule)
* On original 8086/8088 hardware, immediate shift counts can **only be 1** (`SHL AL, 1`).
* Shifting by any immediate value $> 1$ (e.g. `SHL AL, 4`) is **illegal** on 8086 machine code.
* To shift or rotate by more than 1 bit, the count **must** be loaded into register **`CL`**:
  ```assembly
  mov cl, 4
  shr al, cl     ; Legal 8086 instruction
  ```

### 2. ALU Instructions Never Require INT 21h
* Instructions like `ADD`, `SUB`, `MUL`, `DIV`, `AND`, `OR`, `XOR`, `SHL`, `SHR`, `ROL`, `ROR`, and `CMP` are internal CPU machine operations.
* They execute directly in silicon and do **not** invoke DOS.
* **Trap**: Placing `INT 21H` after `ADD AL, BL` without resetting `AH` will re-trigger whatever DOS service happened to be leftover in `AH` (e.g., printing garbage to screen or crashing).

### 3. Division Dividend & Register Hygiene (Zeroing AH / DX)
* **8-bit Division (`DIV reg8`)**: Divides the **16-bit register `AX`** by `reg8`.
  $$\text{Quotient} \rightarrow \text{AL}, \quad \text{Remainder} \rightarrow \text{AH}$$
* **The Catastrophic Trap**: If `AH` has leftover garbage from an earlier operation, `AX` is huge! This triggers a **Divide Error Fault (`#DE` / Interrupt 0)**.
* **The Fix**: Always clear `AH` before 8-bit division:
  ```assembly
  mov ah, 0      ; Or: xor ah, ah
  mov al, num1
  div bl         ; Safe division
  ```
* **16-bit Division (`DIV reg16`)**: Divides the **32-bit register pair `DX:AX`** by `reg16`.
  $$\text{Quotient} \rightarrow \text{AX}, \quad \text{Remainder} \rightarrow \text{DX}$$
  `DX` must be zeroed before unsigned 16-bit division: `XOR DX, DX`.

### 4. Implicit Sizing for Multiplication (MUL / IMUL)
* `MUL` takes only **one explicit operand**; the other operand is implicitly `AL` or `AX`:
  - 8-bit: `MUL BL` $\implies \text{AX} = \text{AL} \times \text{BL}$ (product stored in 16-bit `AX`).
  - 16-bit: `MUL BX` $\implies \text{DX:AX} = \text{AX} \times \text{BX}$ (high word in `DX`, low word in `AX`).
* **Flag Rule for `MUL`**: If upper half of the product contains significant digits (`AH != 0` for 8-bit, or `DX != 0` for 16-bit), both **`CF = 1`** and **`OF = 1`**. Otherwise, `CF = 0` and `OF = 0`.

### 5. The INC / DEC Carry Flag Exemption
* **`INC reg`** and **`DEC reg`** affect `ZF`, `SF`, `OF`, `AF`, and `PF`, but **NEVER affect the Carry Flag (`CF`)**!
* **Why?** This hardware design allows `INC` to update loop counters without clobbering the carry flag during multi-word addition loops (`ADC`).
* **Trap Question**:
  ```assembly
  MOV AL, 0FFH
  INC AL
  ```
  Result: `AL = 00H`, `ZF = 1`, but **`CF = 0` (unchanged)**!
  *(If `ADD AL, 1` were used instead, `CF` would become `1`)*.

### 6. Non-Destructive Comparisons: CMP vs SUB and TEST vs AND
* `CMP dest, src`: Computes $(dest - src)$, updates all arithmetic flags, but **does NOT store the difference**. `dest` is unchanged.
* `SUB dest, src`: Computes $(dest - src)$, updates all arithmetic flags, and **overwrites `dest`** with the result.
* `TEST dest, src`: Computes $(dest \text{ AND } src)$, updates `ZF`, `SF`, `PF` (clears `CF` and `OF` to 0), but **does NOT overwrite `dest`**.
* `AND dest, src`: Computes $(dest \text{ AND } src)$, updates flags, and **overwrites `dest`**.

### 7. Logical Shift vs. Arithmetic Shift (SHR vs. SAR)
* **`SHR` (Logical Shift Right)**:
  - Shifts all bits right.
  - Inserts **`0`** into the Most Significant Bit (MSB, Bit 7).
  - Outgoing Bit 0 enters **`CF`**.
  - Used for **unsigned numbers**.
* **`SAR` (Arithmetic Shift Right)**:
  - Shifts all bits right.
  - Replicates the **sign bit (original Bit 7)** into the MSB to preserve sign!
  - Outgoing Bit 0 enters **`CF`**.
  - Used for **signed numbers** (preserves negative values).

```
SHR:  [ 0 ] ---> [b7][b6][b5][b4][b3][b2][b1][b0] ---> [ CF ]

SAR:  [b7] ----> [b7][b6][b5][b4][b3][b2][b1][b0] ---> [ CF ]
        |________^ (Sign bit preserved)
```

### 8. Shift vs. Rotate Bit Conservation
* **Shift (`SHL`, `SHR`)**: Drops bits into `CF` and fills empty spots with zeroes. Bits are **discarded**.
* **Rotate (`ROL`, `ROR`)**: Rotates bits circularly. The bit pushed out of one end is placed in `CF` **and** recirculated back into the opposite end. **All bits are conserved**.
* **Rotate Through Carry (`RCL`, `RCR`)**: Treats `CF` as a 9th bit. Rotates the 9-bit register-plus-carry ring.

### 9. Unsigned (Above/Below) vs. Signed (Greater/Less) Jumps
| Type | Greater Condition | Less Condition | Tested Flags |
| :--- | :--- | :--- | :--- |
| **Unsigned** | **`JA` / `JNBE`** (Above) | **`JB` / `JNAE` / `JC`** (Below) | Carry Flag (`CF`) and Zero Flag (`ZF`) |
| **Signed** | **`JG` / `JNLE`** (Greater) | **`JL` / `JNGE`** (Less) | Sign Flag (`SF`), Overflow Flag (`OF`), and `ZF` |

* **Golden Rule**:
  - Memory addresses and character ASCII codes: Use **`JA` / `JB`**.
  - Signed quantities (positive and negative integers): Use **`JG` / `JL`**.

### 10. Conditional Jump Aliases (Same Machine Opcode)
Certain jump mnemonics share the identical machine code opcode in the 8086:
* `JE` (Jump if Equal) $\equiv$ `JZ` (Jump if Zero) $\rightarrow$ Opcode `74H` ($ZF = 1$)
* `JNE` (Jump if Not Equal) $\equiv$ `JNZ` (Jump if Not Zero) $\rightarrow$ Opcode `75H` ($ZF = 0$)
* `JB` (Jump if Below) $\equiv$ `JC` (Jump if Carry) $\equiv$ `JNAE` (Jump if Not Above or Equal) $\rightarrow$ Opcode `72H` ($CF = 1$)
* `JAE` (Jump if Above or Equal) $\equiv$ `JNC` (Jump if No Carry) $\equiv$ `JNB` $\rightarrow$ Opcode `73H` ($CF = 0$)

### 11. The LOOP Instruction Hardware Mechanics
* `LOOP target` automatically decrements `CX` and branches if $CX \ne 0$.
* It is a **single-instruction loop controller**.
* **Crucial Quiz Fact**: `LOOP` does **not alter any flags in the FLAGS register**.
* **Zero Counter Hazard**: If `CX = 0` prior to executing `LOOP`, `CX` decrements from `0000H` to `FFFFH` (65,535), causing the loop to execute **65,536 times**!
* Prevention: Use `JCXZ exit` before the loop to bypass execution if `CX` is already zero.

### 12. Memory Segmentation & Register Architecture
* **Segment Registers (16-bit)**:
  - `CS` (Code Segment): Stores program executable machine instructions.
  - `DS` (Data Segment): Stores global variables, arrays, and string constants.
  - `SS` (Stack Segment): Stores the stack data structure (subroutine return addresses, pushed registers).
  - `ES` (Extra Segment): Used for string operations and destination data.
* **General-Purpose Registers**:
  - 16-bit: `AX`, `BX`, `CX`, `DX`.
  - 8-bit halves: `AH`/`AL`, `BH`/`BL`, `CH`/`CL`, `DH`/`DL`.
* **Stack Pointer**:
  - `PUSH operand16`: Decrements `SP` by 2 ($SP = SP - 2$).
  - `POP operand16`: Increments `SP` by 2 ($SP = SP + 2$).
  - Stack operates in Last-In, First-Out (**LIFO**) order.
  - 8-bit pushes (`PUSH AL`) are **illegal** on the 8086. Only 16-bit words can be pushed.

---

## 4. In-Depth Syllabus Technical Reference

### 4.1 Arithmetic Operations (ADD, ADC, SUB, SBB, MUL, DIV, INC, DEC, NEG)

#### 1. ADD and ADC
* `ADD dest, src`: Calculates $dest = dest + src$. Updates `CF`, `OF`, `SF`, `ZF`, `AF`, `PF`.
* `ADC dest, src` (Add with Carry): Calculates $dest = dest + src + CF$. Used in multi-word arithmetic (e.g. 32-bit addition on a 16-bit CPU).

#### 2. SUB and SBB
* `SUB dest, src`: Calculates $dest = dest - src$. If $dest < src$ (unsigned), sets borrow flag `CF = 1`.
* `SBB dest, src` (Subtract with Borrow): Calculates $dest = dest - (src + CF)$.

#### 3. NEG
* `NEG dest`: Computes the two's complement of the operand ($0 - dest$). Inverts all bits and adds 1.
* Sets `CF = 1` for all nonzero operands; sets `CF = 0` only when operand is 0.

#### 4. MUL and IMUL
* `MUL` is unsigned; `IMUL` is signed.
* Execution register mappings:
  | Operand Size | Multiplicand | Multiplier | Destination (Product) | Flag Effect (`CF`, `OF`) |
  | :--- | :--- | :--- | :--- | :--- |
  | **Byte (8-bit)** | `AL` | `reg8` / `mem8` | `AX` (16-bit) | `1` if `AH != 0`, else `0` |
  | **Word (16-bit)** | `AX` | `reg16` / `mem16` | `DX:AX` (32-bit, `DX`=high, `AX`=low) | `1` if `DX != 0`, else `0` |

#### 5. DIV and IDIV
* `DIV` is unsigned; `IDIV` is signed.
* Sizing table:
  | Division Type | Dividend | Divisor | Quotient | Remainder |
  | :--- | :--- | :--- | :--- | :--- |
  | **8-bit Divisor** | `AX` (16-bit) | `reg8` / `mem8` | **`AL`** | **`AH`** |
  | **16-bit Divisor** | `DX:AX` (32-bit) | `reg16` / `mem16` | **`AX`** | **`DX`** |

> [!WARNING]
> **Divide Error Fault (`#DE`)**: Occurs if the divisor is 0, OR if the quotient is too large to fit in the destination register (`AL` $> 255$ for 8-bit division, or `AX` $> 65535$ for 16-bit division).

---

### 4.2 Bitwise Logic Operations (AND, OR, XOR, NOT, TEST)

| Instruction | Truth Table / Operation | Flag Effects | High-Yield Application |
| :--- | :--- | :--- | :--- |
| **`AND dest, src`** | $1 \text{ AND } 1 = 1$, else $0$ | Clears `CF=0`, `OF=0`. Updates `SF`, `ZF`, `PF`. | **Bit Masking / Clearing**: Extracting lower nibble (`AND AL, 0FH`), clearing parity/sign bits. |
| **`OR dest, src`** | $0 \text{ OR } 0 = 0$, else $1$ | Clears `CF=0`, `OF=0`. Updates `SF`, `ZF`, `PF`. | **Bit Setting**: Forcing specific bits to 1 (e.g. lowercase conversion `OR AL, 20H`). |
| **`XOR dest, src`** | Equal bits = $0$, Distinct bits = $1$ | Clears `CF=0`, `OF=0`. Updates `SF`, `ZF`, `PF`. | **Bit Inversion / Zeroing**: `XOR AX, AX` clears register to zero in 2 bytes; `XOR AL, 20H` toggles ASCII case. |
| **`NOT dest`** | Flips all bits ($0 \rightarrow 1, 1 \rightarrow 0$) | **NO FLAGS AFFECTED!** | One's complement calculation. |
| **`TEST dest, src`** | Performs $dest \text{ AND } src$ without saving | Clears `CF=0`, `OF=0`. Updates `SF`, `ZF`, `PF`. Dest operand unchanged! | Checking if register is zero (`TEST AL, AL`), checking if bit is set without destroying value. |

---

### 4.3 Shift and Rotate Operations (SHL, SHR, SAL, SAR, ROL, ROR, RCL, RCR)

#### Summary Comparison Table:
| Instruction | Shift/Rotate Direction | Incoming Bit Injected | Bit Discarded / Shifted to Carry | Affects CF? | Preserves Original Bits? |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`SHL` / `SAL`** | Left ($\leftarrow$) | `0` injected into LSB | MSB enters `CF` | Yes | No |
| **`SHR`** | Right ($\rightarrow$) | `0` injected into MSB | LSB enters `CF` | Yes | No |
| **`SAR`** | Right ($\rightarrow$) | **Original MSB (Sign bit)** replicated | LSB enters `CF` | Yes | No |
| **`ROL`** | Left Circular ($\circlearrowleft$) | MSB recirculates into LSB | MSB also copied to `CF` | Yes | **Yes (All bits preserved)** |
| **`ROR`** | Right Circular ($\circlearrowright$) | LSB recirculates into MSB | LSB also copied to `CF` | Yes | **Yes (All bits preserved)** |
| **`RCL`** | Left through Carry | `CF` enters LSB | MSB enters `CF` | Yes | Yes (9-bit ring) |
| **`RCR`** | Right through Carry | `CF` enters MSB | LSB enters `CF` | Yes | Yes (9-bit ring) |

#### Multiplication and Division Shortcuts via Shifts:
* Shifting left by 1 (`SHL AL, 1`) multiplies unsigned value by $2^1 = 2$.
* Shifting left by $N$ (`SHL AL, CL` where $CL = N$) multiplies by $2^N$.
* Shifting right by 1 (`SHR AL, 1`) divides unsigned value by $2^1 = 2$.
* Shifting right arithmetically by 1 (`SAR AL, 1`) divides signed value by 2.

---

### 4.4 Jump Conditions, Flag Mechanics & Flow Control

#### 1. Flag Quick Summary:
* **`ZF` (Zero Flag)**: Set to `1` if ALU result is zero; `0` if nonzero.
* **`SF` (Sign Flag)**: Set to `1` if MSB of result is `1` (negative in signed representation); `0` if positive.
* **`CF` (Carry Flag)**: Set to `1` if an arithmetic operation generated a carry out of (or borrow into) the MSB.
* **`OF` (Overflow Flag)**: Set to `1` if a signed arithmetic operation produced a result outside the valid signed range (e.g., $+127$ to $-128$ for 8-bit).
* **`PF` (Parity Flag)**: Set to `1` if the low 8 bits of result contain an **even number of 1-bits**.

#### 2. Jump Decision Table:
```
+-----------------------------------------------------------------------------+
|                          JUMP INSTRUCTION MATRIX                            |
+---------------------+-------------------------------+-----------------------+
| Mnemonic            | Description                   | Condition Flag Test   |
+---------------------+-------------------------------+-----------------------+
| JMP target          | Unconditional Jump            | None (Always jumps)   |
| JE / JZ target      | Jump if Equal / Zero          | ZF = 1                |
| JNE / JNZ target    | Jump if Not Equal / Not Zero  | ZF = 0                |
+---------------------+-------------------------------+-----------------------+
| UNSIGNED CONDITIONS (After CMP A, B)                                        |
+---------------------+-------------------------------+-----------------------+
| JA / JNBE target    | Jump if Above (A > B)         | CF = 0 and ZF = 0     |
| JAE / JNB / JNC     | Jump if Above or Equal / No CF| CF = 0                |
| JB / JNAE / JC      | Jump if Below (A < B) / Carry | CF = 1                |
| JBE / JNA target    | Jump if Below or Equal        | CF = 1 or ZF = 1      |
+---------------------+-------------------------------+-----------------------+
| SIGNED CONDITIONS (After CMP A, B)                                          |
+---------------------+-------------------------------+-----------------------+
| JG / JNLE target    | Jump if Greater (A > B)       | ZF = 0 and SF = OF    |
| JGE / JNL target    | Jump if Greater or Equal      | SF = OF               |
| JL / JNGE target    | Jump if Less (A < B)          | SF != OF              |
| JLE / JNG target    | Jump if Less or Equal         | ZF = 1 or SF != OF    |
+---------------------+-------------------------------+-----------------------+
| MISCELLANEOUS CONDITIONAL JUMPS                                             |
+---------------------+-------------------------------+-----------------------+
| JS / JNS            | Jump if Sign (Negative / Pos) | SF = 1 / SF = 0       |
| JO / JNO            | Jump if Overflow / No Overflow| OF = 1 / OF = 0       |
| JP / JPE / JPO      | Parity Even / Parity Odd      | PF = 1 / PF = 0       |
| JCXZ target         | Jump if CX is Zero            | CX = 0                |
| LOOP target         | Decrement CX; Jump if CX != 0 | CX != 0 (No flags)    |
+---------------------+-------------------------------+-----------------------+
```

---

## 5. Extensive Socrative-Style Question Bank

*(Modeled after the official UITS Socrative format: MCQs, True/False, and Code Execution Output Traces)*

---

### Category A: CPU Architecture, Segments & Registers (Q1–Q12)

#### Question 1
**Which register is commonly used as the default loop counter in 8086 Assembly language?**
- [ ] A. AX
- [ ] B. BX
- [x] C. CX *(Correct)*
- [ ] D. DX

> **Explanation**: The `LOOP` instruction automatically decrements the `CX` register and jumps to the target address if `CX != 0`.

---

#### Question 2
**What is the size of the AH register in the 8086 microprocessor?**
- [x] A. 8-bit *(Correct)*
- [ ] B. 16-bit
- [ ] C. 32-bit
- [ ] D. 4-bit

> **Explanation**: The primary accumulator `AX` is a 16-bit register composed of two independent 8-bit registers: `AH` (high byte) and `AL` (low byte).

---

#### Question 3
**Which segment register is used by the 8086 CPU to fetch program executable machine instructions?**
- [ ] A. Data Segment (DS)
- [ ] B. Stack Segment (SS)
- [x] C. Code Segment (CS) *(Correct)*
- [ ] D. Extra Segment (ES)

> **Explanation**: Program code and instructions reside in the Code Segment (`CS`). Physical address $= CS \times 16 + IP$.

---

#### Question 4
**Which segment stores subroutine return addresses and data saved via PUSH?**
- [ ] A. Data Segment
- [ ] B. Code Segment
- [x] C. Stack Segment *(Correct)*
- [ ] D. Extra Segment

> **Explanation**: The Stack Segment (`SS`), indexed by `SP` (Stack Pointer), stores temporary frames, return addresses on `CALL`, and data saved with `PUSH`.

---

#### Question 5
**What is the role of the PUSH instruction in 8086 Assembly?**
- [ ] A. Remove data from memory
- [x] B. Push 16-bit data onto the stack *(Correct)*
- [ ] C. Copy data into register AX
- [ ] D. Perform an indirect jump

> **Explanation**: `PUSH` decrements `SP` by 2 and stores a 16-bit word onto the hardware stack.

---

#### Question 6
**The instruction `PUSH AL` is valid on the 8086 microprocessor.**
- [ ] True
- [x] False *(Correct)*

> **Explanation**: The 8086 stack architecture strictly operates on 16-bit words. Pushing or popping individual 8-bit registers (`AL`, `BL`, `CL`, etc.) is illegal.

---

#### Question 7
**Which interrupt value is invoked for MS-DOS standard operating system services?**
- [ ] A. INT 10H
- [ ] B. INT 20H
- [x] C. INT 21H *(Correct)*
- [ ] D. INT 33H

> **Explanation**: `INT 21H` is the MS-DOS Application Program Interface (API) vector handling console I/O, file management, and program termination.

---

#### Question 8
**What DOS service number must be placed in AH to terminate a program and return control to the OS?**
- [ ] A. 01H
- [ ] B. 02H
- [ ] C. 09H
- [x] D. 4CH *(Correct)*

> **Explanation**: Setting `AH = 4CH` and calling `INT 21H` terminates the process cleanly with a return code in `AL`.

---

#### Question 9
**Which instruction correctly loads the Data Segment register with the data segment address?**
- [ ] A. `MOV DS, @DATA`
- [x] B. `MOV AX, @DATA` followed by `MOV DS, AX` *(Correct)*
- [ ] C. `LEA DS, @DATA`
- [ ] D. `LDS DS, @DATA`

> **Explanation**: The 8086 hardware architecture does not support moving an immediate value directly into a segment register. An intermediate general-purpose register (usually `AX`) must be used.

---

#### Question 10
**Which character is used by DOS Service 09h (`INT 21H, AH=09H`) as the mandatory end-of-string sentinel?**
- [ ] A. Null character (`00H` / `\0`)
- [ ] B. Line Feed (`0AH`)
- [x] C. Dollar sign (`$` / `24H`) *(Correct)*
- [ ] D. Asterisk (`*`)

> **Explanation**: DOS Service 09h prints bytes sequentially starting at `DS:DX` until it encounters a literal dollar sign (`$`).

---

#### Question 11
**Direct memory-to-memory data transfers (e.g. `MOV [var2], [var1]`) are allowed in 8086 assembly.**
- [ ] True
- [x] False *(Correct)*

> **Explanation**: 8086 machine instructions cannot read from a memory location and write to another memory location in a single operation. The data must pass through a CPU register.

---

#### Question 12
**What happens to the Stack Pointer (`SP`) register when a `POP BX` instruction is executed?**
- [ ] A. It is decremented by 1
- [ ] B. It is decremented by 2
- [ ] C. It is incremented by 1
- [x] D. It is incremented by 2 *(Correct)*

> **Explanation**: The stack grows downward toward lower memory. `PUSH` decrements `SP` by 2, and `POP` increments `SP` by 2.

---

### Category B: Arithmetic Operations & Flag Effects (Q13–Q25)

#### Question 13
**What will be the value of AX after executing the following instructions?**
```assembly
MOV AX, 9
MOV BX, 3
DIV BX
```
- [ ] A. AX = 2
- [x] B. AX = 3 *(Correct)*
- [ ] C. AX = 0
- [ ] D. AX = 9

> **Explanation**: `DIV BX` performs 16-bit division: $DX:AX \div BX$. Here $AX = 9$, $BX = 3$. Quotient $= 9 \div 3 = 3$, stored in `AX`. Remainder $= 0$, stored in `DX`.

---

#### Question 14
**What will be the values in AL and AH after executing the following code?**
```assembly
MOV AX, 0019H   ; 25 in decimal
MOV BL, 10      ; 10 in decimal
DIV BL
```
- [x] A. AL = 2, AH = 5 *(Correct)*
- [ ] B. AL = 5, AH = 2
- [ ] C. AL = 2, AH = 0
- [ ] D. AL = 25, AH = 10

> **Explanation**: 8-bit division $AX \div BL$ yields quotient $25 \div 10 = 2$ stored in `AL`, and remainder $25 \pmod{10} = 5$ stored in `AH`.

---

#### Question 15
**What will be the value in AX after executing the following multiplication?**
```assembly
MOV AL, 5
MOV BL, 6
MUL BL
```
- [ ] A. AX = 001EH (30 decimal) *(Correct)*
- [ ] B. AX = 000BH (11 decimal)
- [ ] C. AL = 30, AH unchanged
- [ ] D. AX = 3000H

> **Explanation**: `MUL BL` calculates $AL \times BL = 5 \times 6 = 30$ (`001EH`). The 16-bit product is placed across the entire `AX` register (`AL = 1EH`, `AH = 00H`).

---

#### Question 16
**Which instruction increments AL by 1 without altering the Carry Flag (CF)?**
- [ ] A. `ADD AL, 1`
- [x] B. `INC AL` *(Correct)*
- [ ] C. `ADC AL, 1`
- [ ] D. `SUB AL, -1`

> **Explanation**: By architectural design, `INC` and `DEC` update `ZF`, `SF`, `OF`, `AF`, and `PF`, but leave `CF` completely unaffected.

---

#### Question 17
**What will be the value of AL and the status of the Zero Flag (ZF) after this code?**
```assembly
MOV AL, 0FFH
INC AL
```
- [ ] A. AL = 01H, ZF = 0, CF = 1
- [x] B. AL = 00H, ZF = 1, CF = 0 (unchanged) *(Correct)*
- [ ] C. AL = 00H, ZF = 1, CF = 1
- [ ] D. AL = 100H, ZF = 0, CF = 1

> **Explanation**: `0FFH + 1 = 100H`. In an 8-bit register, the byte wraps to `00H`, setting `ZF = 1`. Crucially, `INC` does **not** modify `CF`.

---

#### Question 18
**What happens if you execute 8-bit division (`DIV BL`) without clearing AH when AH contains 02h and AL contains 08h?**
- [ ] A. It computes $8 \div BL$ correctly
- [x] B. It divides 0208H (520 decimal) by BL, which may cause a Divide Error Fault (#DE) *(Correct)*
- [ ] C. It ignores AH and only divides AL
- [ ] D. It sets AL to 0

> **Explanation**: 8-bit division strictly divides the full 16-bit register `AX`. With `AH = 02H` and `AL = 08H`, the dividend is `0208H` ($520_{10}$). If $BL = 2$, quotient is $260$, which exceeds 8 bits ($> 255$), immediately crashing the CPU with `#DE`.

---

#### Question 19
**Which instruction computes the two's complement of AL (negates the value)?**
- [ ] A. `NOT AL`
- [x] B. `NEG AL` *(Correct)*
- [ ] C. `SUB AL, 0`
- [ ] D. `XOR AL, 0FFH`

> **Explanation**: `NOT AL` computes the one's complement (bit inversion). `NEG AL` computes two's complement ($0 - AL$), effectively multiplying by $-1$.

---

#### Question 20
**What is the result in AL and CF after executing the following instructions?**
```assembly
MOV AL, 00H
NEG AL
```
- [ ] A. AL = 00H, CF = 1
- [x] B. AL = 00H, CF = 0 *(Correct)*
- [ ] C. AL = 0FFH, CF = 1
- [ ] D. AL = 01H, CF = 0

> **Explanation**: `NEG` calculates $0 - AL$. For $AL = 0$, $0 - 0 = 0$. `NEG` sets `CF = 0` when the operand is zero, and `CF = 1` for any non-zero operand.

---

#### Question 21
**What is the value in AL after converting ASCII character `'7'` into decimal integer 7?**
```assembly
MOV AL, '7'
SUB AL, 30H
```
- [ ] A. AL = 55
- [ ] B. AL = '0'
- [x] C. AL = 07H *(Correct)*
- [ ] D. AL = 37H

> **Explanation**: ASCII `'7'` is `37H` ($55_{10}$). Subtracting `30H` ($48_{10}$) yields integer `07H`.

---

#### Question 22
**What instruction performs addition including the incoming carry from a previous operation?**
- [ ] A. ADD
- [x] B. ADC *(Correct)*
- [ ] C. INC
- [ ] D. DAA

> **Explanation**: `ADC dest, src` computes $dest + src + CF$.

---

#### Question 23
**When executing `MUL BX` on a 16-bit operand, where is the 32-bit product stored?**
- [ ] A. EAX
- [ ] B. AX:BX
- [x] C. DX:AX (DX holds high word, AX holds low word) *(Correct)*
- [ ] D. BX:AX

> **Explanation**: In 16-bit multiplication, `AX * BX` produces a 32-bit result placed across `DX` (high 16 bits) and `AX` (low 16 bits).

---

#### Question 24
**What will be the value of AL after the following operations?**
```assembly
MOV AL, 5
ADD AL, 3
SUB AL, 2
```
- [ ] A. 8
- [x] B. 6 *(Correct)*
- [ ] C. 4
- [ ] D. 10

> **Explanation**: $5 + 3 = 8$; $8 - 2 = 6$.

---

#### Question 25
**The instruction `DEC CX` affects the Carry Flag (CF).**
- [ ] True
- [x] False *(Correct)*

> **Explanation**: Like `INC`, `DEC` does not touch `CF`.

---

### Category C: Bitwise AND, OR, XOR, Shift & Rotate (Q26–Q40)

#### Question 26
**What will be the value in AL after executing the following instructions?**
```assembly
MOV AL, 00000101B
SHL AL, 1
```
- [x] A. 00001010B (0AH) *(Correct)*
- [ ] B. 00010100B
- [ ] C. 00000010B
- [ ] D. 00000100B

> **Explanation**: `SHL` shifts all bits to the left by 1 position. The bit pattern `0000 0101` shifted left becomes `0000 1010` (decimal $5 \times 2 = 10$).

---

#### Question 27
**What will be the value in AL after executing the following operation?**
```assembly
MOV AL, 00001000B
SHR AL, 1
```
- [ ] A. 00010000B
- [x] B. 00000100B (04H) *(Correct)*
- [ ] C. 00000010B
- [ ] D. 00001001B

> **Explanation**: `SHR` shifts all bits to the right by 1 position, injecting a 0 at the MSB. `0000 1000` ($8_{10}$) becomes `0000 0100` ($4_{10}$).

---

#### Question 28
**Shift operations preserve all bits by wrapping them around back into the register.**
- [ ] True
- [x] False *(Correct)*

> **Explanation**: Shift operations (`SHL`, `SHR`) drop bits into the Carry Flag and replace them with zeroes (bits are lost). Rotate instructions (`ROL`, `ROR`) preserve all bits by circulating them around.

---

#### Question 29
**Which instruction rotates the bits of AL to the left circularly so that Bit 7 wraps around into Bit 0?**
- [ ] A. SHL AL, 1
- [x] B. ROL AL, 1 *(Correct)*
- [ ] C. RCL AL, 1
- [ ] D. SAL AL, 1

> **Explanation**: `ROL` (Rotate Left) wraps the outgoing MSB directly back into the LSB, while also copying it into `CF`.

---

#### Question 30
**What is the valid 8086 syntax to shift register AL to the right by 4 bit positions?**
- [ ] A. `SHR AL, 4`
- [ ] B. `SHR AL, 4H`
- [x] C. `MOV CL, 4` followed by `SHR AL, CL` *(Correct)*
- [ ] D. `SHR 4, AL`

> **Explanation**: On original 8086 silicon, multi-bit shifts can only use the count stored in register **`CL`**.

---

#### Question 31
**What will be the value of AL after the following operation?**
```assembly
MOV AL, 0F0H
AND AL, 0AAH
```
- [ ] A. 0FFH
- [x] B. 0A0H *(Correct)*
- [ ] C. 05AH
- [ ] D. 000H

> **Explanation**:
> `0F0H = 1111 0000B`
> `0AAH = 1010 1010B`
> Bitwise AND: `1010 0000B = 0A0H`.

---

#### Question 32
**Which instruction clears register AL to zero while setting the Zero Flag (ZF = 1)?**
- [ ] A. `MOV AL, 0`
- [x] B. `XOR AL, AL` *(Correct)*
- [ ] C. `AND AL, 0FFH`
- [ ] D. `NOT AL`

> **Explanation**: `XOR AL, AL` yields 0, requires only 2 bytes of opcode, executes faster, and updates flags (`ZF = 1`). `MOV AL, 0` does not touch flags.

---

#### Question 33
**What is the effect of executing `XOR AL, 20H` on an ASCII character stored in AL?**
- [ ] A. Converts digits to hex
- [ ] B. Multiplies the character by 32
- [x] C. Inverts character case (Uppercase $\leftrightarrow$ Lowercase) *(Correct)*
- [ ] D. Clears the character

> **Explanation**: ASCII letters differ solely at Bit 5 ($2^5 = 32 = 20\text{H}$). XORing with `20H` toggles Bit 5, turning `'A'` (`41H`) into `'a'` (`61H`) and vice versa.

---

#### Question 34
**What will be the value in AL and the Carry Flag (CF) after executing:**
```assembly
MOV AL, 10000001B
ROL AL, 1
```
- [ ] A. AL = 00000010B, CF = 0
- [x] B. AL = 00000011B, CF = 1 *(Correct)*
- [ ] C. AL = 00000010B, CF = 1
- [ ] D. AL = 10000010B, CF = 0

> **Explanation**: In `1000 0001B`, the MSB is `1` and LSB is `1`. Rotating left shifts Bit 0 to Bit 1, and wraps the MSB (`1`) into both Bit 0 and `CF`. Result: `0000 0011B` (`03H`), `CF = 1`.

---

#### Question 35
**What is the difference between `SHR AL, 1` and `SAR AL, 1` when AL contains 10000000B (-128 decimal)?**
- [ ] A. `SHR` produces `11000000B`; `SAR` produces `01000000B`
- [x] B. `SHR` produces `01000000B` (+64); `SAR` produces `11000000B` (-64) *(Correct)*
- [ ] C. Both produce identical results
- [ ] D. `SAR` produces an overflow fault

> **Explanation**: `SHR` inserts `0` into the MSB (treating data as unsigned). `SAR` replicates the sign bit (Bit 7 = `1`), preserving negative sign in two's complement.

---

#### Question 36
**Which instruction tests whether the least significant bit (Bit 0) of AL is 1 without modifying AL?**
- [ ] A. `AND AL, 01H`
- [x] B. `TEST AL, 01H` *(Correct)*
- [ ] C. `OR AL, 01H`
- [ ] D. `CMP AL, 01H`

> **Explanation**: `TEST` performs bitwise AND and updates `ZF`, but does not alter the destination operand. If Bit 0 is 0, `ZF = 1`; if Bit 0 is 1, `ZF = 0`.

---

#### Question 37
**Executing `NOT AL` modifies which of the following CPU status flags?**
- [ ] A. ZF and SF
- [ ] B. CF and OF
- [ ] C. All flags
- [x] D. None of the flags *(Correct)*

> **Explanation**: `NOT` is an exception in the 8086 ALU: it performs a one's complement inversion without changing any flags.

---

#### Question 38
**To mask (extract) only the lower 4 bits (lower nibble) of register BL, which instruction is used?**
- [ ] A. `SHR BL, 4`
- [x] B. `AND BL, 0FH` *(Correct)*
- [ ] C. `OR BL, 0FH`
- [ ] D. `XOR BL, 0F0H`

> **Explanation**: `AND BL, 0FH` performs bitwise AND with `0000 1111B`, preserving bits 0–3 and setting bits 4–7 to 0.

---

#### Question 39
**What is the state of the Carry Flag after executing:**
```assembly
MOV AL, 00000101B
ROR AL, 1
```
- [x] A. CF = 1 *(Correct)*
- [ ] B. CF = 0
- [ ] C. CF is unchanged
- [ ] D. Undefined

> **Explanation**: `ROR` rotates right. The outgoing LSB is `1`, which is placed into `CF` as well as MSB.

---

#### Question 40
**What instruction turns character 'b' into uppercase 'B' by clearing Bit 5?**
- [ ] A. `OR AL, 20H`
- [x] B. `AND AL, 0DFH` *(Correct)*
- [ ] C. `XOR AL, 20H`
- [ ] D. `NOT AL`

> **Explanation**: `0DFH = 1101 1111B`. Bitwise AND with `0DFH` forces Bit 5 to `0` while preserving all other bits.

---

### Category D: Comparisons, Jump Conditions & Loops (Q41–Q55)

#### Question 41
**`JMP` is a conditional jump instruction.**
- [ ] True
- [x] False *(Correct)*

> **Explanation**: `JMP` is an **unconditional** jump; it alters `IP` regardless of flag states.

---

#### Question 42
**Which of the following is a valid conditional jump instruction in 8086 Assembly?**
- [ ] A. MOVE
- [ ] B. JMPZ
- [x] C. JE *(Correct)*
- [ ] D. JUMP

> **Explanation**: `JE` (Jump if Equal) is a valid conditional jump instruction testing $ZF = 1$.

---

#### Question 43
**What will be the value of AX after executing this loop?**
```assembly
MOV AX, 0
MOV CX, 3
LOOP1:
    INC AX
    LOOP LOOP1
```
- [ ] A. AX = 1
- [ ] B. AX = 2
- [x] C. AX = 3 *(Correct)*
- [ ] D. AX = 0

> **Explanation**: Loop starts with $CX = 3$. Iteration 1: $AX = 1, CX = 2$. Iteration 2: $AX = 2, CX = 1$. Iteration 3: $AX = 3, CX = 0$ (loop terminates).

---

#### Question 44
**How many asterisks (`*`) will be printed by the following code?**
```assembly
    MOV CX, 4
TOP:
    MOV AH, 02H
    MOV DL, '*'
    INT 21H
    LOOP TOP
```
- [ ] A. 1
- [ ] B. 3
- [x] C. 4 (`****`) *(Correct)*
- [ ] D. Infinite

> **Explanation**: The loop initializes `CX = 4` and iterates exactly 4 times, printing 4 asterisks.

---

#### Question 45
**What happens to the CX register during each execution of the LOOP instruction?**
- [ ] A. It increases by 1
- [x] B. It decreases by 1 *(Correct)*
- [ ] C. It becomes 0 immediately
- [ ] D. It remains unchanged

> **Explanation**: `LOOP` automatically decrements `CX` by 1 before checking if $CX == 0$.

---

#### Question 46
**Which flag condition causes the instruction `JE` (Jump if Equal) to branch?**
- [x] A. ZF = 1 *(Correct)*
- [ ] B. ZF = 0
- [ ] C. CF = 1
- [ ] D. SF = 1

> **Explanation**: `JE` (and its alias `JZ`) branches when the Zero Flag is set ($ZF = 1$).

---

#### Question 47
**After executing `CMP AL, BL`, which conditional jump should be used to test if unsigned AL is strictly greater than unsigned BL?**
- [ ] A. JG
- [x] B. JA *(Correct)*
- [ ] C. JGE
- [ ] D. JAE

> **Explanation**: For unsigned numbers, `JA` (Jump if Above) is used ($CF = 0$ and $ZF = 0$). `JG` is strictly for signed quantities.

---

#### Question 48
**What does the `CMP AL, BL` instruction do internally?**
- [ ] A. Divides AL by BL
- [x] B. Subtracts BL from AL internally and updates flags without altering AL *(Correct)*
- [ ] C. Stores AL - BL into AL
- [ ] D. Clears AL if equal to BL

> **Explanation**: `CMP dest, src` executes $dest - src$ to update status flags, discarding the result.

---

#### Question 49
**What will be the value of AL after the following code runs?**
```assembly
MOV AL, 10
MOV BL, 10
CMP AL, BL
JE EQUAL_LABEL
MOV AL, 99
JMP DONE
EQUAL_LABEL:
MOV AL, 42
DONE:
```
- [ ] A. AL = 10
- [x] B. AL = 42 *(Correct)*
- [ ] C. AL = 99
- [ ] D. AL = 0

> **Explanation**: Since $10 == 10$, $AL - BL = 0$, setting $ZF = 1$. `JE EQUAL_LABEL` branches to `EQUAL_LABEL`, which loads `AL = 42`.

---

#### Question 50
**Which pair of conditional jump mnemonics represent the exact same machine opcode?**
- [ ] A. JA and JG
- [ ] B. JB and JL
- [x] C. JE and JZ *(Correct)*
- [ ] D. JNE and JE

> **Explanation**: `JE` and `JZ` both test $ZF = 1$ and assemble to the exact same opcode (`74H`). Similarly, `JB`, `JC`, and `JNAE` share opcode `72H`.

---

#### Question 51
**If CX is initialized to 0000H before executing `MY_LOOP: ... LOOP MY_LOOP`, how many times will the loop execute?**
- [ ] A. 0 times
- [ ] B. 1 time
- [x] C. 65,536 times *(Correct)*
- [ ] D. 256 times

> **Explanation**: In the first iteration, `LOOP` decrements `CX` from `0000H` to `0FFFFH` ($65,535_{10}$). Since $CX \ne 0$, it repeats through all 65,535 values down to 0, running $65,536$ times.

---

#### Question 52
**Which instruction should be placed before a loop to safely bypass it if CX is already zero?**
- [ ] A. `JZ exit`
- [ ] B. `JC exit`
- [x] C. `JCXZ exit` *(Correct)*
- [ ] D. `JMP exit`

> **Explanation**: `JCXZ` (Jump if CX is Zero) tests register `CX` directly without evaluating flags, jumping if $CX == 0$.

---

#### Question 53
**After `CMP AL, 5`, if AL is 3, what is the state of the Carry Flag (CF)?**
- [x] A. CF = 1 (because an unsigned borrow occurred: 3 < 5) *(Correct)*
- [ ] B. CF = 0
- [ ] C. CF is unchanged
- [ ] D. Undefined

> **Explanation**: $3 - 5$ produces an unsigned borrow, so $CF = 1$. This triggers the `JB` (Jump if Below) condition.

---

#### Question 54
**Which jump tests for signed numbers being strictly less than?**
- [ ] A. JB
- [ ] B. JNA
- [x] C. JL *(Correct)*
- [ ] D. JBE

> **Explanation**: `JL` (Jump if Less) checks if $SF \ne OF$, testing signed relational less-than.

---

#### Question 55
**Does the LOOP instruction modify CPU status flags?**
- [ ] True
- [x] False *(Correct)*

> **Explanation**: `LOOP` does **not** modify any condition flags in the `FLAGS` register.

---

### Category E: Complex Code Output Prediction Challenges (Q56–Q65)

#### Question 56
**What is the output displayed on the console screen by this code snippet?**
```assembly
    MOV AH, 02H
    MOV DL, '0'
    ADD DL, 5
    INT 21H
```
- [ ] A. 0
- [ ] B. 53
- [x] C. 5 *(Correct)*
- [ ] D. 8

> **Explanation**: ASCII `'0'` has value 48 ($30\text{H}$). Adding 5 gives $48 + 5 = 53$ ($35\text{H}$), which is the ASCII character `'5'`. `INT 21H, AH=02H` displays `'5'`.

---

#### Question 57
**What will be printed by the following code?**
```assembly
    MOV AL, 65      ; ASCII for 'A'
    XOR AL, 20H
    MOV DL, AL
    MOV AH, 02H
    INT 21H
```
- [ ] A. A
- [x] B. a *(Correct)*
- [ ] C. @
- [ ] D. Garbage

> **Explanation**: `65 = 41H = 'A'`. XORing with `20H` inverts Bit 5, yielding `61H = 97 = 'a'`.

---

#### Question 58
**What is the value in AL after execution?**
```assembly
    MOV AL, 12H     ; 0001 0010B
    MOV CL, 4
    ROL AL, CL
```
- [ ] A. 12H
- [x] B. 21H *(Correct)*
- [ ] C. 02H
- [ ] D. 00H

> **Explanation**: Rotating an 8-bit register by 4 positions swaps its two nibbles. `12H` becomes `21H`.

---

#### Question 59
**What is the value in AX after execution?**
```assembly
    MOV AX, 10
    MOV BX, 2
    MUL BX
    MOV CX, 4
    DIV CX
```
- [ ] A. AX = 0
- [x] B. AX = 0005H *(Correct)*
- [ ] C. AX = 0014H
- [ ] D. AX = 0002H

> **Explanation**:
> 1. `MUL BX`: $10 \times 2 = 20$, stored in `AX` (and `DX=0`).
> 2. `DIV CX`: $DX:AX \div 4 \implies 20 \div 4 = 5$, stored in quotient register `AX`. Remainder $0$ in `DX`.

---

#### Question 60
**What will be printed to screen?**
```assembly
.DATA
    MSG DB 'HELLO', '$', 'WORLD', '$'
.CODE
    MOV AX, @DATA
    MOV DS, AX
    LEA DX, MSG
    MOV AH, 09H
    INT 21H
```
- [x] A. HELLO *(Correct)*
- [ ] B. HELLOWORLD
- [ ] C. HELLO$WORLD$
- [ ] D. WORLD

> **Explanation**: DOS Service 09h terminates display at the **first** `$` sign encountered. Only `'HELLO'` is output.

---

#### Question 61
**What is the value in BL after executing the following loop?**
```assembly
    MOV CX, 5
    MOV BL, 0
SUM_LOOP:
    ADD BL, 2
    LOOP SUM_LOOP
```
- [ ] A. 5
- [ ] B. 8
- [x] C. 10 *(Correct)*
- [ ] D. 12

> **Explanation**: The loop executes 5 times. In each iteration, `BL` increases by 2. Total $= 5 \times 2 = 10$.

---

#### Question 62
**What will be the final value of AL?**
```assembly
    MOV AL, 10011000B
    SHR AL, 1
    SHL AL, 1
```
- [ ] A. 10011000B
- [x] B. 00011000B *(Correct)*
- [ ] C. 10011001B
- [ ] D. 00000000B

> **Explanation**:
> 1. Initial: `1001 1000B`.
> 2. `SHR AL, 1`: Shifts right, MSB becomes `0`. Result = `0100 1100B`.
> 3. `SHL AL, 1`: Shifts left, LSB becomes `0`. Result = `1001 1000`? Wait! Look closely:
> `0100 1100B` shifted left is `1001 1000B`!
> Wait, let's re-trace carefully!
> `1001 1000B`:
> Bits: b7=1, b6=0, b5=0, b4=1, b3=1, b2=0, b1=0, b0=0.
> `SHR AL, 1`:
> b7=0, b6=1, b5=0, b4=0, b3=1, b2=1, b1=0, b0=0. (Value: `0100 1100B`). Outgoing bit was 0.
> `SHL AL, 1`:
> b7=1, b6=0, b5=0, b4=1, b3=1, b2=0, b1=0, b0=0. (Value: `1001 1000B`).
> What if the initial bit 0 was 1? E.g. `1001 1001B`? Then bit 0 would be lost! But here bit 0 is 0, and bit 7 shifted into b6 and back to b7!
> Let's make this snippet test a real bit loss so the distractor is sharp:
> Let initial AL be `10000001B`.
> `SHR AL, 1` $\rightarrow$ `01000000B` (bit 0 lost into CF).
> `SHL AL, 1` $\rightarrow$ `10000000B` (empty LSB filled with 0).
> Result: `10000000B` (80H).

Let's present that clean code snippet:
```assembly
    MOV AL, 10000001B
    SHR AL, 1
    SHL AL, 1
```
- [ ] A. 10000001B
- [x] B. 10000000B (80H) *(Correct)*
- [ ] C. 00000001B
- [ ] D. 00000000B

> **Explanation**: `SHR AL, 1` shifts Bit 0 (`1`) into `CF`, leaving `0100 0000B`. `SHL AL, 1` shifts it left, filling Bit 0 with `0`, producing `1000 0000B`. The original LSB is permanently lost.

---

#### Question 63
**What will be printed to the screen by this code?**
```assembly
    MOV AL, 7
    MOV BL, 2
    DIV BL
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
```
- [x] A. 3 *(Correct)*
- [ ] B. 1
- [ ] C. 7
- [ ] D. 3.5

> **Explanation**: $7 \div 2$ gives quotient 3 in `AL` and remainder 1 in `AH`. Adding `'0'` (`48`) to `AL` gives ASCII `'3'`. `INT 21H, AH=02H` outputs `'3'`.

---

#### Question 64
**What will be the value in AL after the following sequence?**
```assembly
    MOV AL, 05H
    MOV BL, 05H
    SUB AL, BL
    JNZ SKIP
    ADD AL, 10
SKIP:
```
- [ ] A. 0
- [ ] B. 5
- [x] C. 10 *(Correct)*
- [ ] D. 15

> **Explanation**: `SUB AL, BL` gives $5 - 5 = 0$, setting the Zero Flag ($ZF = 1$). `JNZ` (Jump if Not Zero) checks if $ZF = 0$. Since $ZF = 1$, the jump is **not** taken. Execution falls through to `ADD AL, 10`, setting $AL = 0 + 10 = 10$.

---

#### Question 65
**Given array `arr DB 10, 20, 30, 40`, what value is in AL after executing:**
```assembly
    LEA SI, arr
    INC SI
    MOV AL, [SI]
```
- [ ] A. 10
- [x] B. 20 *(Correct)*
- [ ] C. 30
- [ ] D. 40

> **Explanation**: `arr` is an array of byte elements (`DB`). `LEA SI, arr` points to index 0 (value 10). `INC SI` advances the pointer by 1 byte to index 1 (value 20). `MOV AL, [SI]` loads 20 into `AL`.

---

## 6. Summary Checklist for the Exam

Before submitting your quiz on Socrative, verify each answer against these golden rules:

| Topic | Check | Rule to Verify |
| :--- | :--- | :--- |
| **Shift / Rotate Count** | Immediate $> 1$? | Must be in `CL`! Immediate $> 1$ is rejected on 8086. |
| **Division** | Is `AH` cleared? | 8-bit `DIV` divides full `AX` ($\text{AL}=\text{quotient}$, $\text{AH}=\text{remainder}$). |
| **Multiplication** | Destination register? | 8-bit `MUL` writes to full `AX`; 16-bit `MUL` writes to `DX:AX`. |
| **`INC` / `DEC`** | Carry flag asked? | `INC` and `DEC` **never** touch `CF`. |
| **Comparisons** | Unsigned vs Signed? | Unsigned: `JA`, `JB`, `CF`. Signed: `JG`, `JL`, `SF/OF`. |
| **Loop Counter** | Register used? | Always `CX`. Decrements automatically; does NOT alter flags. |
| **Case Conversion** | Mask value? | `20H` (`32d`) toggles bit 5. `XOR AL, 20H` swaps case. |
| **DOS Strings** | Terminator? | Must end with `$` for `AH=09H`. |
| **Segments** | Direct `MOV`? | Cannot move immediate directly into `DS` (`MOV DS, @DATA` is illegal). |
| **Code Traces** | Hex vs Decimal? | Check if numbers are decimal ($10$) or hex ($10\text{H} = 16$). |

