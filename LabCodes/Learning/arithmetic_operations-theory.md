# String Output Mechanics and Address Loading (arithmetic_operations.asm)

In 8086 assembly programming, printing text prompts to the console requires interacting with the MS-DOS operating system through Software Interrupt `21h` (Service `09h`).

This document explains the mechanics of lines 48–50 in [`arithmetic_operations.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/arithmetic_operations.asm), detailing how `LEA` loads memory pointers, how DOS Service `09h` interprets `$`-terminated strings, and how `LEA DX` compares to `MOV DX, OFFSET`.

---

## Table of Contents

1. [Overview of Lines 48–50](#1-overview-of-lines-4850)
2. [Instruction Breakdown](#2-instruction-breakdown)
   - [2.1 `LEA DX, prompt_op1` (Load Effective Address)](#21-lea-dx-prompt_op1-load-effective-address)
   - [2.2 `MOV AH, 09h` (DOS String Output Service)](#22-mov-ah-09h-dos-string-output-service)
   - [2.3 `INT 21h` (Executing the Software Interrupt)](#23-int-21h-executing-the-software-interrupt)
3. [The Contract of DOS Service 09h (`$` Termination)](#3-the-contract-of-dos-service-09h--termination)
4. [Comparative Analysis: `LEA DX, var` vs. `MOV DX, OFFSET var`](#4-comparative-analysis-lea-dx-var-vs-mov-dx-offset-var)
5. [Complete Architectural Memory Trace](#5-complete-architectural-memory-trace)
6. [Key Takeaways](#6-key-takeaways)

---

## 1. Overview of Lines 48–50

In [`arithmetic_operations.asm#L48-L50`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/arithmetic_operations.asm#L48-L50):

```assembly
48:     lea dx, prompt_op1          ; Alternative: LEA instead of MOV DX, OFFSET
49:     mov ah, 09h
50:     int 21h
```

This 3-instruction block prints the user prompt string defined in the `.data` segment:
```assembly
16:     prompt_op1 db 'Enter first single digit (0-9): $'
```
onto the console screen.

---

## 2. Instruction Breakdown

### 2.1 `LEA DX, prompt_op1` (Load Effective Address)
- **What it does**: Calculates the memory **offset address** where `prompt_op1` begins inside the data segment and places that 16-bit number into register `DX`.
- **Crucial Distinction**: It does **not** load the letters `'E'`, `'n'`, `'t'`, `'e'`, `'r'`. It loads the **pointer (address)** to the first letter `'E'`.
- In C/C++, this is equivalent to passing a pointer:
  ```c
  const char* dx = &prompt_op1[0];
  ```

---

### 2.2 `MOV AH, 09h` (DOS String Output Service)
- Staging register `AH` with the **Service Function Number `09h`**.
- In MS-DOS calling conventions:
  - `AH = 01h`: Read single character from keyboard.
  - `AH = 02h`: Print single character from `DL`.
  - `AH = 09h`: **Print string from memory pointed to by `DS:DX`**.
  - `AH = 4Ch`: Terminate process.

---

### 2.3 `INT 21h` (Executing the Software Interrupt)
- Triggers software interrupt vector `21h`.
- The CPU switches to the MS-DOS kernel Interrupt Service Routine (ISR).
- DOS inspects `AH` (sees `09h`), retrieves the base address from `DS:DX`, and reads memory byte-by-byte, sending each character to the active display until it hits the **`$`** delimiter.
- Control returns to the next instruction (line 52).

```
+-------------------------------------------------------------------------------+
|                       DOS SERVICE 09H EXECUTION FLOW                          |
+-------------------------------------------------------------------------------+
| 1. LEA DX, prompt_op1  --> DX = 0000h (Offset of 'Enter first...')            |
| 2. MOV AH, 09h         --> AH = 09h   (DOS Print String Service)              |
| 3. INT 21h             --> CPU triggers DOS Kernel                            |
|                            DOS reads DS:[DX] -> 'E', 'n', 't', 'e', 'r'...    |
|                            Loops and prints until encountering '$'            |
|                            Halts print, restores CPU state, returns           |
+-------------------------------------------------------------------------------+
```

---

## 3. The Contract of DOS Service 09h (`$` Termination)

DOS Service `09h` relies on a strict contract:
1. **The String MUST End with `$` (ASCII `24h` / `36d`)**:
   - In high-level languages like C, strings are null-terminated (`\0`).
   - In DOS assembly, strings are **dollar-sign terminated (`$`)**.
   - DOS does not know the length of your string in advance; it keeps printing characters sequentially until it encounters `'$'`.
2. **What Happens if `$` is Missing?**:
   - DOS will not stop at the end of your string. It will keep reading adjacent variables and random RAM bytes, printing garbage characters, until it happens to encounter a random byte containing `24h` (`$`) or crashes.

---

## 4. Comparative Analysis: `LEA DX, var` vs. `MOV DX, OFFSET var`

Line 48 includes the comment: `; Alternative: LEA instead of MOV DX, OFFSET`.

Both instructions achieve the identical runtime result for static variables:

```assembly
lea dx, prompt_op1          ; CPU Instruction: Load Effective Address
mov dx, offset prompt_op1   ; Assembler Directive: Move immediate offset
```

### Detailed Comparison Table

| Attribute | `MOV DX, OFFSET prompt_op1` | `LEA DX, prompt_op1` |
| :--- | :--- | :--- |
| **Type** | **Assembler Directive / Immediate Move** | **CPU Hardware Instruction** |
| **Address Calculation Time** | **Compile Time** (Calculated by MASM/emu8086) | **Runtime** (Calculated by CPU Execution Unit) |
| **Instruction Length** | **3 Bytes** (`BA xx xx`) | **4 Bytes** (`8D 16 xx xx`) |
| **Clock Cycles (8086)** | **4 Cycles** (Fastest) | **8 Cycles** (Slightly slower) |
| **Dynamic Addressing?** | **No** (Cannot do `OFFSET [bx+si]`) | **Yes** (Can do `LEA DX, [bx+si+4]`) |
| **Arithmetic Ability** | None | Can do math without modifying flags (`LEA AX, [BX+5]`) |

> [!TIP]
> For simple, static string labels like `prompt_op1`, `MOV DX, OFFSET` is conventionally preferred in production code because it is 1 byte smaller and 2× faster. However, in lab assignments and exams, instructors frequently test `LEA` to assess understanding of the Execution Unit's address generation hardware.

---

## 5. Complete Architectural Memory Trace

```
Data Segment (DS = 0710h):
+---------------+-------+---------------------------------------+
| Offset (Hex)  | Byte  | Representation                        |
+---------------+-------+---------------------------------------+
| DS:0000       | 45h   | 'E'  <-- DX points here after LEA DX  |
| DS:0001       | 6Eh   | 'n'                                   |
| DS:0002       | 74h   | 't'                                   |
| ...           | ...   | ...                                   |
| DS:001F       | 3Ah   | ':'                                   |
| DS:0020       | 20h   | ' '                                   |
| DS:0021       | 24h   | '$'  <-- DOS stops printing here      |
+---------------+-------+---------------------------------------+
```

---

## 6. Key Takeaways

1. **`LEA DX, string`** loads the memory offset address of the string, not its content.
2. **`MOV AH, 09h`** selects the DOS print string service.
3. **`INT 21h`** executes the display service, printing every character until reaching the mandatory `$` sentinel.
4. **`LEA DX, prompt_op1`** and **`MOV DX, OFFSET prompt_op1`** are functionally interchangeable for static strings, with `MOV OFFSET` resolved at compile time and `LEA` evaluated at runtime.
