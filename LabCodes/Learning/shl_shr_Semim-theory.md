# Theory & Comparative Analysis: `shl_Semim.asm` vs. `shr_Semim.asm`

This document provides a comprehensive technical comparison, architectural breakdown, and theory guide for [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm) and [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shr_Semim.asm).

---

## Table of Contents
1. [Overview & High-Level Summary](#1-overview--high-level-summary)
2. [Key Code Differences Side-by-Side](#2-key-code-differences-side-by-side)
   - [Difference 1: The `SHL` vs `SHR` Implementation Discrepancy (Code Bug)](#difference-1-the-shl-vs-shr-implementation-discrepancy-code-bug)
   - [Difference 2: Newline String Literals (`0Dh,0Ah` vs `10,13`)](#difference-2-newline-string-literals-0dh0ah-vs-1013)
   - [Difference 3: Immediate vs. Lazy ASCII Conversion](#difference-3-immediate-vs-lazy-ascii-conversion)
3. [Microprocessor Mechanics: Shift Operations (`SHL` vs `SHR`)](#3-microprocessor-mechanics-shift-operations-shl-vs-shr)
   - [Bitwise Mechanics of `SHR` (Shift Right)](#bitwise-mechanics-of-shr-shift-right)
   - [Bitwise Mechanics of `SHL` (Shift Left)](#bitwise-mechanics-of-shl-shift-left)
   - [Mathematical Significance](#mathematical-significance)
4. [Nibble Separation and Hex Printing Mechanics](#4-nibble-separation-and-hex-printing-mechanics)
5. [Step-by-Step Execution Trace](#5-step-by-step-execution-trace)
6. [Corrected Implementation for `shl_Semim.asm`](#6-corrected-implementation-for-shl_semimasm)
7. [Summary Table of Differences](#7-summary-table-of-differences)

---

## 1. Overview & High-Level Summary

Both programs prompt the user for two single-digit decimal inputs (`num1` and `num2`), compute their integer quotient and remainder (`num2 / num1`), print both results to the console, and then compute the product (`num1 * num2`).

However, there are three primary differences:
1. **Intended Shift Operation**: [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm) is named after `SHL`, but **erroneously still contains `shr al, 1`** and uses string `msg_shr` (`'After SHR: $'`).
2. **ASCII Conversion Timing**: [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shr_Semim.asm) converts `quot` and `rem` to ASCII characters (`+48`) immediately after `div bl`, whereas [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm) delays this conversion until right before each display interrupt.
3. **Newline Representation**: [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm) uses standard DOS hex notation `0dh, 0ah` ($\text{CR} \rightarrow \text{LF}$), while [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shr_Semim.asm) uses decimal `10, 13` ($\text{LF} \rightarrow \text{CR}$).

---

## 2. Key Code Differences Side-by-Side

### Difference 1: The `SHL` vs `SHR` Implementation Discrepancy (Code Bug)

- In [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shr_Semim.asm#L77-L84):
  ```assembly
  ; Shift Right (SHR) operation on multiplication result
  shr  al, 1
  mov  bl, al ; Save result in BL for printing

  ; Print SHR message
  mov  dx, offset msg_shr
  mov  ah, 09h
  int  21h
  ```
- In [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm#L74-L81):
  ```assembly
  ; Shift Right (SHR) operation on multiplication result
  shr  al, 1          ; <--- BUG: File is named shl_Semim.asm but still executes SHR!
  mov  bl, al ; Save result in BL for printing

  ; Print SHR message
  mov  dx, offset msg_shr
  mov  ah, 09h
  int  21h
  ```
> [!WARNING]
> [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm) is currently an almost identical duplicate of [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shr_Semim.asm) regarding the shift operation. It was intended to execute `shl al, 1` and display `After SHL: `, but the author copied the block from `shr_Semim.asm` without updating the mnemonic and prompt.

---

### Difference 2: Newline String Literals (`0Dh,0Ah` vs `10,13`)

| File | Code Declaration | Representation | Order |
| :--- | :--- | :--- | :--- |
| [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm#L11-L14) | `0dh, 0ah` | Hexadecimal | `13` (CR = `\r`), then `10` (LF = `\n`) — Standard DOS |
| [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shr_Semim.asm#L11-L14) | `10, 13` | Decimal | `10` (LF = `\n`), then `13` (CR = `\r`) — Inverted Order |

While DOS video drivers in EMU8086 handle both sequences by resetting the cursor column and advancing the line, the standard convention is `0Dh, 0Ah` (CRLF).

---

### Difference 3: Immediate vs. Lazy ASCII Conversion

#### In [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shr_Semim.asm#L46-L70):
```assembly
div  bl
mov  quot, al
mov  rem, ah 
add  quot, 48        ; Immediate ASCII conversion right after DIV
add  rem, 48

; Print Quotient
mov  dx, offset msg_q
mov  ah, 09h
int  21h
;add quot, 48        ; Commented out
mov  ah, 02h
mov  dl, quot
int  21h

; Print Remainder
mov  dx, offset msg_r
mov  ah, 09h
int  21h
;add rem, 48         ; Commented out
mov  ah, 02h
mov  dl, rem
int  21h
```

#### In [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm#L46-L67):
```assembly
div  bl
mov  quot, al        ; Stored as raw numerical values
mov  rem, ah

; Print Quotient
mov  dx, offset msg_q
mov  ah, 09h
int  21h
add  quot, 48        ; Converted right before printing
mov  ah, 02h
mov  dl, quot
int  21h

; Print Remainder
mov  dx, offset msg_r
mov  ah, 09h
int  21h
add  rem, 48         ; Converted right before printing
mov  ah, 02h
mov  dl, rem
int  21h
```

**Architectural Insight**:
- Storing raw numeric values (`shl_Semim.asm`) is considered better programming practice because `quot` and `rem` remain numeric quantities if subsequent calculations are needed.
- Storing ASCII values (`shr_Semim.asm`) prevents reusing `quot` or `rem` in arithmetic without re-subtracting `48`.

---

## 3. Microprocessor Mechanics: Shift Operations (`SHL` vs `SHR`)

### Bitwise Mechanics of `SHR` (Shift Right)
`SHR destination, 1` performs an **unsigned logical right shift**:
1. All bits shift right by 1 position.
2. The Most Significant Bit (MSB, Bit 7) is filled with `0`.
3. The Least Significant Bit (LSB, Bit 0) is shifted into the **Carry Flag (CF)**.

```
+---+    +---+---+---+---+---+---+---+---+    +---+
| 0 | -> | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | -> |CF |
+---+    +---+---+---+---+---+---+---+---+    +---+
```

### Bitwise Mechanics of `SHL` (Shift Left)
`SHL destination, 1` performs an **unsigned logical left shift**:
1. All bits shift left by 1 position.
2. The Least Significant Bit (LSB, Bit 0) is filled with `0`.
3. The Most Significant Bit (MSB, Bit 7) is shifted into the **Carry Flag (CF)**.

```
+---+    +---+---+---+---+---+---+---+---+    +---+
|CF | <- | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | <- | 0 |
+---+    +---+---+---+---+---+---+---+---+    +---+
```

### Mathematical Significance
- **`SHR destination, 1`**: Computes integer division by 2 ($\lfloor X / 2 \rfloor$).
- **`SHL destination, 1`**: Computes multiplication by 2 ($X \times 2$), provided no overflow occurs.

---

## 4. Nibble Separation and Hex Printing Mechanics

Both files print the shift result in 2-digit Hexadecimal notation followed by `'H'` using the same nibble separation algorithm:

```assembly
; Print HIGH nibble
mov  al, bl
shr  al, 4           ; Moves bits 7..4 down to bits 3..0
call print_hex

; Print LOW nibble
mov  al, bl
and  al, 0Fh         ; Masks off upper 4 bits (0000 1111b)
call print_hex

; Print 'H' suffix
mov  dl, 'H'
mov  ah, 02h
int  21h
```

The procedure `print_hex` translates values `00h..0Fh` to `'0'..'9'` or `'A'..'F'`:
```assembly
print_hex proc
    add al, 48       ; Map 0..9 to '0'..'9' (ASCII 48..57)
    cmp al, 57
    jbe out_label
    add al, 7        ; Map 10..15 to 'A'..'F' (58 + 7 = 65 = 'A')
out_label:
    mov dl, al
    mov ah, 02h
    int 21h
    ret
print_hex endp
```

---

## 5. Step-by-Step Execution Trace

Assume user inputs:
- First digit `num1` = `2`
- Second digit `num2` = `6`

1. **Division**:
   - `AL = 6`, `BL = 2`, `AH = 0`
   - `DIV BL` $\rightarrow$ Quotient in `AL = 3`, Remainder in `AH = 0`.
   - Output: `Quotient = 3`, `Remainder = 0`.

2. **Multiplication**:
   - `AL = 2`, `BL = 6`
   - `MUL BL` $\rightarrow$ `AX = 000Ch` (`12` decimal, `0000 1100b`).

3. **Shift Operation Comparison**:
   - **Under `SHR AL, 1` (executed in both existing files)**:
     - Binary: `0000 1100b` $\gg 1 = 0000\ 0110_2$ (`06h`, `6` decimal).
     - High nibble: `0`
     - Low nibble: `6`
     - Output: `After SHR: 06H`
   - **Under `SHL AL, 1` (intended for `shl_Semim.asm`)**:
     - Binary: `0000 1100b` $\ll 1 = 0001\ 1000_2$ (`18h`, `24` decimal).
     - High nibble: `1`
     - Low nibble: `8`
     - Output: `After SHL: 18H`

---

## 6. Corrected Implementation for `shl_Semim.asm`

To fix `shl_Semim.asm` so that it matches its filename and performs a left shift:

```diff
-.data
-    msg_shr db 0dh,0ah,'After SHR: $'
+.data
+    msg_shl db 0dh,0ah,'After SHL: $'

-.code
-    ; Shift Right (SHR) operation on multiplication result
-    shr  al, 1
-    mov  bl, al ; Save result in BL for printing
-
-    ; Print SHR message
-    mov  dx, offset msg_shr
-    mov  ah, 09h
-    int  21h
+.code
+    ; Shift Left (SHL) operation on multiplication result
+    shl  al, 1
+    mov  bl, al ; Save result in BL for printing
+
+    ; Print SHL message
+    mov  dx, offset msg_shl
+    mov  ah, 09h
+    int  21h
```

---

## 7. Summary Table of Differences

| Feature | [`shl_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm) | [`shr_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shr_Semim.asm) | Notes / Recommendations |
| :--- | :--- | :--- | :--- |
| **Shift instruction** | `shr al, 1` (Line 75) | `shr al, 1` (Line 78) | `shl_Semim.asm` has a copy-paste bug and should use `shl al, 1`. |
| **Prompt string** | `'After SHR: $'` | `'After SHR: $'` | Should be `'After SHL: $'` in `shl_Semim.asm`. |
| **Newline literals** | `0dh, 0ah` (Hex CRLF) | `10, 13` (Dec LFCR) | Standard is `0dh, 0ah` ($13, 10$). |
| **ASCII adjustment** | Performed on-demand right before printing (`add quot, 48`). | Performed immediately after `div` (`add quot, 48`), printing code commented out. | On-demand conversion preserves numeric semantics. |
| **Nibble extraction** | `shr al, 4` & `and al, 0Fh` | `shr al, 4` & `and al, 0Fh` | Identical 2-digit Hex printing routine. |
| **Hex procedure** | Identical `print_hex` | Identical `print_hex` | Identical logic (`+48`, `cmp 57`, `+7`). |
