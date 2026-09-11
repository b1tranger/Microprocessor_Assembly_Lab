# 8086 Assembly Core Mechanics: Syntax Rules, Register Hygiene & Garbage Elimination

This guide provides an architectural breakdown of foundational 8086 Assembly quirks that cause subtle bugs, compile errors, and runtime crashes. It specifically details **why hex literals require leading zeros**, **why clearing `AH` is mandatory before arithmetic and division**, and how the 8086 CPU handles data across segmented registers.

---

## Table of Contents
1. [Hexadecimal & Literal Syntax: The "Leading Zero" Rule](#1-hexadecimal--literal-syntax-the-leading-zero-rule)
   - [1.1 Identifiers vs. Numeric Literals](#11-identifiers-vs-numeric-literals)
   - [1.2 Why `0Ah` is Valid but `Ah` Causes Compile Errors](#12-why-0ah-is-valid-but-ah-causes-compile-errors)
   - [1.3 Assembler Radix Suffix Reference Table](#13-assembler-radix-suffix-reference-table)
   - [1.4 Correct vs. Incorrect Literal Examples](#14-correct-vs-incorrect-literal-examples)
2. [Register Hygiene: Eliminating Leftover Garbage in `AH`](#2-register-hygiene-eliminating-leftover-garbage-in-ah)
   - [2.1 The Accumulator Architecture (`AX = AH : AL`)](#21-the-accumulator-architecture-ax--ah--al)
   - [2.2 The Independence Paradox (Why `AL` Does Not Reset `AH`)](#22-the-independence-paradox-why-al-does-not-reset-ah)
   - [2.3 DOS Interrupt Service Clobbering](#23-dos-interrupt-service-clobbering)
   - [2.4 The 8-Bit Division Disaster (`DIV reg8` Mechanics)](#24-the-8-bit-division-disaster-div-reg8-mechanics)
   - [2.5 Mathematical Proof of Division Overflow (#DE Fault)](#25-mathematical-proof-of-division-overflow-de-fault)
   - [2.6 Best Practices for Zeroing `AH`](#26-best-practices-for-zeroing-ah)
3. [The 16-Bit Extension: Clearing `DX` Before 16-Bit Division](#3-the-16-bit-extension-clearing-dx-before-16-bit-division)
   - [3.1 Hardware Pairing of `DX:AX`](#31-hardware-pairing-of-dxax)
   - [3.2 The `mov dx, 0` Requirement](#32-the-mov-dx-0-requirement)
4. [ASCII, Integer & Hexadecimal Data Transformations](#4-ascii-integer--hexadecimal-data-transformations)
   - [4.1 The ASCII Baseline Offset (`48` / `30h`)](#41-the-ascii-baseline-offset-48--30h)
   - [4.2 Why Hexadecimal Display Requires the `+7` Adjustment](#42-why-hexadecimal-display-requires-the-7-adjustment)
   - [4.3 Transformation Flow Diagram](#43-transformation-flow-diagram)
5. [Other Critical 8086 Hardware Constraints](#5-other-critical-8086-hardware-constraints)
   - [5.1 Segment Registers Cannot Accept Immediate Literals](#51-segment-registers-cannot-accept-immediate-literals)
   - [5.2 Memory-to-Memory Operations Are Illegal](#52-memory-to-memory-operations-are-illegal)
   - [5.3 Carriage Return (`0Dh`) vs. Line Feed (`0Ah`) Pairing](#53-carriage-return-0dh-vs-line-feed-0ah-pairing)
6. [Summary Checklist for Exam & Lab Testing](#6-summary-checklist-for-exam--lab-testing)

---

## 1. Hexadecimal & Literal Syntax: The "Leading Zero" Rule

### 1.1 Identifiers vs. Numeric Literals
In assembly language (MASM, TASM, and EMU8086), the compiler's lexical scanner parses words sequentially. It needs an unambiguous rule to distinguish **variable names, procedure names, and register names** from **raw numeric values**.

* **Rule of Identifiers**: Any token starting with a letter (`A-Z`, `a-z`) or underscore (`_`) is interpreted as a **symbol or identifier** (such as a variable, label, or register).
* **Rule of Numeric Literals**: Any token starting with a decimal digit (`0` through `9`) is parsed as a **numeric constant**.

### 1.2 Why `0Ah` is Valid but `Ah` Causes Compile Errors
Hexadecimal numbers use digits `0`-`9` and letters `A`-`F` (representing values 10 through 15).
- If you write:
  ```assembly
  mov al, Ah
  ```
  The assembler scans `A` first. Because it starts with a letter, the assembler looks for a register or variable named `Ah`. 
  - In this context, `AH` is the high-byte register, which cannot be copied into `AL` without standard syntax, or if interpreted as a variable `Ah`, the assembler throws:
    > `Error: Undefined symbol: Ah` or `Symbol not defined`
- If you write:
  ```assembly
  mov al, 0Ah
  ```
  The assembler scans `0` first. Because it starts with a numeric digit, the assembler treats the entire token as a number. It then reads the suffix `h` and correctly interprets the literal value as hexadecimal $10$.

```
Token: "Ah"   --> Starts with 'A' (Letter) --> Interpreted as IDENTIFIER/VARIABLE  --> FAILS (Undefined Symbol)
Token: "0Ah"  --> Starts with '0' (Digit)  --> Interpreted as NUMERIC LITERAL (Hex) --> SUCCEEDS (Value = 10d)
```

### 1.3 Assembler Radix Suffix Reference Table
By default, numbers without a suffix are treated as base-10 (decimal). Use the standard radix suffixes below:

| Suffix | Radix / System | Example | Decimal Value | Description / Usage |
| :---: | :---: | :---: | :---: | :--- |
| **`b`** or **`B`** | Binary (Base 2) | `00001111b` | $15$ | Bit masks, logic operations (`AND`, `OR`, `XOR`) |
| **`d`** or none | Decimal (Base 10) | `10` or `10d` | $10$ | Natural counters, loop iterations, divisor `10` |
| **`h`** or **`H`** | Hexadecimal (Base 16) | `0Ah`, `0FFh` | $10$, $255$ | DOS interrupt services, memory addresses, byte values |
| **`' '`** | ASCII Character | `'A'`, `'0'` | $65$, $48$ | Immediate character values (assembler stores ASCII code) |

### 1.4 Correct vs. Incorrect Literal Examples

```assembly
; ================= INCORRECT SYNTAX =================
mov al, Ah       ; ERROR: Assembler thinks 'Ah' is an identifier
mov bl, FFh      ; ERROR: Assembler treats 'FFh' as an unknown variable
mov dl, Dh       ; ERROR: Confused with register or undefined label
mov cl, Bh       ; ERROR: Confused with register BH

; ================== CORRECT SYNTAX ==================
mov al, 0Ah      ; CORRECT: Hexadecimal 10 (Line Feed / ASCII LF)
mov bl, 0FFh     ; CORRECT: Hexadecimal 255 (All 8 bits high)
mov dl, 0Dh      ; CORRECT: Hexadecimal 13 (Carriage Return / ASCII CR)
mov cl, 0Bh      ; CORRECT: Hexadecimal 11
mov ch, 00h      ; CORRECT: Hexadecimal 0 (explicit 8-bit hex)
```

---

## 2. Register Hygiene: Eliminating Leftover Garbage in `AH`

### 2.1 The Accumulator Architecture (`AX = AH : AL`)
The 8086 accumulator `AX` is a single physical 16-bit register partitioned into two independently addressable 8-bit registers:

```
+---------------------------------------------------------------+
|                       AX (16-bit Word)                        |
+-------------------------------+-------------------------------+
|       AH (High Byte)          |        AL (Low Byte)          |
|      Bits 15 through 8        |       Bits 7 through 0        |
+-------------------------------+-------------------------------+
```

### 2.2 The Independence Paradox (Why `AL` Does Not Reset `AH`)
When you write to `AL`, the CPU alters **only the lowest 8 bits**. The upper 8 bits in `AH` remain **completely untouched**.

```assembly
mov ax, 1234h    ; AX = 1234h (AH = 12h, AL = 34h)
mov al, 56h      ; AL updated to 56h, but AH REMAINS 12h!
                 ; Resulting AX is now 1256h (NOT 0056h!)
```

### 2.3 DOS Interrupt Service Clobbering
In DOS programs, character input is received through `INT 21H / AH=01H`:
```assembly
mov ah, 01h      ; Request character input service
int 21h          ; CPU reads character into AL
```
At the end of this interrupt:
- **`AL`** contains the entered ASCII character (e.g., `'5'` = `35h`).
- **`AH`** still contains `01h` (the DOS service code you assigned it, or undefined internal DOS flags).

If your subsequent code assumes `AX` represents just the character in `AL`, you are operating on contaminated data (`0135h` instead of `0035h`).

### 2.4 The 8-Bit Division Disaster (`DIV reg8` Mechanics)
The single most catastrophic bug in 8086 student labs involves 8-bit division (`DIV reg8` or `DIV mem8`):

> [!IMPORTANT]
> In 8086 hardware, there is **no instruction that divides only `AL`**.
> Whenever you execute `DIV reg8` (e.g., `div bl`), the CPU **always uses the full 16-bit register `AX` (`AH:AL`) as the dividend**:
> $$\text{Quotient} = \frac{AX}{\text{Operand}}, \quad \text{Remainder} = AX \pmod{\text{Operand}}$$
> - The 8-bit Quotient is placed in **`AL`**.
> - The 8-bit Remainder is placed in **`AH`**.

### 2.5 Mathematical Proof of Division Overflow (#DE Fault)

Suppose you took a single digit input from the user (e.g. `'6'`), converted it to numeric $6$, and want to divide by $2$:

```assembly
mov ah, 01h      ; Read character
int 21h          ; User presses '6' (AL = 36h = 54d, AH = 01h)

sub al, 48       ; AL = 54 - 48 = 6d
mov bl, 2        ; Divisor BL = 2

div bl           ; PERFORM 8-BIT DIVISION
```

#### What you intended:
$$\frac{AL}{BL} = \frac{6}{2} = 3 \quad (\text{Quotient } AL=3, \text{Remainder } AH=0)$$

#### What the 8086 hardware actually does:
Because you did not clear `AH`, `AH` still holds `01h` from `INT 21H`!
- High byte `AH` = `01h`
- Low byte `AL` = `06h`
- Dividend `AX` = `0106h` = $262$ in decimal!

$$\text{Calculation} = \frac{262}{2} = 131$$

* Since the maximum value an 8-bit register (`AL`) can hold in signed arithmetic is $127$ (or if the quotient exceeds 255 in unsigned arithmetic), or if the quotient does not fit in `AL`, the CPU immediately triggers **Hardware Interrupt 0: Divide Error Fault (`#DE`)**.
* The program abruptly crashes with:
  > `Divide overflow` or `Divide Error - program terminated`

```
Contaminated AX:
+-------------------------------+-------------------------------+
|         AH = 01h              |         AL = 06h              |
+-------------------------------+-------------------------------+
   Combined 16-bit Value = 0106h = 262 (Decimal)
   Divided by BL (2) = Quotient 131
   Result: 131 does NOT match expected 3, or causes Divide Error!
```

### 2.6 Best Practices for Zeroing `AH`
Whenever preparing `AL` for arithmetic, decomposition (`div bl`), or printing digits, always clear `AH`:

```assembly
; Technique 1: Direct Immediate Assignment (Explicit & Clear)
mov ah, 00h
mov al, [number]
div bl           ; AX is guaranteed to equal exactly AL

; Technique 2: Zeroing via XOR (Fastest & 1-byte opcode)
xor ah, ah       ; Clears AH to 0 by XORing register with itself

; Technique 3: Unsigned Byte to Word Extension (CBW is for signed only!)
; Use 'mov ah, 0' for unsigned numbers.
; Use 'cbw' (Convert Byte to Word) ONLY for signed numbers (sign-extends AL bit 7 into AH).
```

---

## 3. The 16-Bit Extension: Clearing `DX` Before 16-Bit Division

### 3.1 Hardware Pairing of `DX:AX`
Just as 8-bit division uses `AX` (`AH:AL`), **16-bit division** (`DIV reg16`, e.g. `div bx`) divides a **32-bit doubleword dividend**:

```
+---------------------------------------------------------------+
|                   32-bit Dividend (DX:AX)                     |
+-------------------------------+-------------------------------+
|       DX (Upper 16 bits)      |       AX (Lower 16 bits)      |
+-------------------------------+-------------------------------+
```

$$\text{Quotient} = \frac{DX:AX}{BX} \longrightarrow \text{Stored in } \mathbf{AX}$$
$$\text{Remainder} = DX:AX \pmod{BX} \longrightarrow \text{Stored in } \mathbf{DX}$$

### 3.2 The `mov dx, 0` Requirement
If you want to divide a 16-bit number stored in `AX` by `BX`:
```assembly
; ================= INCORRECT =================
mov ax, 1000     ; Dividend
mov bx, 10       ; Divisor
div bx           ; CRASH! If DX has leftover garbage from INT 21H / AH=09H,
                 ; DX:AX will be in the millions, causing Divide Overflow!

; ================== CORRECT ==================
mov ax, 1000     ; Dividend
mov dx, 0        ; EXPLICITLY CLEAR HIGH 16 BITS!
mov bx, 10       ; Divisor
div bx           ; AX = 100 (Quotient), DX = 0 (Remainder)
```

---

## 4. ASCII, Integer & Hexadecimal Data Transformations

### 4.1 The ASCII Baseline Offset (`48` / `30h`)
Characters in memory do not hold raw numeric values; they hold **ASCII encoding indexes**:
- Character `'0'` = ASCII $48$ (`30h`)
- Character `'9'` = ASCII $57$ (`39h`)

To switch between text representation and raw math:
```assembly
; ASCII Character to Integer Number (Input):
sub al, '0'      ; Equivalent to: sub al, 48 (or sub al, 30h)

; Integer Number to ASCII Character (Output):
add al, '0'      ; Equivalent to: add al, 48 (or add al, 30h)
```

### 4.2 Why Hexadecimal Display Requires the `+7` Adjustment
In the ASCII table, digits `'0'-'9'` end at index $57$, but the uppercase alphabet `'A'-'Z'` does **not** start at $58$. There is a **7-character punctuation gap**:

```
ASCII Index:  55   56   57   58   59   60   61   62   63   64   65   66
Character:    '7'  '8'  '9'  ':'  ';'  '<'  '='  '>'  '?'  '@'  'A'  'B'
                               ^-------------------------^
                                  7-Character Gap!
```

When converting a 4-bit nibble ($0$ to $15$) to a printable hexadecimal character:
1. First, add `'0'` ($+48$).
   - If the nibble is between $0$ and $9$: Result is between $48$ and $57$ (`'0'` through `'9'`). This is correct.
2. If the nibble is between $10$ and $15$ (`0Ah` to `0Fh`):
   - Adding $48$ produces $10 + 48 = 58$ (which prints the colon `:` instead of `'A'`).
   - Adding an **extra $+7$** bridges the punctuation gap:
     $$10 + 48 + 7 = 65 \longrightarrow \text{'A'}$$
     $$15 + 48 + 7 = 70 \longrightarrow \text{'F'}$$

```assembly
convert_hex_digit:
    add dl, 48       ; Base ASCII offset
    cmp dl, 57       ; Is it greater than '9'?
    jbe print_digit  ; If <= '9', it is 0-9, print directly
    add dl, 7        ; If > '9', bridge the 7-character gap to reach 'A'-'F'

print_digit:
    mov ah, 02h
    int 21h
    ret
```

---

## 5. Other Critical 8086 Hardware Constraints

### 5.1 Segment Registers Cannot Accept Immediate Literals
The 8086 CPU instruction decoder does not support encoding an immediate 16-bit constant directly into segment registers (`DS`, `ES`, `SS`, `CS`).

```assembly
; ILLEGAL INSTRUCTION:
mov ds, @data    ; COMPILER ERROR: Direct immediate to segment register illegal

; REQUIRED TWO-STEP SEQUENCE:
mov ax, @data    ; 1. Load memory segment base into general accumulator AX
mov ds, ax       ; 2. Transfer segment base from AX into Data Segment (DS)
```

### 5.2 Memory-to-Memory Operations Are Illegal
In 8086 CISC microarchitecture, an instruction can have at most **one memory operand**. You cannot transfer data directly between two RAM addresses:

```assembly
; ILLEGAL INSTRUCTION:
mov [di], [si]   ; COMPILER ERROR: Memory to memory move not allowed

; REQUIRED TWO-STEP SEQUENCE:
mov al, [si]     ; Read source RAM byte into CPU register
mov [di], al     ; Write CPU register into destination RAM byte
```

### 5.3 Carriage Return (`0Dh`) vs. Line Feed (`0Ah`) Pairing
In DOS console I/O, a new line requires two distinct mechanical typewriter operations:
1. **Carriage Return (`13` / `0Dh` / `'\r'`)**: Moves the cursor horizontally back to the **far-left column (column 0)**.
2. **Line Feed (`10` / `0Ah` / `'\n'`)**: Moves the cursor vertically down to the **next row** without resetting the column.

```assembly
; If you ONLY print 10 (Line Feed):
; Line 1
;       Line 2 (Stair-stepping bug!)

; Standard Newline Procedure:
print_newline:
    mov ah, 02h
    mov dl, 0Dh      ; Carriage Return (Return cursor to column 0)
    int 21h
    mov dl, 0Ah      ; Line Feed (Advance cursor down one line)
    int 21h
    ret
```

---

## 6. Summary Checklist for Exam & Lab Testing

| Rule / Pitfall | Danger if Ignored | Required Fix |
| :--- | :--- | :--- |
| **Hex constants starting with A-F** | Assembler fails with `Undefined symbol` | Prepend a `0`: `0Ah`, `0FFh`, `0BAh` |
| **Leftover `AH` before `DIV reg8`** | Divide Error Fault (`#DE`) or wildly incorrect quotient | Always write `mov ah, 00h` before 8-bit division |
| **Leftover `DX` before `DIV reg16`** | 32-bit division overflow crash | Always write `mov dx, 0000h` before 16-bit division |
| **Arithmetic on raw input characters** | Adding `'2'` + `'3'` gives $50 + 51 = 101$ (`'e'`) | Strip ASCII base: `sub al, 48` before math |
| **Hex character conversion (`0Ah-0Fh`)** | Prints punctuation symbols (`:`, `;`, `<`, `=`, `>`, `?`) | Add $+7$ after adding $48$ if value $> 57$ |
| **Direct assignment to `DS`** | Assembler reject: Invalid addressing | Route through accumulator: `mov ax, @data; mov ds, ax` |
| **Printing without `0Dh` (CR)** | Diagonal stair-stepping text on screen | Always print both `0Dh` (CR) and `0Ah` (LF) |
