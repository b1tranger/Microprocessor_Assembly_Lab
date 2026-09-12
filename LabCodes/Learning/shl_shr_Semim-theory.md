# Theory & Comparative Analysis: `shl_Semim.asm` vs. `shr_Semim.asm`

This document provides a comprehensive technical comparison, architectural breakdown, and theory guide for [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shl_Semim.asm), [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim.asm), and the exact sample-output variant [`shr_Semim[mod].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim%5Bmod%5D.asm) in [`LabCodes/Labtest/prep/CSE55-096/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096).

---

## Table of Contents
1. [Official Examination Context (UITS Lab Test 01)](#1-official-examination-context-uits-lab-test-01)
   - [1.1 Task Specification & Set Division](#11-task-specification--set-division)
   - [1.2 Required Sample Output](#12-required-sample-output)
2. [Code Evolution & Status of `shl_Semim.asm`](#2-code-evolution--status-of-shl_semimasm)
   - [2.1 The Historical Copy-Paste Bug](#21-the-historical-copy-paste-bug)
   - [2.2 The Verified Bug Fix](#22-the-verified-bug-fix)
3. [Key Code Differences Side-by-Side](#3-key-code-differences-side-by-side)
   - [3.1 Shift Operation: `SHL` vs. `SHR`](#31-shift-operation-shl-vs-shr)
   - [3.2 ASCII Conversion Timing](#32-ascii-conversion-timing)
   - [3.3 Newline String Literals (`10, 13`)](#33-newline-string-literals-10-13)
4. [Microprocessor Mechanics: Shift & Rotate Operations](#4-microprocessor-mechanics-shift--rotate-operations)
   - [4.1 Bitwise Mechanics of `SHR` (Logical Shift Right)](#41-bitwise-mechanics-of-shr-logical-shift-right)
   - [4.2 Bitwise Mechanics of `SHL` (Logical Shift Left)](#42-bitwise-mechanics-of-shl-logical-shift-left)
   - [4.3 Hardware Shift Count Constraint (The `CL` Rule)](#43-hardware-shift-count-constraint-the-cl-rule)
5. [The Sample Output Discrepancy & Resolution (`shr_Semim[mod].asm`)](#5-the-sample-output-discrepancy--resolution-shr_semimmodasm)
   - [5.1 Why `shr al, 1` Produces `0CH`](#51-why-shr-al-1-produces-0ch)
   - [5.2 Why `shr al, 4` Produces `01H`](#52-why-shr-al-4-produces-01h)
6. [Nibble Separation & Hexadecimal ASCII Subroutine](#6-nibble-separation--hexadecimal-ascii-subroutine)
7. [Step-by-Step Execution Traces](#7-step-by-step-execution-traces)
   - [7.1 Trace for Set A with 1-bit Shift (`shr_Semim.asm`)](#71-trace-for-set-a-with-1-bit-shift-shr_semimasm)
   - [7.2 Trace for Set A with 4-bit Shift (`shr_Semim[mod].asm`)](#72-trace-for-set-a-with-4-bit-shift-shr_semimmodasm)
   - [7.3 Trace for Set B with 1-bit Shift (`shl_Semim.asm`)](#73-trace-for-set-b-with-1-bit-shift-shl_semimasm)
8. [Master Comparative Summary Table](#8-master-comparative-summary-table)

---

## 1. Official Examination Context (UITS Lab Test 01)

### 1.1 Task Specification & Set Division
Both assembly programs directly implement the official questions from **University of Information Technology & Sciences (UITS)**, **Department of Computer Science and Engineering**:
* **Course**: Microprocessors & Microcontrollers Lab (`CSE0611323`)
* **Semester**: Autumn 2026 | **Section**: 6A | **Duration**: 1 Hour | **Marks**: 10
* **Set Allocation**:
  - **Set A**: Implemented in [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim.asm). Requires performing a Shift Right (`SHR`) on the multiplication product.
  - **Set B**: Implemented in [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shl_Semim.asm). Requires performing a Shift Left (`SHL`) on the multiplication product.

### 1.2 Required Sample Output
The official question paper dictates strict compliance with the following format:
```text
Enter first digit: 3
Enter second digit: 8
Quotient= 2
Remainder = 2
After SHR: 01H
```
*(For Set B, the final line reads `After SHL: <HEX_VALUE>H`)*.

---

## 2. Code Evolution & Status of `shl_Semim.asm`

### 2.1 The Historical Copy-Paste Bug
In early versions of the code, [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shl_Semim.asm) suffered from a common assembly lab bug:
* The file was created by duplicating [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim.asm).
* Lines 74–81 erroneously retained:
  ```assembly
  ; Shift Right (SHR) operation on multiplication result
  shr  al, 1          ; <--- BUG: In shl_Semim.asm, it still executed SHR!
  mov  bl, al
  mov  dx, offset msg_shr
  ```

### 2.2 The Verified Bug Fix
The file has since been **corrected and verified**:
```assembly
; In shl_Semim.asm (lines 14, 78, 82, 122):
msg_shl db 10,13,'After SHL: $'       ; Dedicated SHL string
...
shl  al, 1                            ; Corrected shift instruction
mov  bl, al                           ; Save shifted product in BL
...
mov  dx, offset msg_shl               ; Displays msg_shl
...
; ata sHL                             ; Author confirmation note
```

---

## 3. Key Code Differences Side-by-Side

### 3.1 Shift Operation: `SHL` vs. `SHR`

```assembly
; Set A: shr_Semim.asm (lines 77-84)
mov  al, num1
mov  bl, num2
mul  bl                               ; AX = num1 * num2
shr  al, 1                            ; Logical Shift Right by 1
mov  bl, al
mov  dx, offset msg_shr
mov  ah, 09h
int  21h

; Set B: shl_Semim.asm (lines 72-84)
mov  al, num1
mov  bl, num2
mul  bl                               ; AX = num1 * num2
shl  al, 1                            ; Logical Shift Left by 1
mov  bl, al
mov  dx, offset msg_shl
mov  ah, 09h
int  21h
```

---

### 3.2 ASCII Conversion Timing

Both files perform integer division (`div bl`) on `num2 / num1`:
```assembly
mov  al, num2
mov  bl, num1
mov  ah, 0                            ; Register hygiene: clears AH before DIV
div  bl                               ; AL = Quotient, AH = Remainder
mov  quot, al
mov  rem, ah 
add  quot, 48                         ; Immediate conversion to ASCII
add  rem, 48
```
> [!NOTE]
> Later in the display block, redundant lines such as `;add quot, 48` remain commented out, confirming that conversion is handled immediately after division.

---

### 3.3 Newline String Literals (`10, 13`)

Both files declare strings using decimal ASCII constants:
```assembly
msg2 db 10, 13, 'Enter second digit: $'
msg_q db 10, 13, 'Quotient = $'
msg_r db 10, 13, 'Remainder = $'
```
- `10` = Line Feed (`LF`, `\n`)
- `13` = Carriage Return (`CR`, `\r`)
- This orders the control sequence as `LF -> CR`. While standard DOS formatting is `CR -> LF` (`13, 10` / `0Dh, 0Ah`), modern DOS emulators (EMU8086, DOSBox) interpret both orders equivalently to reposition the cursor at the start of the next line.

---

## 4. Microprocessor Mechanics: Shift & Rotate Operations

### 4.1 Bitwise Mechanics of `SHR` (Logical Shift Right)
`SHR reg, 1` performs an unsigned logical right shift:
1. All bits shift right by 1 position.
2. The Most Significant Bit (MSB, Bit 7) is filled with `0`.
3. The Least Significant Bit (LSB, Bit 0) is pushed into the **Carry Flag (CF)**.
4. **Mathematical Effect**: Computes integer division by 2 ($\lfloor X / 2 \rfloor$).

```text
+---+    +---+---+---+---+---+---+---+---+    +---+
| 0 | -> | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | -> |CF |
+---+    +---+---+---+---+---+---+---+---+    +---+
```

### 4.2 Bitwise Mechanics of `SHL` (Logical Shift Left)
`SHL reg, 1` performs an unsigned logical left shift:
1. All bits shift left by 1 position.
2. The Least Significant Bit (LSB, Bit 0) is filled with `0`.
3. The Most Significant Bit (MSB, Bit 7) is pushed into the **Carry Flag (CF)**.
4. **Mathematical Effect**: Computes multiplication by 2 ($X \times 2$), provided no overflow beyond 8 bits occurs.

```text
+---+    +---+---+---+---+---+---+---+---+    +---+
|CF | <- | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | <- | 0 |
+---+    +---+---+---+---+---+---+---+---+    +---+
```

### 4.3 Hardware Shift Count Constraint (The `CL` Rule)
In pure 8086 processor architecture:
- An immediate count of `1` is valid directly in the opcode (`SHR AL, 1`, `SHL AL, 1`).
- Immediate shift counts greater than 1 (`SHR AL, 4`) are **invalid** on original 8086 hardware and require loading into the `CL` register:
  ```assembly
  mov cl, 4
  shr al, cl
  ```
  *(EMU8086 allows `shr al, 4` in extended 80186+ emulation mode).*

---

## 5. The Sample Output Discrepancy & Resolution (`shr_Semim[mod].asm`)

A key analytical finding in this repository centers on [`shr_Semim[mod].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim%5Bmod%5D.asm).

### 5.1 Why `shr al, 1` Produces `0CH`
Given sample inputs `num1 = 3` and `num2 = 8`:
1. Multiplication:
   $$\text{Product} = 3 \times 8 = 24_{10} = 0001\ 1000_2 = 18_{16}$$
2. Shifting right by 1 bit:
   $$0001\ 1000_2 \gg 1 = 0000\ 1100_2 = 12_{10} = 0\text{C}_{16}$$
3. Resulting Output:
   ```text
   After SHR: 0CH
   ```
   **Problem**: This does *not* match the sample output printed on the official exam sheet (`After SHR: 01H`).

### 5.2 Why `shr al, 4` Produces `01H`
In [`shr_Semim[mod].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim%5Bmod%5D.asm#L78), the shift instruction was updated:
```assembly
shr  al, 4    ; <----- MODIFIED: `Question did not specify how many bits to SHR`
```
1. Shifting right by 4 bits:
   $$0001\ 1000_2 \gg 4 = 0000\ 0001_2 = 1_{10} = 01_{16}$$
2. Resulting Output:
   ```text
   After SHR: 01H
   ```
   **Result**: This matches the question paper sample output **byte-for-byte**!

---

## 6. Nibble Separation & Hexadecimal ASCII Subroutine

Both programs format their shift result as two hex digits followed by `'H'`:

```assembly
; 1. Print HIGH nibble (bits 7..4)
mov  al, bl
shr  al, 4                   ; Shift bits 7..4 into position 3..0
call print_hex

; 2. Print LOW nibble (bits 3..0)
mov  al, bl
and  al, 0Fh                 ; Mask off upper nibble (0000 1111b)
call print_hex

; 3. Print 'H' suffix
mov  dl, 'H'
mov  ah, 02h
int  21h
```

### The `print_hex` Subroutine:
```assembly
print_hex proc
    add al, 48               ; Base offset: converts 0..9 to '0'..'9' (ASCII 48..57)
    cmp al, 57
    jbe out_label            ; If <= '9', ready to print
    add al, 7                ; For 10..15: 58 + 7 = 65 ('A') through 70 ('F')
out_label:
    mov dl, al
    mov ah, 02h
    int 21h
    ret
print_hex endp
```

---

## 7. Step-by-Step Execution Traces

Assume candidate inputs:
- First digit `num1 = 3`
- Second digit `num2 = 8`

### 7.1 Trace for Set A with 1-bit Shift (`shr_Semim.asm`)
1. **Division (`num2 / num1` $\rightarrow$ `8 / 3`)**:
   - `AL = 08h`, `AH = 00h`, `BL = 03h`
   - `DIV BL` $\rightarrow$ `AL = 02h` (Quotient), `AH = 02h` (Remainder).
   - Display:
     ```text
     Quotient = 2
     Remainder = 2
     ```
2. **Multiplication (`3 * 8`)**:
   - `AL = 03h`, `BL = 08h`
   - `MUL BL` $\rightarrow$ `AX = 0018h` (`24` decimal, `0001 1000b`).
3. **Shift Right (`shr al, 1`)**:
   - `0001 1000b` $\gg 1 = 0000\ 1100_2 = 0\text{C}_{16}$.
   - High nibble: `0` $\rightarrow$ `'0'`
   - Low nibble: `12` $\rightarrow$ `'C'`
   - Display: `After SHR: 0CH`

### 7.2 Trace for Set A with 4-bit Shift (`shr_Semim[mod].asm`)
1. **Shift Right (`shr al, 4`)**:
   - `0001 1000b` $\gg 4 = 0000\ 0001_2 = 01_{16}$.
   - High nibble: `0` $\rightarrow$ `'0'`
   - Low nibble: `1` $\rightarrow$ `'1'`
   - Display: `After SHR: 01H` *(Exact match with UITS sample output)*.

### 7.3 Trace for Set B with 1-bit Shift (`shl_Semim.asm`)
1. **Shift Left (`shl al, 1`)**:
   - `0001 1000b` $\ll 1 = 0011\ 0000_2 = 48_{10} = 30_{16}$.
   - High nibble: `3` $\rightarrow$ `'3'`
   - Low nibble: `0` $\rightarrow$ `'0'`
   - Display: `After SHL: 30H`

---

## 8. Master Comparative Summary Table

| Feature / Metric | [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim.asm) | [`shr_Semim[mod].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shr_Semim%5Bmod%5D.asm) | [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/CSE55-096/shl_Semim.asm) |
| :--- | :--- | :--- | :--- |
| **Exam Assignment** | Set A (Shift Right) | Set A (Sample Output Match) | Set B (Shift Left) |
| **Shift Instruction** | `shr al, 1` | `shr al, 4` | `shl al, 1` |
| **Multiplication ($3 \times 8$)** | $24_{10} = 18_{16}$ | $24_{10} = 18_{16}$ | $24_{10} = 18_{16}$ |
| **Shift Output for Inputs 3, 8** | `After SHR: 0CH` | `After SHR: 01H` *(Matches PDF)* | `After SHL: 30H` |
| **Display Message** | `msg_shr` (`'After SHR: $'`) | `msg_shr` (`'After SHR: $'`) | `msg_shl` (`'After SHL: $'`) |
| **Newline Delimiters** | `10, 13` (LF, CR) | `10, 13` (LF, CR) | `10, 13` (LF, CR) |
| **ASCII Transformation** | Immediate (`add quot, 48`) | Immediate (`add quot, 48`) | Immediate (`add quot, 48`) |
| **Register Clearing (`AH=0`)** | Yes (`mov ah, 0`) | Yes (`mov ah, 0`) | Yes (`mov ah, 0`) |
| **Hex Printing Logic** | High nibble + Low nibble | High nibble + Low nibble | High nibble + Low nibble |

---
*Maintained under [Microprocessor & Assembly Lab Repository](https://github.com/b1tranger/Microprocessor_Assembly_Lab).*
