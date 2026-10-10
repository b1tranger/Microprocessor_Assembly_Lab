# Post-Mortem Debugging: Register Overwrite, Malformed CMP, and Unreachable Instruction Traps (3value_Semim.asm)

In low-level assembly programming, the programmer directly manages register allocations and execution control flow without a compiler safety net. Minor oversights—such as reusing a register prematurely or placing a jump before an interrupt call—lead to catastrophic system failure. This document presents a comprehensive forensic analysis of [`3value_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/3value_Semim.asm), explaining each bug, tracing CPU register states under flawed logic, and presenting a correct implementation.

---

## Table of Contents

1. [Overview & Program Intent](#1-overview--program-intent)
2. [Forensic Breakdown of Critical Bugs](#2-forensic-breakdown-of-critical-bugs)
   - [Bug 1: Register Overwrite & Data Loss (`mov bl, al` for Both A and C)](#bug-1-register-overwrite--data-loss-mov-bl-al-for-both-a-and-c)
   - [Bug 2: Comparing with Uninitialized Register (`cmp bl, cl`)](#bug-2-comparing-with-uninitialized-register-cmp-bl-cl)
   - [Bug 3: Illegal Syntax with Missing Operand (`cmp bl`)](#bug-3-illegal-syntax-with-missing-operand-cmp-bl)
   - [Bug 4: Misplaced Branch Before Interrupt (`jmp` Preempting `INT 21h`)](#bug-4-misplaced-branch-before-interrupt-jmp-preempting-int-21h)
   - [Bug 5: Dead Code and Unreachable Instructions](#bug-5-dead-code-and-unreachable-instructions)
3. [Step-by-Step Execution Trace of the Flawed Code](#3-step-by-step-execution-trace-of-the-flawed-code)
4. [8086 Register Allocation Principles for $\ge 3$ Variables](#4-8086-register-allocation-principles-for-ge-3-variables)
   - [General-Purpose Byte Register Partitioning](#general-purpose-byte-register-partitioning)
   - [Preserving Registers During DOS Interrupts (`AX` Clobbering)](#preserving-registers-during-dos-interrupts-ax-clobbering)
5. [Comparative Bug Table](#5-comparative-bug-table)
6. [Fully Corrected and Refactored Assembly Implementation](#6-fully-corrected-and-refactored-assembly-implementation)

---

## 1. Overview & Program Intent

[`3value_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/3value_Semim.asm) attempts to accept three characters from the user ($A, B, C$), compare them, and output which of the three is largest or declare that all are equal:
- `a db 'A is Bigger then B,C!$'`
- `b db 'B is Bigger then A,C!$'`
- `c db 'C is Bigger then A,B!$'`
- `d db 'Both are Equal!$'`

However, due to multiple severe architectural errors, the file fails to assemble in standard assemblers and produces erratic behavior in emulators.

---

## 2. Forensic Breakdown of Critical Bugs

### Bug 1: Register Overwrite & Data Loss (`mov bl, al` for Both A and C)

