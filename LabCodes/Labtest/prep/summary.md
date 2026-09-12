# Lab Test Preparation Programs: Master Concept Summary & Architectural Reference

This document provides a concise architectural breakdown, algorithmic explanation, and comparative analysis for the dedicated 8086 assembly preparation programs located in [`LabCodes/Labtest/prep/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep). Each program demonstrates core concepts, modern idiomatic alternatives (e.g., `LEA` vs `OFFSET`, bidirectional `XOR` toggling, register hygiene), and hardware-compliant multi-bit operations.

---

## Table of Contents
1. [Overview & Program Directory Mapping](#1-overview--program-directory-mapping)
2. [Program Summaries & Technical Deep Dives](#2-program-summaries--technical-deep-dives)
   - [2.1 Arithmetic Operations (`arithmetic_operations.asm`)](#21-arithmetic-operations-arithmetic_operationsasm)
   - [2.2 String Printing & Addressing Modes (`string_printing_lea.asm`)](#22-string-printing--addressing-modes-string_printing_leaasm)
   - [2.3 Bitwise Logic, Shift & Rotate (`bitwise_and_or_shift_rotate.asm`)](#23-bitwise-logic-shift--rotate-bitwise_and_or_shift_rotateasm)
   - [2.4 Hexadecimal Value Output (`print_hexadecimal_values.asm`)](#24-hexadecimal-value-output-print_hexadecimal_valuesasm)
   - [2.5 Bidirectional Character Case Conversion (`case_conversion_xor.asm`)](#25-bidirectional-character-case-conversion-case_conversion_xorasm)
3. [Comparative Mechanics & High-Yield Cheatsheet](#3-comparative-mechanics--high-yield-cheatsheet)
   - [3.1 LEA vs MOV DX, OFFSET](#31-lea-vs-mov-dx-offset)
   - [3.2 ASCII Arithmetic vs Pure Logic Toggling](#32-ascii-arithmetic-vs-pure-logic-toggling)
   - [3.3 8086 Shifting & Rotation Hardware Rules](#33-8086-shifting--rotation-hardware-rules)
   - [3.4 Division Hygiene & Radix-10 Decomposition](#34-division-hygiene--radix-10-decomposition)

---

## 1. Overview & Program Directory Mapping

The table below maps each preparation file to its primary laboratory concepts, alternative approaches demonstrated, and key CPU registers utilized:

| File Name | Primary Concept | Alternative Approaches Demonstrated | Key Registers & DOS Services |
| :--- | :--- | :--- | :--- |
| [`arithmetic_operations.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/arithmetic_operations.asm) | All 4 Arithmetic Operations (`ADD`, `SUB`, `MUL`, `DIV`) | • `LEA` address loading for prompts<br>• Dynamic keyboard input & conversion<br>• Zeroing `AH` prior to `DIV`<br>• Decimal radix-10 decomposition for 2-digit results | `AX` (`AL`/`AH`), `BX`, `DX`<br>`INT 21H / AH=01H, 02H, 09H` |
| [`string_printing_lea.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/string_printing_lea.asm) | String Display & Addressing Modes | • `LEA DX, label` runtime effective addressing<br>• Multi-line banner with embedded CRLF (`13, 10`)<br>• Byte-by-byte traversal with pointer `[SI]` for null-terminated strings | `DX` (string pointer), `SI` (index)<br>`INT 21H / AH=09H, 02H` |
| [`bitwise_and_or_shift_rotate.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/bitwise_and_or_shift_rotate.asm) | Bitwise Logic (`AND`, `OR`, `XOR`) & Shifts (`SHL`, `SHR`, `ROL`, `ROR`) | • Pure 8086 hardware shift count via `CL`<br>• Subroutine outputting 8-bit binary string (`shl bl, 1` + carry inspection)<br>• Bit masking vs setting | `AL`, `CL` (shift counter), `CF`<br>`INT 21H / AH=02H, 09H` |
| [`print_hexadecimal_values.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/print_hexadecimal_values.asm) | Hexadecimal Printing Subroutines | • Modular `print_hex_byte` & `print_hex_word`<br>• Nibble isolation (`shr al, 4` & `and al, 0Fh`)<br>• Branching conversion (`+ '0'`, `CMP '9'`, `+ 7`)<br>• Full stack preservation (`PUSH`/`POP`) | `AL` (byte), `AX` (word), `BL`, `DX`<br>`INT 21H / AH=02H` |
| [`case_conversion_xor.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/case_conversion_xor.asm) | Character Case Conversion & Toggling | • Universal case inversion using `XOR AL, 20h`<br>• Range validation (`'A'-'Z'` and `'a'-'z'`)<br>• In-place batch string transformation loop via `[SI]` | `AL`, `BL`, `SI`<br>`INT 21H / AH=01H, 02H, 09H` |

---

## 2. Program Summaries & Technical Deep Dives

