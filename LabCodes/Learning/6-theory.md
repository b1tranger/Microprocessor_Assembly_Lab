# Understanding `AX` Register Overwrites & Register Aliasing in 8086 Assembly

In 8086 microprocessor assembly programming, unexpected bugs often arise from accumulator register overwrites. This document explains the architectural reasons why the `AX` register (and its sub-registers `AH` and `AL`) can be modified or corrupted during code execution, followed by two comparative code examples.

---

## Table of Contents
1. [Architecture of the `AX` Register](#1-architecture-of-the-ax-register)
2. [Why Does `AX` / `AL` Get Corrupted?](#2-why-does-ax--al-get-corrupted)
3. [Case 1: Value Corrupted Due to Leftover Value in `AH`](#3-case-1-value-corrupted-due-to-leftover-value-in-ah)
4. [Case 2: Output Kept Intact by Explicitly Clearing `AH` (`mov ah, 0`)](#4-case-2-output-kept-intact-by-explicitly-clearing-ah-mov-ah-0)
5. [Summary & Best Practices](#5-summary--best-practices)
6. [Character Case Conversion & Bitwise XOR Toggling](#6-character-case-conversion--bitwise-xor-toggling)
   - [6.1 The ASCII Case Bit Property (Bit 5 Alignment)](#61-the-ascii-case-bit-property-bit-5-alignment)
   - [6.2 Comparison of Conversion Approaches](#62-comparison-of-conversion-approaches)
   - [6.3 Bitwise Masking with XOR Under the Hood](#63-bitwise-masking-with-xor-under-the-hood)
   - [6.4 String Definition & Embedded CRLF (`DB 13, 10`)](#64-string-definition--embedded-crlf-db-13-10)
   - [6.5 Address Loading: `MOV DX, OFFSET` vs `LEA DX`](#65-address-loading-mov-dx-offset-vs-lea-dx)
   - [6.6 Comparative Code Implementations (`6.1_CP.asm` vs `6.1_CP-alt.asm`)](#66-comparative-code-implementations-61_cpasm-vs-61_cp-altasm)

---

## 1. Architecture of the `AX` Register

The `AX` register is a **16-bit general-purpose accumulator** in the 8086 CPU. It is physically partitioned into two independently addressable 8-bit registers:

```
+-----------------------------------+
|               AX                  | (16-bit Accumulator)
+-----------------+-----------------+
|       AH        |       AL        |
| (Bits 15 - 8)   |  (Bits 7 - 0)   |
|   High Byte     |    Low Byte     |
+-----------------+-----------------+
```

### Key Architectural Characteristics:
1. **Shared Physical Storage (Register Aliasing)**: 
   - `AX` is **not** a third separate register. Any write to `AH` or `AL` instantly alters the value of `AX`.
   - Formula: $\text{AX} = (\text{AH} \times 256) + \text{AL} = (\text{AH} \ll 8) \mid \text{AL}$.
2. **Implicit Register Usage**:
   - **Division (`DIV operand8`)**: The 8086 requires the dividend to be a 16-bit value located in `AX`. It performs $\text{AX} \div \text{operand8}$, storing the quotient in `AL` and the remainder in `AH`.
   - **Multiplication (`MUL operand8`)**: Multiplies $\text{AL} \times \text{operand8}$, storing the 16-bit result across `AH:AL` (`AX`).
3. **DOS Interrupt Services (`INT 21h`)**:
   - DOS function calls use `AH` to select service routines (e.g., `AH = 1` for Character Input, `AH = 2` for Character Output, `AH = 9` for String Display).
   - Some interrupt routines return data in `AL` (e.g., `AH = 1` sets `AL` to the input ASCII code).

---

## 2. Why Does `AX` / `AL` Get Corrupted?

### Reason 1: Leftover High Byte in `AH` Before 8-bit `DIV`
When performing 8-bit division (`div reg8`), the CPU expects the full 16-bit register `AX` as the dividend, **not just `AL`**.
If `AH` previously held a DOS function number (such as `mov ah, 2` for character display) or any leftover calculation value, `AX` becomes:
$$\text{AX} = 02\text{xxh} \quad (\text{instead of } 00\text{xxh})$$

When `div` runs, it divides $02\text{xxh}$ rather than $00\text{xxh}$, producing an incorrect quotient in `AL` and incorrect remainder in `AH` (or triggering a divide error / `INT 0` overflow if quotient $\ge 256$).

### Reason 2: Overwriting `AL` via DOS Function Calls
Calling `INT 21h` with `AH = 1` immediately overwrites whatever value was previously held in `AL`.

---

## 3. Case 1: Value Corrupted Due to Leftover Value in `AH`

In this scenario:
1. The initial value (`14`) is placed in `AL` and copied to `BL`.
2. Some intermediate operations execute that modify `AH` (e.g., `mov ah, 2` to print a space character).
3. The program attempts to divide `AL` by `10` to get the digits, but **forgets to clear `AH`**.
4. The 8-bit `div` instruction reads the full dirty `AX` ($020\text{Eh} = 526$), giving completely erroneous quotient and remainder values at output.

### Code Example 1 (Buggy Execution)

```assembly
.MODEL SMALL
.STACK 100H
.DATA
    QUOT DB ?
    REM  DB ?
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Load initial value (14) into AL and preserve in BL
    MOV AL, 14       ; AL = 14 (0Eh), AH = 00h -> AX = 000Eh
    MOV BL, AL       ; BL = 14

    ; 2. Perform some other execution modifying AH (e.g. printing a space)
    MOV AH, 2        ; AH is now 02h! (AX is now 020Eh = 526 in decimal)
    MOV DL, 32       ; ASCII for Space ' '
    INT 21H          ; DOS interrupt output

    ; 3. Divide by 10 to display double-digit number
    MOV BH, 10
    ; BUG: AH is still 2 from the previous 'MOV AH, 2'
    ; CPU performs AX / BH => 526 / 10 = quotient 52 (34h), remainder 6 (06h)
    DIV BH           

    ; 4. Convert and store outputs
    ADD AL, 48       ; AL = 52 + 48 = 100 ('d' in ASCII instead of '1'!)
    ADD AH, 48       ; AH = 6 + 48 = 54 ('6' in ASCII instead of '4'!)
    MOV QUOT, AL
    MOV REM, AH

    ; 5. Print Quotient
    MOV AH, 2
    MOV DL, QUOT
    INT 21H          ; Prints 'd' (corrupted!)

    ; 6. Print Remainder
    MOV AH, 2
    MOV DL, REM
    INT 21H          ; Prints '6' (corrupted!)

    ; Exit Program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
```

### Trace Table for Case 1

| Instruction | `AH` | `AL` | `AX` | `BL` | Notes |
|---|---|---|---|---|---|
| `MOV AL, 14` | `00h` | `0Eh` | `000Eh` (14) | - | Initial load |
| `MOV BL, AL` | `00h` | `0Eh` | `000Eh` (14) | `0Eh` | Stored in `BL` |
| `MOV AH, 2` | `02h` | `0Eh` | `020Eh` (526) | `0Eh` | `AH` altered by service call setup |
| `INT 21H` | `02h` | `0Eh` | `020Eh` (526) | `0Eh` | Space printed, `AX` is dirty |
| `DIV BH` (BH=10) | `06h` | `34h` (52) | `0634h` | `0Eh` | **Corrupted!** Divided 526 instead of 14 |

---

## 4. Case 2: Output Kept Intact by Explicitly Clearing `AH` (`mov ah, 0`)

In this scenario:
1. `mov ah, 0` is explicitly executed before 8-bit division (as seen in [`4.1_CP.asm:L119`](file:///c:/Users/gsmur/OneDrive/Documents/GitHub/Microprocessor_Assembly_Lab/LabCodes/4.1_CP.asm#L119)).
2. `AX` becomes $000\text{Eh} = 14$.
3. The division $14 \div 10$ yields quotient `1` and remainder `4`, keeping the output accurate and intact.

### Code Example 2 (Corrected Execution)

```assembly
.MODEL SMALL
.STACK 100H
.DATA
    QUOT DB ?
    REM  DB ?
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Load initial value (14) into AL and preserve in BL
    MOV AL, 14       ; AL = 14 (0Eh)
    MOV BL, AL       ; BL = 14

    ; 2. Perform other execution modifying AH (e.g. printing a space)
    MOV AH, 2        ; AH = 02h
    MOV DL, 32       ; ASCII for Space ' '
    INT 21H          ; DOS interrupt output

    ; 3. Prepare for division by restoring AL and clearing AH
    MOV BH, 10
    MOV AL, BL       ; AL = 14
    
    MOV AH, 0        ; FIX: Clear high byte! AX is now 000Eh (14 decimal)

    DIV BH           ; AX / BH => 14 / 10 = Quotient AL = 1, Remainder AH = 4

    ; 4. Convert to ASCII
    ADD AL, 48       ; AL = 1 + 48 = 49 ('1')
    ADD AH, 48       ; AH = 4 + 48 = 52 ('4')
    MOV QUOT, AL
    MOV REM, AH

    ; 5. Print Quotient
    MOV AH, 2
    MOV DL, QUOT
    INT 21H          ; Prints '1' (correct!)

    ; 6. Print Remainder
    MOV AH, 2
    MOV DL, REM
    INT 21H          ; Prints '4' (correct!)

    ; Exit Program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
```

### Trace Table for Case 2

| Instruction | `AH` | `AL` | `AX` | `BL` | Notes |
|---|---|---|---|---|---|
| `MOV AL, 14` | `00h` | `0Eh` | `000Eh` (14) | - | Initial load |
| `MOV BL, AL` | `00h` | `0Eh` | `000Eh` (14) | `0Eh` | Stored in `BL` |
| `MOV AH, 2` | `02h` | `0Eh` | `020Eh` (526) | `0Eh` | `AH` altered |
| `INT 21H` | `02h` | `0Eh` | `020Eh` (526) | `0Eh` | Space printed |
| `MOV AL, BL` | `02h` | `0Eh` | `020Eh` (526) | `0Eh` | Reload `AL` from `BL` |
| `MOV AH, 0` | `00h` | `0Eh` | `000Eh` (14) | `0Eh` | **Clean AX!** High byte is zeroed |
| `DIV BH` (BH=10) | `04h` | `01h` | `0401h` | `0Eh` | **Correct!** `AL` = 1, `AH` = 4 |

---

## 5. Summary & Best Practices

1. **Always Clear `AH` Before 8-bit `DIV`**:
   - Use `mov ah, 0` (for unsigned numbers) or `cbw` (*Convert Byte to Word*, for signed numbers) before invoking `div` or `idiv`.
2. **Preserve Registers Across Interrupt Calls**:
   - `INT 21h` routines and DOS function setup overwrite `AH` (and often `AL`). If a value in `AL` or `AH` is needed later, save it to another register (`BL`, `CL`) or push it to the stack (`PUSH AX` / `POP AX`).
3. **Remember Register Aliasing**:
   - Any modification to `AH` or `AL` directly modifies `AX`.

---

## 6. Character Case Conversion & Bitwise XOR Toggling

In Lab 6, the task is to read an ASCII alphabetic character from the console and convert or toggle its case. Understanding the underlying binary bit layout of ASCII glyphs enables elegant bitwise solutions that avoid branching and conditional jumps.

### 6.1 The ASCII Case Bit Property (Bit 5 Alignment)

In standard 7-bit / 8-bit ASCII encoding, uppercase and lowercase Latin characters are systematically paired:

$$\text{'a'} = 01100001_2 = 61_{16} = 97_{10}$$
$$\text{'A'} = 01000001_2 = 41_{16} = 65_{10}$$

Notice the bitwise layout of the entire alphabet:
- **Bits 0–4 (Weights $2^0$ through $2^4$, values $1$ to $26$)**: Represent the 1-based alphabetical index ($1 = \text{'A'/'a'}, 2 = \text{'B'/'b'}, \dots, 26 = \text{'Z'/'z'}$).
- **Bit 5 (Weight $2^5 = 32_{10} = 20_{16}$)**: **The Case Selector Bit**.
  - Lowercase characters have Bit 5 = `1` (`61h` to `7Ah`).
  - Uppercase characters have Bit 5 = `0` (`41h` to `5Ah`).
- **Bits 6–7**: Fixed prefix `01b` designating printable uppercase and lowercase alphabetic blocks.

Because the numerical gap between `'a'` and `'A'` is exactly $97 - 65 = 32_{10} = 20_{16}$, case conversion is fundamentally a manipulation of **Bit 5**.

### 6.2 Comparison of Conversion Approaches

| Approach | Assembly Instruction | Mechanism | Pros & Cons |
| :--- | :--- | :--- | :--- |
| **Arithmetic Subtraction** | `SUB AL, 20h` (or `SUB AL, 32`) | $\text{AL} \leftarrow \text{AL} - 32$ | **Pros**: Simple arithmetic.<br>**Cons**: Unidirectional (Lower $\rightarrow$ Upper only). Passing uppercase `'A'` gives `'!'` ($65 - 32 = 33$). |
| **Arithmetic Addition** | `ADD AL, 20h` (or `ADD AL, 32`) | $\text{AL} \leftarrow \text{AL} + 32$ | **Pros**: Simple arithmetic.<br>**Cons**: Unidirectional (Upper $\rightarrow$ Lower only). Passing lowercase `'a'` produces non-ASCII garbage ($97 + 32 = 129$). |
| **Bitwise Force (AND/OR)** | `AND AL, 0DFh`<br>`OR AL, 20h` | Clears Bit 5 (`11011111b`)<br>Sets Bit 5 (`00100000b`) | **Pros**: Idempotent. Guarantees valid target case even if already in that case.<br>**Cons**: Directional; cannot dynamically toggle. |
| **Bitwise Inversion (XOR)** | `XOR AL, 32`<br>*(or `XOR AL, 20h`)* | $\text{AL} \leftarrow \text{AL} \oplus 00100000_2$ | **Pros**: **Universal Bidirectional Toggle**. Automatically inverts Lower $\rightarrow$ Upper AND Upper $\rightarrow$ Lower in a single opcode without conditional jumps! |

### 6.3 Bitwise Masking with XOR Under the Hood

The Exclusive-OR (`XOR`) operation follows two axiomatic truth tables for any bit $x$:

$$x \oplus 0 = x \quad \text{(Bit preserved)}$$
$$x \oplus 1 = \text{NOT}(x) \quad \text{(Bit inverted / toggled)}$$

To selectively toggle Bit 5 without disturbing any of the other 7 bits, we construct an 8-bit mask where **only Bit 5 is `1`**:

$$\text{Binary Mask} = 00100000_2 = 32_{10} = 20_{16}$$

#### Bit-by-Bit Transformation Trace:

1. **Lowercase to Uppercase (`'a' \rightarrow 'A'`)**:
   ```
   Bit Index:      7 6 5 4 3 2 1 0
   AL ('a'):       0 1 1 0 0 0 0 1  (97 dec / 61h)
   Mask (32):      0 0 1 0 0 0 0 0  (32 dec / 20h)
   --------------------------------- (XOR)
   Result ('A'):   0 1 0 0 0 0 0 1  (65 dec / 41h)
                       ^
                Bit 5 flipped (1 -> 0)
   ```

2. **Uppercase to Lowercase (`'A' \rightarrow 'a'`)**:
   ```
   Bit Index:      7 6 5 4 3 2 1 0
   AL ('A'):       0 1 0 0 0 0 0 1  (65 dec / 41h)
   Mask (32):      0 0 1 0 0 0 0 0  (32 dec / 20h)
   --------------------------------- (XOR)
   Result ('a'):   0 1 1 0 0 0 0 1  (97 dec / 61h)
                       ^
                Bit 5 flipped (0 -> 1)
   ```

### 6.4 String Definition & Embedded CRLF (`DB 13, 10`)

When structuring console user interfaces, moving to a new line typically requires emitting both:
1. **Carriage Return (`CR = 13` / `0Dh`)**: Repositions cursor to column 0 (far-left margin).
2. **Line Feed (`LF = 10` / `0Ah`)**: Advances cursor down to the subsequent row.

#### Verbose Approach (Multiple Interrupt Calls):
```assembly
mov ah, 02h
mov dl, 10          ; Line Feed
int 21h
mov dl, 13          ; Carriage Return
int 21h
```

#### Optimized Approach (Embedded Control Bytes in `.DATA`):
```assembly
MSG2 DB 13, 10, 'Output: $'
```
When DOS service `INT 21H / AH=09H` outputs `MSG2`, it processes byte `13` and byte `10` as control instructions before printing the string characters, completely avoiding extra instruction bytes and saving CPU cycles.

### 6.5 Address Loading: `MOV DX, OFFSET` vs `LEA DX`

| Dimension | `MOV DX, OFFSET label` | `LEA DX, label` |
| :--- | :--- | :--- |
| **Instruction Meaning** | Move Immediate Offset | Load Effective Address |
| **Resolution Phase** | **Assemble-time** (Compile-time) | **Run-time** (Executed by CPU ALU) |
| **Machine Opcode Size** | Typically 3 bytes (`BA [Low] [High]`) | Typically 4 bytes (`8D 16 [Disp]`) |
| **Execution Latency** | Faster (Immediate literal copy) | Adds ALU effective address calculation cycle |
| **Flexibility** | Fixed labels only; cannot index registers | Computes register arithmetic: `LEA SI, [BX + DI + 4]` |
| **Exam Recommendation** | Recommended for static strings in `.DATA` | Widely used across textbooks and assemblers for clarity |

### 6.6 Comparative Code Implementations (`6.1_CP.asm` vs `6.1_CP-alt.asm`)

#### Primary Approach: Arithmetic Subtraction (`6.1_CP.asm`)
```assembly
.model small
.stack 100h
.data
    msg1 db "Input: $"
    msg2 db "Output : $"
    char db ?

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Prompt Input
    mov dx, offset msg1
    mov ah, 09h
    int 21h

    ; Read character into AL
    mov ah, 01h
    int 21h

    ; Subtraction conversion
    sub al, 20h
    mov char, al

    ; Manual CRLF
    mov ah, 02h
    mov dl, 10
    int 21h
    mov ah, 02h
    mov dl, 13
    int 21h

    ; Print Output
    mov dx, offset msg2
    mov ah, 09h
    int 21h

    mov ah, 02h
    mov dl, char
    int 21h

exit:
    mov ah, 4ch
    int 21h
main endp
end main
```

#### Alternative Approach: Bitwise XOR Toggling (`6.1_CP-alt.asm`)
```assembly
.MODEL SMALL
.STACK 100H
.DATA
    MSG1 DB 'Input: $'
    MSG2 DB 13, 10, 'Output: $'      ; Embedded CR and LF control characters

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Display input prompt
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    ; 2. Take input
    MOV AH, 01H
    INT 21H

    ; 3. Universal bidirectional case toggle
    XOR AL, 32                      ; Decimal 32 = 20h = 00100000b

    ; 4. Preserve converted character
    MOV BL, AL

    ; 5. Output message (automatically issues CRLF first)
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H

    ; 6. Display converted character
    MOV DL, BL
    MOV AH, 02H
    INT 21H

    ; 7. Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
```

