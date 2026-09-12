# UITS Lab Test 01 (Autumn 2026): Preparation Summary & Code Walkthrough

This document provides a bullet-pointed architectural breakdown and comparison of the 8086 assembly implementations in [`LabCodes/Labtest/prep/CSE55-096/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096), directly mapped to the official **UITS Lab Test 01** examination requirements.

---

## Table of Contents
1. [Official Examination Task (UITS Lab Test 01)](#1-official-examination-task-uits-lab-test-01)
   - [1.1 Examination Metadata & Instructions](#11-examination-metadata--instructions)
   - [1.2 Questions & Mark Distribution](#12-questions--mark-distribution)
   - [1.3 Official Sample Output](#13-official-sample-output)
2. [Bullet-Pointed Summary of `shr_Semim.asm` (Set A)](#2-bullet-pointed-summary-of-shr_semimasm-set-a)
3. [Bullet-Pointed Summary of `shl_Semim.asm` (Set B)](#3-bullet-pointed-summary-of-shl_semimasm-set-b)
4. [Shift Count Mechanics & The Sample Output Resolution (`shr_Semim[mod].asm`)](#4-shift-count-mechanics--the-sample-output-resolution-shr_semimmodasm)
5. [Step-by-Step Mathematical Trace & Register Mapping](#5-step-by-step-mathematical-trace--register-mapping)
6. [Comparative Summary Matrix](#6-comparative-summary-matrix)

---

## 1. Official Examination Task (UITS Lab Test 01)

### 1.1 Examination Metadata & Instructions
* **Institution**: University of Information Technology & Sciences (UITS)
* **Faculty**: Faculty of Science and Engineering
* **Department**: Department of Computer Science and Engineering
* **Program**: B.Sc. in CSE
* **Semester**: Autumn 2026
* **Course Title**: Microprocessors & Microcontrollers Lab
* **Course Code**: `CSE0611323`
* **Section**: 6A
* **Duration**: 1 Hour
* **Total Marks**: 10 Marks
* **Exam Sets**: **Set A** (`SHR` operation) and **Set B** (`SHL` operation)

#### Instructions to Candidates:
1. Write your codes using standard 8086 Assembly Language (compatible with EMU8086).
2. Add appropriate comments to explain your logic. Marks will be deducted for uncommented code.
3. The output should be according to the sample output. If sample output is not followed, marks will be deducted.

### 1.2 Questions & Mark Distribution
* **Question 1 [2 Marks]**: Write an assembly language program that reads two 1-digit numbers (from `'1'` to `'9'`) from the keyboard.
* **Question 2 [3 Marks]**: Divide the second digit by the first digit and display the quotient and remainder on the next line.
* **Question 3 [3 Marks]**: 
  - **Set A**: Perform a shift right (`SHR`) operation on the multiplication result and print the resulting value in Hexadecimal.
  - **Set B**: Perform a shift left (`SHL`) operation on the multiplication result and print the resulting value in Hexadecimal.
* **Question 4 [2 Marks]**: Print as per sample output.

### 1.3 Official Sample Output
```text
Enter first digit: 3
Enter second digit: 8
Quotient= 2
Remainder = 2
After SHR: 01H
```
*(For Set B, the final line reads `After SHL: <HEX_VALUE>H`)*.

---

## 2. Bullet-Pointed Summary of `shr_Semim.asm` (Set A)

* **Source File**: [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim.asm)
* **Target Exam Set**: **Set A** (Shift Right implementation).

### Key Architectural & Logic Highlights:
* **Memory & Directives**:
  - Uses `.model small` with `.stack 100h` allocating 256 bytes for CPU stack tracking.
  - Declares byte storage variables: `num1`, `num2`, `quot`, `rem`, `mult`.
  - Defines console prompt strings in `.DATA` using embedded decimal control characters `10, 13` (Line Feed followed by Carriage Return).
* **Keyboard Input & Conversion**:
  - Prompts with `msg1` using `INT 21H / AH=09H` and reads first digit via `INT 21H / AH=01H`.
  - Converts from ASCII glyph to integer via `SUB AL, 48` (or `'0'`) and stores in `num1`.
  - Repeats prompt and read sequence for the second digit, saving the numeric value in `num2`.
* **Hardware Division (`num2 / num1`)**:
  - Copies `num2` into accumulator `AL` and `num1` into divisor `BL`.
  - Clears `AH` to zero (`mov ah, 0`) to prevent CPU Divide Overflow exceptions (`Fault #DE`).
  - Executes 8-bit division `DIV BL`:
    - Quotient is placed in `AL`, saved to `quot`.
    - Remainder is placed in `AH`, saved to `rem`.
  - Converts results to ASCII immediately via `ADD quot, 48` and `ADD rem, 48`.
* **Division Results Display**:
  - Displays `msg_q` (`"Quotient = "`) via `AH=09H`, then outputs `quot` using `INT 21H / AH=02H`.
  - Displays `msg_r` (`"Remainder = "`) via `AH=09H`, then outputs `rem` using `INT 21H / AH=02H`.
* **Multiplication & Shift Right**:
  - Reloads raw numeric values `num1` into `AL` and `num2` into `BL`.
  - Executes unsigned 8-bit hardware multiplication `MUL BL`:
    - Product is stored in `AX` (specifically `AL` for single-digit products $\le 81$).
  - Executes logical shift right: `shr al, 1`.
  - Preserves shifted result in `BL` (`mov bl, al`) for hex output.
* **Hexadecimal Output & Subroutine Call**:
  - Prints prompt `msg_shr` (`"After SHR: "`).
  - **Upper Nibble**: Copies `BL` to `AL`, shifts right 4 bits (`shr al, 4`), and calls `print_hex`.
  - **Lower Nibble**: Copies `BL` to `AL`, masks with `0Fh` (`and al, 0Fh`), and calls `print_hex`.
  - Prints trailing `'H'` character via `INT 21H / AH=02H`.
* **Procedure `print_hex` Mechanics**:
  - Takes a 4-bit nibble (value 0–15) in `AL`.
  - Adds 48 (`add al, 48`).
  - Compares with 57 (`cmp al, 57`). If $\le 57$ (digit '0'–'9'), jumps to `out_label`.
  - If $> 57$ (digit 'A'–'F'), adds 7 (`add al, 7`) to map values 10–15 to ASCII 65–70 ('A'–'F').
  - Emits character via `INT 21H / AH=02H` and returns with `RET`.
* **Program Termination**:
  - Exits gracefully to DOS using `MOV AH, 4Ch; INT 21H`.

---

## 3. Bullet-Pointed Summary of `shl_Semim.asm` (Set B)

* **Source File**: [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shl_Semim.asm)
* **Target Exam Set**: **Set B** (Shift Left implementation).

### Key Architectural & Logic Highlights:
* **Identification & Resolution of Earlier Bug**:
  - In earlier drafts, `shl_Semim.asm` erroneously executed `shr al, 1` with string `msg_shr`.
  - The current code is **fully fixed and verified**:
    - `.DATA` string defined as: `msg_shl db 10,13,'After SHL: $'` (Line 14).
    - Shift opcode updated to: `shl al, 1` (Line 78).
    - Display pointer updated to: `mov dx, offset msg_shl` (Line 82).
    - Annotated with author verification marker: `; ata sHL` (Line 122).
* **Identical Input & Division Pipeline**:
  - Follows the exact same prompt, character acquisition, and division structure as Set A.
  - Correctly clears `AH = 0` prior to `DIV BL`.
  - Converts `quot` and `rem` to ASCII via `+ 48` immediately following division.
* **Multiplication & Shift Left**:
  - Computes `num1 * num2` using `MUL BL`.
  - Executes logical shift left: `shl al, 1` (equivalent to multiplying product by 2).
  - Preserves shifted product in `BL` for hex formatting.
* **Hexadecimal Subroutine**:
  - Emits `"After SHL: "` followed by the 2-digit hex representation (high nibble then low nibble) followed by `'H'`.

---

## 4. Shift Count Mechanics & The Sample Output Resolution (`shr_Semim[mod].asm`)

A notable discovery in the workspace is the variant file [`shr_Semim[mod].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim%5Bmod%5D.asm).

### The Problem:
* In the official exam paper:
  - Input 1: `3`
  - Input 2: `8`
  - Required output line: **`After SHR: 01H`**

### Mathematical Comparison:
* **Product Calculation**:
  $$\text{Product} = 3 \times 8 = 24_{10} = 0001\ 1000_2 = 18_{16}$$
* **Default Single-Bit Shift (`shr al, 1`) in `shr_Semim.asm`**:
  $$0001\ 1000_2 \gg 1 = 0000\ 1100_2 = 12_{10} = 0\text{C}_{16}$$
  - Console Output: `After SHR: 0CH`
  - **Does NOT match** the sample output printed on the question paper!
* **Modified 4-Bit Nibble Shift (`shr al, 4`) in `shr_Semim[mod].asm`**:
  $$0001\ 1000_2 \gg 4 = 0000\ 0001_2 = 1_{10} = 01_{16}$$
  - Console Output: `After SHR: 01H`
  - **Matches the exam sample output byte-for-byte!**

> [!NOTE]
> The author explicitly documented this finding in [`shr_Semim[mod].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim%5Bmod%5D.asm#L78):
> ```assembly
> shr al, 4    ; <----- MODIFIED: `Question did not specify how many bits to SHR`
> ```
> Since Question 3 simply stated *"Perform a shift right (SHR) operation on the multiplication result"* without specifying the bit count, a shift of 4 bits was required to reproduce the exact sample output of `01H`.

---

## 5. Step-by-Step Mathematical Trace & Register Mapping

The trace below illustrates the full state flow when running with the official test inputs (`num1 = 3`, `num2 = 8`):

```text
================================================================================
STEP 1: KEYBOARD INPUT
================================================================================
Read Input 1: User types '3' (ASCII 51 / 33h) --> SUB 48 --> num1 = 3
Read Input 2: User types '8' (ASCII 56 / 38h) --> SUB 48 --> num2 = 8

================================================================================
STEP 2: DIVISION (second digit by first digit -> 8 / 3)
================================================================================
Registers before DIV: AL = 08h, AH = 00h (Clean AX = 0008h), BL = 03h
Instruction         : DIV BL
Registers after DIV : AL = 02h (Quotient), AH = 02h (Remainder)
ASCII Adjustment    : quot = 2 + 48 = 50 ('2')
                      rem  = 2 + 48 = 50 ('2')
Display Output      : "Quotient = 2"
                      "Remainder = 2"

================================================================================
STEP 3: MULTIPLICATION (num1 * num2 -> 3 * 8)
================================================================================
Registers before MUL: AL = 03h, BL = 08h
Instruction         : MUL BL
Registers after MUL : AX = 0018h (AL = 18h = 24 decimal, AH = 00h)

================================================================================
STEP 4: SHIFT OPERATIONS (SET A vs. SET B)
================================================================================
[Set A - shr_Semim.asm (1-bit)]:
  AL = 18h (0001 1000b) SHR 1 --> AL = 0Ch (0000 1100b), CF = 0
  Hex Decomposition: High = 00h ('0'), Low = 0Ch ('C')
  Display: "After SHR: 0CH"

[Set A - shr_Semim[mod].asm (4-bit, Exact Sample Output)]:
  AL = 18h (0001 1000b) SHR 4 --> AL = 01h (0000 0001b), CF = 1
  Hex Decomposition: High = 00h ('0'), Low = 01h ('1')
  Display: "After SHR: 01H"

[Set B - shl_Semim.asm (1-bit)]:
  AL = 18h (0001 1000b) SHL 1 --> AL = 30h (0011 0000b), CF = 0
  Hex Decomposition: High = 03h ('3'), Low = 00h ('0')
  Display: "After SHL: 30H"
```

---

## 6. Comparative Summary Matrix

| Metric / Feature | [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim.asm) | [`shr_Semim[mod].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim%5Bmod%5D.asm) | [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shl_Semim.asm) |
| :--- | :--- | :--- | :--- |
| **Exam Set** | Set A | Set A (Sample Output Match) | Set B |
| **Shift Instruction** | `shr al, 1` | `shr al, 4` | `shl al, 1` |
| **Multiplication ($3 \times 8$)** | $24_{10} = 18_{16}$ | $24_{10} = 18_{16}$ | $24_{10} = 18_{16}$ |
| **Shifted Value** | $12_{10} = 0\text{C}_{16}$ | $1_{10} = 01_{16}$ | $48_{10} = 30_{16}$ |
| **Console Output** | `After SHR: 0CH` | `After SHR: 01H` *(Exact Sample)* | `After SHL: 30H` |
| **Shift Message Label** | `msg_shr` (`'After SHR: $'`) | `msg_shr` (`'After SHR: $'`) | `msg_shl` (`'After SHL: $'`) |
| **AH Cleared Before DIV** | Yes (`mov ah, 0`) | Yes (`mov ah, 0`) | Yes (`mov ah, 0`) |
| **Hex Conversion Subroutine** | `print_hex` (`+48`, `CMP 57`, `+7`) | `print_hex` (`+48`, `CMP 57`, `+7`) | `print_hex` (`+48`, `CMP 57`, `+7`) |

---
*Maintained under [Microprocessor & Assembly Lab Repository](https://github.com/b1tranger/Microprocessor_Assembly_Lab).*