### 2.1 Arithmetic Operations (`arithmetic_operations.asm`)
* **Source Code**: [`arithmetic_operations.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/arithmetic_operations.asm)
* **Objective**: Performs dynamic addition, subtraction (with negative detection), multiplication, and division on user-supplied single-digit inputs, formatting two-digit answers cleanly.
* **Key Mechanics**:
  - **Dynamic Input**: Reads single digits via `INT 21H / AH=01H` and converts ASCII digits to binary integers using `SUB AL, '0'`.
  - **Division Register Hygiene**: Explicitly executes `XOR AH, AH` before `DIV BL` to guarantee the 16-bit dividend in `AX` has a clean high byte, preventing fatal Divide Error interrupts (`#DE`).
  - **Multiplication**: `MUL BL` multiplies `AL * BL` and places the full product in `AX`.
  - **Decimal Decomposition (`print_two_digits`)**: Solves the common limitation of single-character output by dividing the result by 10 (`DIV 10`). The quotient in `AL` is the tens digit and remainder in `AH` is the units digit.

```text
Input: A = 9, B = 4
Addition       : 9 + 4 = 13  --> DIV 10 --> Tens: 1, Units: 3  --> "13"
Subtraction    : 9 - 4 = 05  --> DIV 10 --> Tens: 0, Units: 5  --> "05"
Multiplication : 9 * 4 = 36  --> DIV 10 --> Tens: 3, Units: 6  --> "36"
Division       : 9 / 4 = Q: 02, R: 01
```

---

### 2.2 String Printing & Addressing Modes (`string_printing_lea.asm`)
* **Source Code**: [`string_printing_lea.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/string_printing_lea.asm)
* **Objective**: Demonstrates three alternative strategies for displaying strings in 8086 assembly.
* **Key Mechanics**:
  1. **`LEA DX, label`**: Computes the effective offset of the target memory label at execution time. Supports base-index addressing expressions (`[BX+SI+disp]`).
  2. **Embedded Carriage Return (13) & Line Feed (10)**: Eliminates repetitive calls to DOS interrupt 02h by baking newline sequences directly into the `.DATA` string definition (`DB 13, 10, '...'`).
  3. **Null-Terminated Pointer Loop**: Demonstrates standard C-style string traversal where pointer `SI` steps through memory until encountering `00h`, printing each byte via `INT 21H / AH=02H`. This bypasses the DOS `$` sentinel restriction entirely.

---

### 2.3 Bitwise Logic, Shift & Rotate (`bitwise_and_or_shift_rotate.asm`)
* **Source Code**: [`bitwise_and_or_shift_rotate.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/bitwise_and_or_shift_rotate.asm)
* **Objective**: Explains the execution characteristics of `AND`, `OR`, `XOR`, `SHL`, `SHR`, `ROL`, and `ROR` with interactive binary output.
* **Key Mechanics**:
  - **Pure 8086 Multi-Bit Shift Rule**: Demonstrates that for shift or rotation counts greater than 1, the 8086 CPU strictly mandates placing the count in the `CL` register (`MOV CL, 3; SHR AL, CL`). Immediate multi-bit shifts like `SHR AL, 3` were only added in the 80186 processor.
  - **Bit Masking (`AND AL, 0Fh`)**: Clears bits 7-4 while preserving bits 3-0.
  - **Bit Setting (`OR AL, 30h`)**: Forces specific bits high without altering unmasked bits.
  - **Circular Rotation (`ROL` / `ROR`)**: Bits shifted off one end wrap around and enter the opposite end, preserving total bit quantity.
  - **`print_binary_8bit` Subroutine**: Successively shifts the MSB into the Carry Flag (`SHL BL, 1; JC ...`) and emits `'1'` or `'0'` with an aesthetic space dividing the upper and lower nibbles.

---

### 2.4 Hexadecimal Value Output (`print_hexadecimal_values.asm`)
* **Source Code**: [`print_hexadecimal_values.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/print_hexadecimal_values.asm)
* **Objective**: Provides reusable, stack-safe subroutines to display raw 8-bit bytes and 16-bit words as ASCII hexadecimal text.
* **Key Mechanics**:
  - **Nibble Splitting**:
    - Upper nibble: Shift right by 4 bits (`SHR AL, 4`) using `CL = 4`.
    - Lower nibble: Mask out upper 4 bits with `AND AL, 0Fh`.
  - **Hexadecimal ASCII Conversion Rule**:
    - Adding `'0'` (48) maps nibbles `0-9` to ASCII `'0'-'9'`.
    - For values `10-15` (`0Ah-0Fh`), an additional `+7` adjustment is needed because there is a 7-character gap in the ASCII table between `'9'` (57) and `'A'` (65):
      $$\text{ASCII} = \text{Nibble} + 48 + 7 = \text{Nibble} + 55 \quad (\text{when Nibble} \ge 10)$$
  - **Word Printing (`print_hex_word`)**: Emits `AH` (most significant byte) first, followed by `AL` (least significant byte).

---

### 2.5 Bidirectional Character Case Conversion (`case_conversion_xor.asm`)
* **Source Code**: [`case_conversion_xor.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/case_conversion_xor.asm)
* **Objective**: Demonstrates universal, bidirectional ASCII case toggling using bitwise `XOR AL, 20h` along with input classification and in-place string processing.
* **Key Mechanics**:
  - **The Bit 5 Architecture**:
    - Uppercase `'A'` = `41h` = `0100 0001b`
    - Lowercase `'a'` = `61h` = `0110 0001b`
    - The difference between uppercase and lowercase English letters is solely **bit 5** (`20h` = 32 decimal).
  - **Why `XOR AL, 20h` is Superior to `ADD`/`SUB`**:
    - `SUB AL, 20h` only works if the input is already known to be lowercase. If run on an uppercase letter, it corrupts the character into punctuation.
    - `ADD AL, 20h` only works if the input is already known to be uppercase.
    - `XOR AL, 20h` flips bit 5 unconditionally:
      - If bit 5 is `0` (uppercase), it becomes `1` (lowercase).
      - If bit 5 is `1` (lowercase), it becomes `0` (uppercase).
  - **Boundary Validation**: Validates whether the character falls in `'A'..'Z'` or `'a'..'z'` before toggling so punctuation, numbers, and spaces are untouched.
  - **Batch String Traversal**: Uses `LEA SI, sample_str` to iterate across an entire string in memory and toggle characters in-place.

---

## 3. Comparative Mechanics & High-Yield Cheatsheet

### 3.1 LEA vs MOV DX, OFFSET

| Feature | `LEA DX, Target` (Load Effective Address) | `MOV DX, OFFSET Target` |
| :--- | :--- | :--- |
| **Resolution Time** | Runtime calculation by CPU execution unit. | Assemble / link time constant substitution. |
| **Addressing Flexibility** | Supports complex addressing modes: `[BX+SI+disp]`, `[BP+DI]`. | Only supports direct memory labels known at assemble time. |
| **Instruction Size** | Typically 3 to 4 bytes. | Typically 3 bytes. |
| **Use Case Recommendation** | Ideal for subroutines, dynamic pointers, arrays, and stack frames. | Ideal for static `.DATA` strings where offset never changes. |

---

### 3.2 ASCII Arithmetic vs Pure Logic Toggling

```text
[Uppercase to Lowercase]
Traditional Arithmetic : ADD AL, 32    (41h + 20h = 61h -> 'A' to 'a')
Logical Masking        : OR  AL, 00100000b (Forces bit 5 to 1)

[Lowercase to Uppercase]
Traditional Arithmetic : SUB AL, 32    (61h - 20h = 41h -> 'a' to 'A')
Logical Masking        : AND AL, 11011111b (Forces bit 5 to 0; mask 0DFh)

[Bidirectional Case Toggling]
Universal Logic        : XOR AL, 00100000b (Inverts bit 5; 20h / 32)
```

---

### 3.3 8086 Shifting & Rotation Hardware Rules

1. **Shift Count Limitation**:
   - Single-bit shift: `SHL reg, 1` or `SHR reg, 1` is valid as an immediate.
   - Multi-bit shift: `SHL reg, N` is **illegal** on 8086 when $N > 1$. You **must** load $N$ into register `CL` first (`MOV CL, N; SHL reg, CL`).
2. **Logical vs Arithmetic Shifts**:
   - `SHL` / `SAL`: Both insert `0` on the right (LSB) and push MSB into CF.
   - `SHR`: Logical shift right; inserts `0` on the left (MSB); used for unsigned values.
   - `SAR`: Arithmetic shift right; replicates the sign bit (MSB); preserves 2's complement sign.
3. **Circular Rotations (`ROL` / `ROR`)**:
   - Rotates bits within the register without losing information; useful for byte packing/unpacking and cryptography.

---

### 3.4 Division Hygiene & Radix-10 Decomposition

* **Register Setup for 8-bit `DIV reg8`**:
  - Dividend is strictly `AX` (16-bit).
  - High byte `AH` MUST be cleared to `0` prior to dividing an 8-bit value, or it will divide `(AH * 256) + AL` instead of just `AL`.
  - Uninitialized `AH` causes the quotient to exceed 255 ($FF_{16}$), triggering an immediate CPU **Divide By Zero / Divide Error Interrupt (Fault 0)**.
* **Two-Digit Radix-10 Algorithm**:
  ```assembly
  xor ah, ah          ; Clear high byte (hygiene)
  mov bl, 10
  div bl              ; AL = quotient (tens digit), AH = remainder (units digit)
  add al, '0'         ; Convert tens digit to ASCII and display
  add ah, '0'         ; Convert units digit to ASCII and display
  ```

---
*Maintained under [Microprocessor & Assembly Lab Repository](https://github.com/b1tranger/Microprocessor_Assembly_Lab).*