Observe the sequence of inputs in lines 23–57 of [`3value_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/3value_Semim.asm#L23-L57):

```assembly
; --- Reading Input A ---
mov ah, 1
int 21h
mov bl, al              ; Input A is stored into BL (Line 25)

; --- Reading Input B ---
mov ah, 1
int 21h
mov bh, al              ; Input B is stored into BH (Line 40)

; --- Reading Input C ---
mov ah, 1
int 21h
mov bl, al              ; Clobbers BL! Overwrites Input A! (Line 56)
```

> [!CAUTION]
> **Data Destruction**:
> Storing Input $C$ into `BL` completely erases Input $A$!
> - `BL` no longer holds $A$; it now holds $C$.
> - `BH` holds $B$.
> - Input $A$ is permanently lost from the CPU registers.

When line 68 executes:
```assembly
cmp bl, bh
```
the programmer intended to compare $A$ with $B$. In reality, the CPU is comparing $C$ with $B$!

---

### Bug 2: Comparing with Uninitialized Register (`cmp bl, cl`)

In [`3value_Semim.asm#L75`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/3value_Semim.asm#L75):
```assembly
cmp bl, cl
jg  b_is_big
jl  c_is_big
je  both_are_equal
```

- Register `CL` was **never assigned any value** throughout the entire program.
- In the 8086 architecture, uninitialized registers contain arbitrary values left behind by the BIOS, DOS kernel, or prior instructions.
- The outcome of `cmp bl, cl` is completely non-deterministic and will produce random, unrepeatable jump behavior.

---

### Bug 3: Illegal Syntax with Missing Operand (`cmp bl`)

Examine line 83 in [`3value_Semim.asm#L80-L87`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/3value_Semim.asm#L80-L87):

```assembly
a_is_big:
    mov ah, 9
    lea dx, a
    cmp bl              ; SYNTAX ERROR! Missing second operand!
    jmp b_is_big
    jmp c_is_big
    int 21h
    jmp exit
```

> [!WARNING]
> **Assembler Crash / Syntax Error**:
> The `CMP` instruction is strictly a **binary operation**:
> $$\text{CMP destination, source}$$
> It requires exactly two operands (e.g., `cmp bl, bh` or `cmp bl, 5`).
> An instruction with only one operand (`cmp bl`) is illegal in 8086 assembly.
> 
> Assemblers (MASM, TASM, EMU8086) reject this line with:
> `Error: Wrong number of operands` or `Operand expected`.

---

### Bug 4: Misplaced Branch Before Interrupt (`jmp` Preempting `INT 21h`)

Even ignoring the syntax error in line 83, observe the control flow in lines 81–86:
```assembly
a_is_big:
    mov ah, 9           ; Prepares DOS String Print
    lea dx, a           ; Points DX to string 'A is Bigger...'
    jmp b_is_big        ; UNCONDITIONAL JUMP!
    jmp c_is_big        ; Dead code
    int 21h             ; NEVER EXECUTED!
    jmp exit
```

- In assembly, instructions execute sequentially unless redirected by a jump.
- `jmp b_is_big` transfers control immediately to label `b_is_big`:
  ```assembly
  b_is_big:
      mov ah, 9
      lea dx, b         ; Overwrites DX with string 'B is Bigger...'
      int 21h           ; Prints B!
      jmp exit
  ```
- Because `int 21h` in `a_is_big` was positioned **after** `jmp b_is_big`, the string `a` is **never printed** under any circumstances! Instead, the program redirects to `b_is_big` and prints string `b`.

---

### Bug 5: Dead Code and Unreachable Instructions

In lines 84–86:
```assembly
    jmp b_is_big
    jmp c_is_big        ; UNREACHABLE
    int 21h             ; UNREACHABLE
```
- Because `jmp b_is_big` unconditionally redirects the Instruction Pointer (`IP`), lines 85 and 86 can **never be reached by the CPU**.
- Two consecutive unconditional jumps (`jmp b_is_big` followed by `jmp c_is_big`) is an unmistakable structural bug.

---

## 3. Step-by-Step Execution Trace of the Flawed Code

Assuming the syntax error `cmp bl` was temporarily bypassed, let us trace what happens with input: $A = 9$, $B = 1$, $C = 2$:

| Step | Instruction | State of Registers | Comment |
| :--- | :--- | :--- | :--- |
| 1 | `mov bl, al` (Input A = 9) | `BL = 39h` ('9') | A stored in `BL`. |
| 2 | `mov bh, al` (Input B = 1) | `BL = 39h`, `BH = 31h` ('1') | B stored in `BH`. |
| 3 | `mov bl, al` (Input C = 2) | `BL = 32h` ('2'), `BH = 31h` | **A destroyed!** `BL` now holds C ('2'). |
| 4 | `cmp bl, bh` | `BL = '2'`, `BH = '1'` | Compares C ('2') and B ('1'). |
| 5 | `jg a_is_big` | $\text{ZF}=0, \text{SF}=0$ | Jumps because $2 > 1$, but lands on `a_is_big`! |
| 6 | `lea dx, a` | `DX = offset a` | Prepares message A. |
| 7 | `jmp b_is_big` | `IP = offset b_is_big` | Immediately abandons message A! |
| 8 | `lea dx, b` | `DX = offset b` | Prepares message B. |
| 9 | `int 21h` | Displays: `"B is Bigger then A,C!"` | **Catastrophic Failure**: $B$ is the smallest ($1$), but reported as biggest! |

---

## 4. 8086 Register Allocation Principles for $\ge 3$ Variables

### General-Purpose Byte Register Partitioning

The 8086 provides four general-purpose 16-bit data registers, which can be split into eight 8-bit registers:
- `AX` $\rightarrow$ `AH`, `AL`
- `BX` $\rightarrow$ `BH`, `BL`
- `CX` $\rightarrow$ `CH`, `CL`
- `DX` $\rightarrow$ `DH`, `DL`

When handling three simultaneous input variables ($A, B, C$):
1. **`AX` is Volatile**: `INT 21h` modifies `AH` (function code) and `AL` (input return byte). It cannot be used for long-term storage of variables across DOS calls.
2. **`DX` is Volatile**: `INT 21h` uses `DX` for string pointers (`AH=09h`) or `DL` for character output (`AH=02h`).
3. **Safe Storage Registers**:
   - Store $A$ in **`BL`**
   - Store $B$ in **`BH`**
   - Store $C$ in **`CL`** (or **`CH`**)
4. **Memory Variables Alternative**:
   Declaring variables in the `.data` segment (`val_a db ?`, `val_b db ?`, `val_c db ?`) frees CPU registers from clutter and prevents clobbering.

---

## 5. Comparative Bug Table

| Location | Original Flawed Code | Root Cause | Consequence |
| :--- | :--- | :--- | :--- |
| **Line 56** | `mov bl, al` | Reusing `BL` for third input | Erases input $A$; $A$ is lost forever |
| **Line 75** | `cmp bl, cl` | `CL` was never loaded | Comparison with random garbage bits |
| **Line 83** | `cmp bl` | Missing second operand | Code fails to assemble (syntax error) |
| **Line 84** | `jmp b_is_big` (before `int 21h`) | Misplaced unconditional branch | Bypasses display of string $A$, prints string $B$ |
| **Line 85** | `jmp c_is_big` | Redundant second jump | Unreachable dead code |

---

## 6. Fully Corrected and Refactored Assembly Implementation

Below is the corrected, fully working version preserving Semim's logic while fixing register allocation, branch structures, and output sequencing:

```assembly
.model small
.stack 100h

.data 
    a_input db 'Enter the value of A: $'
    b_input db 10, 13, 'Enter the value of B: $' 
    c_input db 10, 13, 'Enter the value of C: $'

    msg_a   db 10, 13, 'A is Bigger than B,C!$'
    msg_b   db 10, 13, 'B is Bigger than A,C!$'
    msg_c   db 10, 13, 'C is Bigger than A,B!$'
    msg_eq  db 10, 13, 'Both/All are Equal!$'

    val_a   db ?
    val_b   db ?
    val_c   db ?

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Read A
    mov ah, 9
    lea dx, a_input
    int 21h
    mov ah, 1
    int 21h
    mov val_a, al

    ; Read B
    mov ah, 9
    lea dx, b_input
    int 21h
    mov ah, 1
    int 21h
    mov val_b, al

    ; Read C
    mov ah, 9
    lea dx, c_input
    int 21h
    mov ah, 1
    int 21h
    mov val_c, al

    ; Check if all three values are equal
    mov al, val_a
    cmp al, val_b
    jne compare_candidates
    cmp al, val_c
    jne compare_candidates
    
    ; All three are identical
    lea dx, msg_eq
    jmp print_result

compare_candidates:
    ; Load A and B into registers
    mov bl, val_a           ; BL = A
    mov bh, val_b           ; BH = B
    mov cl, val_c           ; CL = C

    cmp bl, bh
    ja  check_a_c           ; If A > B, check if A > C

    ; Here B >= A, check if B > C
    cmp bh, cl
    ja  b_is_big            ; If B > C, B is largest
    jmp c_is_big            ; Otherwise C is largest

check_a_c:
    cmp bl, cl
    ja  a_is_big            ; If A > C, A is largest
    jmp c_is_big            ; Otherwise C is largest

a_is_big:
    lea dx, msg_a
    jmp print_result

b_is_big:
    lea dx, msg_b
    jmp print_result

c_is_big:
    lea dx, msg_c

print_result:
    mov ah, 9
    int 21h

exit:
    mov ah, 4ch
    int 21h

main endp
end main
```
