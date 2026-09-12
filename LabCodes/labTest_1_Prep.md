# Lab Test 1 Preparation Guide: Comprehensive Topic Summary & Code Walkthrough

This document serves as a master revision guide for **Lab Test 1**, synthesizing the theoretical principles, architectural mechanisms, and code implementations covered across **Lab 1 through Lab 7** in the 8086 Microprocessor & Assembly Language laboratory.

---

## Table of Contents
1. [Master Lab Reference & Algorithm Mapping Table](#1-master-lab-reference--algorithm-mapping-table)
2. [Lab-by-Lab Deep Dive & Code Walkthroughs](#2-lab-by-lab-deep-dive--code-walkthroughs)
   - [2.1 Lab 1: Environment Setup & Direct String Display](#21-lab-1-environment-setup--direct-string-display)
   - [2.2 Lab 2: Character I/O, Formatting & Multi-Input Staging](#22-lab-2-character-io-formatting--multi-input-staging)
     - [2.2.1 Character Echo & Whitespace / Newline Sequences](#221-character-echo--whitespace--newline-sequences)
     - [2.2.2 Staged Multi-Input Buffering & Prompt Interleaving](#222-staged-multi-input-buffering--prompt-interleaving)
   - [2.3 Lab 3: Single-Digit Arithmetic & Multi-Digit Output Decomposition](#23-lab-3-single-digit-arithmetic--multi-digit-output-decomposition)
     - [2.3.1 Fundamental 4-Operation Arithmetic](#231-fundamental-4-operation-arithmetic)
     - [2.3.2 Multi-Digit Output Decomposition via Radix-10 Division](#232-multi-digit-output-decomposition-via-radix-10-division)
   - [2.4 Lab 4: Compound Academic Marks Calculation & Averages](#24-lab-4-compound-academic-marks-calculation--averages)
   - [2.5 Lab 5: Bitwise Operations & Hexadecimal Conversion Subroutines](#25-lab-5-bitwise-operations--hexadecimal-conversion-subroutines)
   - [2.6 Lab 6: Character Case Conversion & Bitwise Toggling](#26-lab-6-character-case-conversion--bitwise-toggling)
   - [2.7 Lab 7: Loops, Conditional Filtering & 1D Array Processing](#27-lab-7-loops-conditional-filtering--1d-array-processing)
     - [2.7.1 Hardware Loops & Alphabet Traversal](#271-hardware-loops--alphabet-traversal)
     - [2.7.2 Conditional Element Filtering & Jump-Based Loops](#272-conditional-element-filtering--jump-based-loops)
     - [2.7.3 1D Array Declaration & Pointer Traversal](#273-1d-array-declaration--pointer-traversal)
     - [2.7.4 Linear Array Summation & Accumulator Patterns](#274-linear-array-summation--accumulator-patterns)
3. [High-Yield Exam Cheat Sheet & Architecture Mechanics](#3-high-yield-exam-cheat-sheet--architecture-mechanics)
   - [3.1 DOS Interrupt 21h Service Summary](#31-dos-interrupt-21h-service-summary)
   - [3.2 8086 Hardware Division Rules](#32-8086-hardware-division-rules)
   - [3.3 ASCII & Radix Conversion Rules](#33-ascii--radix-conversion-rules)
   - [3.4 Address Loading & String Formatting Cheatsheet](#34-address-loading--string-formatting-cheatsheet)
   - [3.5 Top 5 Common Exam Bugs & Pitfalls](#35-top-5-common-exam-bugs--pitfalls)

> [!TIP]
> For deep architectural explanations of the **leading zero rule on hex literals (`0Ah`)**, **register hygiene & clearing `AH` before `DIV`**, and 8086 hardware constraints, see the companion guide: [`assembly_core_mechanics.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/assembly_core_mechanics.md).

---

## 1. Master Lab Reference & Algorithm Mapping Table

The table below outlines each lab, the specific files implemented, the primary algorithms employed, and the foundational 8086 hardware and software concepts required.

| Lab | Source File(s) | Primary Algorithm / Task | Core Concepts & Prerequisites Required | Key Registers & Services | Common Exam Pitfalls |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Lab 1** | [`1.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-1/1.1.asm)<br>[`lab-1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-1/lab-1.asm) *(Identical)* | **Direct String Display**<br>Load address of a string in memory and print it to standard output. | • Memory segmentation (`.DATA`, `.CODE`, `.STACK`)<br>• Initializing `DS` through accumulator `AX`<br>• Effective offset calculation (`OFFSET`)<br>• String termination using `$` | `DS`, `AX`<br>`DX` (string pointer)<br>`INT 21H / AH=09H`<br>`INT 21H / AH=4CH` | Forgetting `mov ds, ax`, resulting in garbage data or null pointer display. Omitting `$` at string tail. |
| **Lab 2** | [`2.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2/2.1.asm)<br>[`2.2.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2/2.2.asm)<br>[`2.3.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2/2.3.asm)<br>[`2.3-alt.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2/2.3-alt.asm) | **Character I/O & Formatting**<br>Echoing single/multiple characters with formatted whitespace, CR (13), and LF (10). | • Console character input & output interrupts<br>• ASCII control characters (`10 = LF`, `13 = CR`, `32 = Space`)<br>• Staging multiple user inputs into separate 8-bit registers (`BL`, `BH`) | `AL` (input receiver)<br>`DL` (output carrier)<br>`BL`, `BH` (staging)<br>`INT 21H / AH=01H`<br>`INT 21H / AH=02H` | Forgetting carriage return (`13`) alongside line feed (`10`), causing diagonal cursor stair-stepping. Overwriting `AL` before saving previous input. |
| **Lab 3** | [`3.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-3/3.1.asm)<br>[`3.2.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-3/3.2.asm) | **Single-Digit Arithmetic & 2-Digit Decimal Decomposition**<br>Perform `+`, `-`, `*`, `/` and split two-digit results into tens and units digits. | • ASCII to integer conversion (`- 48`)<br>• Integer to ASCII conversion (`+ 48`)<br>• Hardware multiplication (`MUL`) & division (`DIV`) register implicit destinations<br>• Radix-10 decomposition via `DIV 10` | `AL` (multiplier/dividend)<br>`AH` (remainder receiver)<br>`AX` (16-bit product / dividend)<br>`INT 21H / AH=02H` | Performing arithmetic directly on raw ASCII characters. Failing to isolate remainder (`AH`) and quotient (`AL`) after division. |
| **Lab 4** | [`4.1_CP.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-4/4.1_CP.asm) | **Compound Marks Accumulation & Average Calculation**<br>Take 3 course grades, compute total marks, format 2-digit sum, and compute integer average. | • Sequential variable allocation in `.DATA`<br>• Multi-operand accumulation<br>• Clearing high byte `AH=0` before 8-bit division to prevent divide overflow exceptions<br>• Interleaved user prompts | `AL` (sum & dividend)<br>`AH` (zeroed out, then remainder)<br>`BL`, `BH` (divisors)<br>`INT 21H / AH=09H, 01H, 02H` | Leaving uninitialized garbage in `AH` before running `DIV reg8`, which triggers CPU Divide Error interrupt (Fault #DE). |
| **Lab 5** | [`5.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-5/5.1.asm) | **Bitwise Manipulation & 2-Digit Hexadecimal Subroutine**<br>Apply bitwise `OR`, separate upper and lower nibbles, and convert to ASCII hex characters ('0'-'9', 'A'-'F'). | • Logical operations (`OR`, `AND`, `SHR`)<br>• Nibble isolation (shift upper nibble by 4; mask lower nibble with `0Fh`)<br>• Subroutine modularity (`CALL`, `RET`, stack tracking)<br>• Conditional ASCII hex adjustment (`+48`, `CMP 57`, `JBE`, `+7`) | `AL` (data byte / nibble)<br>`BL` (preservation register)<br>`DL` (output carrier)<br>`FLAGS` (CF, ZF from `CMP`) | Missing the `+7` offset for hex digits `10-15` (`0Ah-0Fh` $\rightarrow$ `'A'-'F'`). Forgetting `RET` in `PROC`, causing the CPU to execute subsequent memory fall-through. |
| **Lab 6** | [`6.1_CP.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-6/6.1_CP.asm)<br>[`6.1_CP-alt.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-6/6.1_CP-alt.asm) *(XOR Case Toggling)* | **Character Case Conversion & Toggling**<br>Read an ASCII character and convert or toggle its case (lower $\leftrightarrow$ upper) using arithmetic subtraction or bitwise XOR masking. | • ASCII binary encoding scheme (bit 5 determines case: `'a' = 61h`, `'A' = 41h`)<br>• Subtractive arithmetic conversion (`SUB AL, 20h`)<br>• Universal bitwise case toggling (`XOR AL, 32` / `20h`)<br>• Embedded CRLF string formatting (`DB 13, 10, ...`)<br>• Address loading mechanics (`LEA` vs `OFFSET`) | `AL` (input, conversion & toggling)<br>`BL` (preservation register)<br>`DL` (output carrier)<br>`INT 21H / AH=01H, 02H, 09H` | Modifying character without validating bounds, confusing whether to `ADD 20h` or `SUB 20h`, or using `SUB 20h` on uppercase input (which produces non-alphabetic ASCII). |
| **Lab 7** | [`7.1_loop.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/7.1_loop.asm)<br>[`7.2_task.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/7.2_task.asm)<br>[`7.3_Array.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/7.3_Array.asm)<br>[`7.4_Array_sum.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/7.4_Array_sum.asm)<br>[`array_Jannat[7.3].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/array_Jannat%5B7.3%5D.asm)<br>[`array_sum_Jannat[7.4].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/array_sum_Jannat%5B7.4%5D.asm)<br>[`array_sum_Semim[7.4].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/array_sum_Semim%5B7.4%5D.asm) | **Hardware Loops, Conditional Filtering & 1D Array Operations**<br>Print alphabet sequences, skip specific characters, declare 1D byte arrays, traverse with pointers, and calculate vector sums. | • Dedicated counter register `CX` & hardware `LOOP` instruction (`CX <- CX - 1; JNZ`)<br>• Conditional branching (`CMP`, `JE`, `JBE`)<br>• 1D memory buffers (`array db ...`)<br>• Base indirect pointer indexing using Source Index (`SI`, `[SI]`)<br>• Pointer advancement (`INC SI`) | `CX` (loop counter)<br>`SI` (memory source index pointer)<br>`DL` (current element output)<br>`BL` (running sum accumulator)<br>`AL` (memory transfer mediator) | Placing `INC SI` or `INC DL` inside a skipped block, causing an infinite loop. Adding memory directly to accumulator with unaligned registers. |

---

## 2. Lab-by-Lab Deep Dive & Code Walkthroughs

### 2.1 Lab 1: Environment Setup & Direct String Display
* **Files Analyzed**: [`1.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-1/1.1.asm) and [`lab-1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-1/lab-1.asm) *(Identical implementations; merged into one)*.
* **Core Problem**: Setting up the standard 8086 segment architecture, allocating memory, and printing a predefined text string to the console.

#### Key Mechanics & Architectural Insights
* **Memory Segmentation & Directives**:
  - `.model small`: Configures the memory model where code fits in one 64 KB segment and data fits in one 64 KB segment.
  - `.stack 100h`: Allocates 256 bytes ($100_{16} = 256_{10}$) for the CPU stack segment (`SS:SP`).
* **The Segment Register Rule**:
  - The 8086 architecture does not allow immediate values to be loaded directly into segment registers (e.g., `mov ds, @data` is an illegal opcode).
  - Therefore, `@data` is transferred into general accumulator `AX` first, then copied into `DS`:
    ```assembly
    mov ax, @data
    mov ds, ax
    ```
* **DOS Function 09h (`INT 21H`)**:
  - Requires `AH = 09h`.
  - Requires `DX` to hold the offset address of the string buffer (`mov dx, offset myname`).
  - Expects the string in memory to terminate with the sentinel symbol `$` (ASCII 24h). Without `$`, the service continues outputting adjacent memory contents until it happens to encounter a `$` byte.
* **DOS Function 4Ch (`INT 21H`)**:
  - Gracefully returns control to the operating system / DOS environment (`mov ah, 4ch; int 21h`).

```assembly
; ============================================================
; Lab 1: Standard String Display Program
; Files: 1.1.asm / lab-1.asm
; ============================================================
.model small
.stack 100h

.data
    myname db 'my name is Gaus$'    ; '$' indicates end of string

.code
main proc
    mov ax, @data                   ; Initialize data segment
    mov ds, ax
    
    mov dx, offset myname           ; Load effective address of string
    mov ah, 09h                     ; DOS print string function
    int 21h                         ; Trigger interrupt
    
exit:
    mov ah, 4ch                     ; Return to DOS
    int 21h
main endp
end main
```

---

### 2.2 Lab 2: Character I/O, Formatting & Multi-Input Staging

#### 2.2.1 Character Echo & Whitespace / Newline Sequences
* **Files Analyzed**: [`2.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2/2.1.asm) and [`2.2.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2/2.2.asm).
* **Core Problem**: Reading a single character from the keyboard, generating custom spacing and line breaks, and displaying the character back to the screen.

#### Key Mechanics & Architectural Insights
* **DOS Function 01h (Character Input with Echo)**:
  - Reads a single ASCII character from `STDIN`. The character's 8-bit ASCII value is automatically placed into `AL`.
  - To prevent `AL` from being overwritten by subsequent operations, its content is immediately preserved in `BL` (`mov bl, al`).
* **DOS Function 02h (Character Output)**:
  - Outputs the single byte stored in the `DL` register to `STDOUT`.
* **Standard Line Break Anatomy (CRLF)**:
  - In DOS/x86 console environments, a true new line requires two distinct operations:
    1. **Line Feed (`LF = 10` / `0Ah`)**: Moves the cursor straight down to the next physical row without changing the column position.
    2. **Carriage Return (`CR = 13` / `0Dh`)**: Moves the cursor horizontally back to the leftmost column of the current row.
  - Omitting `13` produces a "staircase effect" where the next line starts directly beneath where the previous line finished.
* **Space Character**: ASCII `32` (`20h`) loaded into `DL` outputs a single blank space.

```assembly
; ============================================================
; Lab 2.1 & 2.2: Character Input, Spacing, and CRLF Output
; Files: 2.1.asm / 2.2.asm
; ============================================================
.model small
.stack 100h
.code
main proc
    ; 1. Read character from keyboard into AL
    mov ah, 1
    int 21h
    mov bl, al              ; Stash input character into BL

    ; 2. Print 4 spaces (ASCII 32)
    mov ah, 2
    mov dl, 32
    int 21h
    int 21h
    int 21h
    int 21h

    ; 3. Print CRLF (New Line + Carriage Return)
    mov ah, 2
    mov dl, 10              ; Line Feed (move down 1 row)
    int 21h
    mov dl, 13              ; Carriage Return (move to column 0)
    int 21h

    ; 4. Output the preserved character
    mov dl, bl
    mov ah, 2
    int 21h

exit:
    mov ah, 4ch
    int 21h
main endp
end main
```

---

#### 2.2.2 Staged Multi-Input Buffering & Prompt Interleaving
* **Files Analyzed**: [`2.3.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2/2.3.asm) and [`2.3-alt.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-2/2.3-alt.asm) *(Alternative attempted embedding newlines inside `.DATA` strings)*.
* **Core Problem**: Interleaving text prompts with user inputs, preserving multiple distinct inputs across registers, and echoing them in a formatted output block.

#### Key Mechanics & Architectural Insights
* **Register Buffering**:
  - The first input character is read into `AL` and saved to `BL`.
  - The second input character is read into `AL` and saved to `BH`.
  - Using `BX` as two distinct 8-bit registers (`BL` and `BH`) avoids allocating unnecessary memory variables.
* **Data Definition Formatting Trap (`2.3-alt.asm`)**:
  - In `2.3-alt.asm`, an attempt was made to embed carriage returns and multiple string segments directly in the `db` declaration without explicit commas or quotes:
    ```assembly
    ; Faulty syntax in 2.3-alt.asm:
    var1 db 'Input:$
             5$
             3$'
    ```
  - Standard MASM requires newline bytes embedded within strings to be declared as explicit numeric byte constants:
    ```assembly
    var1 db 'Input:', 10, 13, '$'
    ```
  - The manual CRLF interrupt sequence (`mov dl, 10; int 21h; mov dl, 13; int 21h`) remains the most portable, predictable approach for console formatting.

```assembly
; ============================================================
; Lab 2.3: Staged Multi-Character Input and Formatted Output
; File: 2.3.asm
; ============================================================
.model small
.stack 100h
.data
    var1 db 'Input:$'
    var2 db 'Output:$'

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Print "Input:"
    mov dx, offset var1
    mov ah, 09h
    int 21h

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; Read First Digit -> BL
    mov ah, 1
    int 21h
    mov bl, al

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; Read Second Digit -> BH
    mov ah, 1
    int 21h
    mov bh, al

    ; Print 2x CRLF before Output Header
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; Print "Output:"
    mov dx, offset var2
    mov ah, 09h
    int 21h

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; Echo First Character (BL)
    mov ah, 2
    mov dl, bl
    int 21h

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; Echo Second Character (BH)
    mov ah, 2
    mov dl, bh
    int 21h

exit:
    mov ah, 4ch
    int 21h
main endp
end main
```

---

### 2.3 Lab 3: Single-Digit Arithmetic & Multi-Digit Output Decomposition

#### 2.3.1 Fundamental 4-Operation Arithmetic
* **Files Analyzed**: [`3.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-3/3.1.asm).
* **Core Problem**: Read two single-digit numeric inputs from standard input, execute addition, subtraction, multiplication, and division, and output each result separated by spaces.

#### Key Mechanics & Architectural Insights
* **The ASCII Conversion Barrier**:
  - The keyboard interrupt returns ASCII glyph codes, not numerical quantities:
    $$\text{ASCII } '5' = 35_{16} = 53_{10}$$
    $$\text{ASCII } '3' = 33_{16} = 51_{10}$$
  - If added directly without conversion: $53 + 51 = 104 = 'h'$.
  - **Conversion to Integer**: Subtract 48 (`30h`):
    ```assembly
    sub al, 48          ; '5' (53) - 48 = 5
    ```
  - **Conversion back to ASCII**: Add 48 (`30h`):
    ```assembly
    add al, 48          ; 5 + 48 = 53 ('5')
    ```
* **Hardware Multiplication (`MUL`)**:
  - In 8-bit mode (`mul operand8`), the CPU uses `AL` as an implicit multiplicand:
    $$\text{AX} \leftarrow \text{AL} \times \text{operand8}$$
  - For single-digit operations where the product is $< 10$, the answer is entirely held in `AL`.
* **Hardware Division (`DIV`)**:
  - In 8-bit mode (`div operand8`), the dividend is **always** assumed to be the 16-bit word in `AX`:
    $$\text{AL (Quotient)} \leftarrow \text{AX} \div \text{operand8}$$
    $$\text{AH (Remainder)} \leftarrow \text{AX} \pmod{\text{operand8}}$$
  - Both `AL` and `AH` can then be individually converted back to ASCII (`add al, 48; add ah, 48`) to display the quotient and remainder separately.

```assembly
; ============================================================
; Lab 3.1: Fundamental Arithmetic Operations (+, -, *, /)
; File: 3.1.asm
; ============================================================
.model small
.stack 100h
.data
    num1  db ?
    num2  db ?
    sum   db ?
    subt  db ?
    multi db ?
    divi  db ?
    rem   db ?

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Read First Number
    mov ah, 1
    int 21h
    sub al, 48                      ; Convert ASCII -> Integer
    mov num1, al

    ; Space delimiter
    mov ah, 2
    mov dl, 32
    int 21h

    ; Read Second Number
    mov ah, 1
    int 21h
    sub al, 48                      ; Convert ASCII -> Integer
    mov num2, al

    ; Space delimiter
    mov ah, 2
    mov dl, 32
    int 21h

    ; 1. ADDITION
    mov al, num1
    add al, num2
    add al, 48                      ; Convert Integer -> ASCII
    mov sum, al
    mov dl, sum
    mov ah, 2
    int 21h

    ; 2. SUBTRACTION
    mov ah, 2
    mov dl, 32
    int 21h
    mov al, num1
    sub al, num2
    add al, 48
    mov subt, al
    mov dl, subt
    mov ah, 2
    int 21h

    ; 3. MULTIPLICATION
    mov ah, 2
    mov dl, 32
    int 21h
    mov al, num1
    mul num2                        ; AX = AL * num2
    add al, 48
    mov multi, al
    mov dl, multi
    mov ah, 2
    int 21h

    ; 4. DIVISION
    mov ah, 2
    mov dl, 32
    int 21h
    mov al, num1
    mov ah, 0                       ; Clear upper byte for clean division
    div num2                        ; AL = Quotient, AH = Remainder
    add al, 48
    add ah, 48
    mov divi, al
    mov rem, ah

    ; Print Quotient
    mov dl, divi
    mov ah, 2
    int 21h

    ; Print Space
    mov dl, 32
    mov ah, 2
    int 21h

    ; Print Remainder
    mov dl, rem
    mov ah, 2
    int 21h

main endp
end main
```

---

#### 2.3.2 Multi-Digit Output Decomposition via Radix-10 Division
* **Files Analyzed**: [`3.2.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-3/3.2.asm).
* **Core Problem**: If multiplication yields a product $\ge 10$ (e.g., $4 \times 3 = 12$), adding 48 directly produces character code $60$ (`<`), corrupting the output. The numerical value must be decomposed into individual decimal digits.

#### Key Mechanics & Architectural Insights
* **The Decimal Decomposition Algorithm**:
  - Any 2-digit decimal number $N \in [0, 99]$ can be separated by dividing by $10$:
    $$\text{Tens Digit} = \lfloor N / 10 \rfloor$$
    $$\text{Units Digit} = N \pmod{10}$$
  - In 8086 assembly, setting `BL = 10` and running `div bl` on `AX` ($AH=0, AL=N$) produces:
    - `AL` = Quotient (tens digit)
    - `AH` = Remainder (units digit)
* **Sequential Output**:
  - Add 48 to `AL` $\rightarrow$ print with `AH=02h` (outputs the tens digit first).
  - Add 48 to `AH` $\rightarrow$ print with `AH=02h` (outputs the units digit second).

```assembly
; ============================================================
; Lab 3.2: Decomposing a 2-Digit Product via Base-10 Division
; File: 3.2.asm
; ============================================================
.model small
.stack 100h
.data
    num1  db ?
    num2  db ?
    multi db ?
    quot  db ?
    rem   db ?

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Read Inputs num1 and num2
    mov ah, 1
    int 21h
    sub al, 48
    mov num1, al

    mov ah, 1
    int 21h
    sub al, 48
    mov num2, al

    ; Multiply: AL = num1 * num2
    mov al, num1
    mul num2                        ; AX = AL * num2 (e.g., 4 * 3 = 12)
    mov multi, al

    ; Decompose Decimal Digits
    mov ah, 0                       ; Ensure AH is 0 before 8-bit division
    mov bl, 10
    div bl                          ; AL = 12 / 10 = 1 (tens), AH = 12 % 10 = 2 (units)

    add al, 48                      ; 1 + 48 = '1'
    add ah, 48                      ; 2 + 48 = '2'
    mov quot, al
    mov rem, ah

    ; Output Tens Digit
    mov ah, 2
    mov dl, quot
    int 21h

    ; Output Units Digit
    mov ah, 2
    mov dl, rem
    int 21h

main endp
end main
```

---

### 2.4 Lab 4: Compound Academic Marks Calculation & Averages
* **Files Analyzed**: [`4.1_CP.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-4/4.1_CP.asm).
* **Core Problem**: Prompt user for 3 subject marks, calculate the total sum, display the 2-digit total marks, and calculate/display the integer average mark.

#### Key Mechanics & Architectural Insights
* **The "Garbage AH" Trap (Fault #DE)**:
  - When preparing to divide by a byte register (`div bl`), the CPU divides the entire 16-bit register `AX` (`AH:AL`), **not** just `AL`.
  - If `AH` contains leftover values from earlier DOS calls (such as `AH = 02h` from printing), the CPU evaluates a dividend of:
    $$\text{AX} = (\text{AH} \times 256) + \text{AL}$$
  - For example, if `AH = 2` and `AL = 27`, $AX = 512 + 27 = 539$.
  - Dividing $539$ by $3$ gives $179$. Since $179$ cannot fit into an 8-bit signed/unsigned register target if scaled, or if the quotient exceeds 255, the CPU immediately raises **Interrupt 0 (Divide Error Exception)**.
  - **The Golden Rule**: Always explicitly clear `AH` before an 8-bit division:
    ```assembly
    mov ah, 0           ; Zero-extend AL into AX
    div bl
    ```
* **Summation & Multi-Digit Formatting**:
  - Accumulate values in `AL`:
    ```assembly
    mov al, num1
    add al, num2
    add al, num3
    mov sum, al
    ```
  - Decompose into two decimal digits using `div 10`.
  - Calculate average using integer division: $\text{Average} = \text{Sum} / 3$.

```assembly
; ============================================================
; Lab 4: Subject Marks Summation & Average Calculation
; File: 4.1_CP.asm
; ============================================================
.model small
.stack 100h
.data
    num1  db ?
    num2  db ?
    num3  db ?
    sum   db ?
    quot  db ?
    rem   db ?
    avg_q db ?
    avg_r db ?
    msg1  db "Subject 1: $"
    msg2  db "Subject 2: $"
    msg3  db "Subject 3: $"
    msg4  db "Total Marks: $"
    msg5  db "Average Marks: $"

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Read Subject 1
    mov dx, offset msg1
    mov ah, 09h
    int 21h
    mov ah, 1
    int 21h
    sub al, 48
    mov num1, al

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; Read Subject 2
    mov dx, offset msg2
    mov ah, 09h
    int 21h
    mov ah, 1
    int 21h
    sub al, 48
    mov num2, al

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; Read Subject 3
    mov dx, offset msg3
    mov ah, 09h
    int 21h
    mov ah, 1
    int 21h
    sub al, 48
    mov num3, al

    ; Compute Sum: AL = num1 + num2 + num3
    mov al, num1
    add al, num2
    add al, num3
    mov sum, al

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; Display "Total Marks: "
    mov dx, offset msg4
    mov ah, 09h
    int 21h

    ; Display 2-digit Total
    mov al, sum
    mov ah, 0                       ; CRITICAL: zero out AH before division
    mov bl, 10
    div bl                          ; AL = tens, AH = units
    add al, 48
    add ah, 48
    mov quot, al
    mov rem, ah

    mov ah, 2
    mov dl, quot
    int 21h
    mov dl, rem
    int 21h

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; Display "Average Marks: "
    mov dx, offset msg5
    mov ah, 09h
    int 21h

    ; Compute Average: Sum / 3
    mov al, sum
    mov ah, 0                       ; CRITICAL: zero out AH again
    mov bl, 3
    div bl                          ; AL = integer average
    add al, 48
    mov avg_q, al

    mov ah, 2
    mov dl, avg_q
    int 21h

exit:
    mov ah, 4ch
    int 21h
main endp
end main
```

---

### 2.5 Lab 5: Bitwise Operations & Hexadecimal Conversion Subroutines
* **Files Analyzed**: [`5.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-5/5.1.asm).
* **Core Problem**: Perform bitwise logical manipulation (`OR`) on a data byte, isolate the upper and lower 4-bit nibbles, and convert them to human-readable ASCII hexadecimal digits ('0'-'9', 'A'-'F') using a reusable procedure (`PROC`).

#### Key Mechanics & Architectural Insights
* **Bitwise Logic**:
  - `or al, 0D1h`: Sets specific bit positions while retaining existing ones.
* **Nibble Isolation Mechanics**:
  - An 8-bit byte consists of two 4-bit nibbles: `[Bit 7..4]` (Upper) and `[Bit 3..0]` (Lower).
  - **Upper Nibble**: Extracted by shifting right 4 bits (`shr al, 4`), which slides bits 7..4 down to bit positions 3..0 and fills bits 7..4 with zeros.
  - **Lower Nibble**: Extracted by bitwise masking with `0Fh` (`00001111b`): `and al, 0Fh`.
* **Hexadecimal ASCII Conversion Math**:
  - For values $0 \le X \le 9$: Adding 48 converts the value directly to `'0'` through `'9'`.
  - For values $10 \le X \le 15$:
    - Adding 48 yields values from $58$ to $63$ (`:`, `;`, `<`, `=`, `>`, `?`).
    - ASCII `'A'` is $65_{10}$.
    - Therefore, an additional offset of $7$ ($65 - 58 = 7$) must be added:
      $$\text{Hex ASCII} = X + 48 + 7 = X + 55$$
* **Subroutines with `CALL` and `RET`**:
  - `call print_hex`: Pushes the current Instruction Pointer (`IP`) onto the stack (`SP <- SP - 2`) and jumps to the procedure label.
  - `ret`: Pops the saved address from the stack back into `IP`, resuming execution immediately after the `CALL` instruction.

```
+-------------------------------------------------------------+
|               Hexadecimal Conversion Logic Flow             |
+-------------------------------------------------------------+
                            |
                     AL = Nibble (0-15)
                            |
                       add al, 48
                            |
                       cmp al, 57 ('9')
                            |
                  +---------+---------+
                  |                   |
            AL <= 57 (0-9)       AL > 57 (10-15)
                  |                   |
                 JBE                add al, 7
                  |                   |
                  +--------->+<-------+
                             |
                      mov dl, al
                      mov ah, 02h
                      int 21h
                             |
                            RET
```

```assembly
; ============================================================
; Lab 5: Bitwise Manipulation & Hexadecimal Subroutine
; File: 5.1.asm
; ============================================================
.model small
.stack 100h
.data
    num1 db 018h
    msg1 db "num1 : $"

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Display Prompt
    mov dx, offset msg1
    mov ah, 09h
    int 21h

    ; Apply Bitwise OR
    mov al, num1
    or al, 0D1h                     ; 0001 1000 OR 1101 0001 = 1101 1001 (0D9h)
    mov bl, al                      ; Preserve result in BL

    ; Process Upper Nibble
    mov al, bl
    shr al, 4                       ; Shift upper 4 bits into lower nibble position
    call print_hex

    ; Process Lower Nibble
    mov al, bl
    and al, 0Fh                     ; Mask out upper 4 bits (0000 1111b)
    call print_hex

    ; Exit
    mov ah, 4Ch
    int 21h
main endp

; ------------------------------------------------------------
; Procedure: print_hex
; Input: AL (holds single 4-bit nibble value 0..15)
; Output: Prints corresponding hex character ('0'-'9', 'A'-'F')
; ------------------------------------------------------------
print_hex proc
    add al, 48                      ; Convert 0..9 to '0'..'9'
    cmp al, 57                      ; Compare with ASCII '9'
    jbe out_label                   ; If <= '9', skip letter adjustment
    add al, 7                       ; Adjust 10..15 to 'A'..'F'

out_label:
    mov dl, al
    mov ah, 02h
    int 21h
    ret                             ; Return control back to caller
print_hex endp

end main
```

---

### 2.6 Lab 6: Character Case Conversion & Bitwise Toggling
* **Files Analyzed**: [`6.1_CP.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-6/6.1_CP.asm) *(Subtractive approach)* and [`6.1_CP-alt.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-6/6.1_CP-alt.asm) *(XOR toggling alternative)*.
* **Core Problem**: Read an arbitrary ASCII alphabetic character from standard input, convert or toggle its case between uppercase and lowercase, and display the transformed result with formatted output.

#### Key Mechanics & Architectural Insights

1. **The ASCII Case Bit Property (Bit 5 Alignment)**:
   - In standard ASCII encoding, corresponding uppercase and lowercase letters differ by exactly one bit: **Bit 5** (weight $2^5 = 32_{10} = 20_{16}$):
     $$\text{'a'} = 01100001_2 = 61_{16} = 97_{10}$$
     $$\text{'A'} = 01000001_2 = 41_{16} = 65_{10}$$
   - Bit 5 is strictly `1` for all lowercase letters (`'a'-'z'`: `61h - 7Ah`) and strictly `0` for all uppercase letters (`'A'-'Z'`: `41h - 5Ah`).
   - Bits 0–4 encode the letter's alphabetical rank ($1$ through $26$), and Bits 6–7 define the printable ASCII character block (`01b`).

2. **Comparison of Case Conversion Techniques**:

| Technique | Instruction | Operation | Characteristics & Limitations |
| :--- | :--- | :--- | :--- |
| **Arithmetic Subtraction** | `SUB AL, 20h` (or `SUB AL, 32`) | $\text{AL} \leftarrow \text{AL} - 32$ | **Directional only (Lower $\rightarrow$ Upper)**.<br>If applied to an uppercase character (`'A'`), the result is non-alphabetic (`'A' - 32 = '!'`). |
| **Arithmetic Addition** | `ADD AL, 20h` (or `ADD AL, 32`) | $\text{AL} \leftarrow \text{AL} + 32$ | **Directional only (Upper $\rightarrow$ Lower)**.<br>If applied to a lowercase character (`'a'`), the result overflows into non-letter ASCII (`'a' + 32 = 81h`). |
| **Bitwise Force (AND/OR)** | `AND AL, 0DFh`<br>`OR AL, 20h` | Clears Bit 5 (`0DFh = 11011111b`)<br>Sets Bit 5 (`20h = 00100000b`) | **Idempotent (Guaranteed target case)**.<br>`AND` guarantees uppercase even if already uppercase; `OR` guarantees lowercase even if already lowercase. |
| **Bitwise Inversion (XOR)** *(Universal)* | `XOR AL, 32`<br>*(or `XOR AL, 20h`)* | $\text{AL} \leftarrow \text{AL} \oplus 00100000_2$ | **Universal Bidirectional Toggle**.<br>Flips Bit 5 ($0 \leftrightarrow 1$). Automatically inverts Lower $\rightarrow$ Upper **and** Upper $\rightarrow$ Lower without conditional jumps! |

3. **Bitwise Masking with `XOR` Under the Hood**:
   - **Fundamental Boolean Axioms**:
     $$x \oplus 0 = x \quad \text{(Preserves the original bit)}$$
     $$x \oplus 1 = \text{NOT}(x) \quad \text{(Inverts / toggles the bit)}$$
   - **The Mask Value**:
     - Decimal: `32`
     - Hexadecimal: `20h`
     - Binary: `0010 0000b` (Only Bit 5 is `1`; all other 7 bits are `0`)
   - **Bit-by-Bit Logic Breakdown**:
     - **Bits 0–4**: Mask is `0` $\rightarrow x \oplus 0 = x \rightarrow$ Letter identity preserved ($1$ to $26$).
     - **Bit 5**: Mask is `1` $\rightarrow x \oplus 1 = \text{NOT}(x) \rightarrow$ **Toggled** ($0 \leftrightarrow 1$).
     - **Bits 6–7**: Mask is `0` $\rightarrow x \oplus 0 = x \rightarrow$ ASCII letter block preserved (`01b`).

```
    Bit Position:   7   6   5   4   3   2   1   0
    AL ('a'):       0   1   1   0   0   0   0   1   (97 dec / 61h)
    Mask 32:        0   0   1   0   0   0   0   0   (32 dec / 20h)
    ------------------------------------------------- (XOR)
    Result ('A'):   0   1   0   0   0   0   0   1   (65 dec / 41h)
                            ^
                     Bit 5 flipped (1 -> 0)
```
```
    Bit Position:   7   6   5   4   3   2   1   0
    AL ('A'):       0   1   0   0   0   0   0   1   (65 dec / 41h)
    Mask 32:        0   0   1   0   0   0   0   0   (32 dec / 20h)
    ------------------------------------------------- (XOR)
    Result ('a'):   0   1   1   0   0   0   0   1   (97 dec / 61h)
                            ^
                     Bit 5 flipped (0 -> 1)
```

4. **String Definition & Embedded CRLF (`DB 13, 10`)**:
   - Instead of issuing separate DOS calls (`INT 21H / AH=02H`) for Line Feed (`10`) and Carriage Return (`13`), embedded control bytes can be placed directly in the `.DATA` string:
     ```assembly
     MSG2 DB 13, 10, 'Output: $'
     ```
   - When printed with `AH=09H`, DOS moves the cursor to column 0 (`13`) and drops down one row (`10`) automatically before rendering `'Output: '`.

5. **Address Loading: `LEA` vs `OFFSET`**:

| Directive / Instruction | Evaluation Timing | Hardware Execution | Best Use Case |
| :--- | :--- | :--- | :--- |
| **`MOV DX, OFFSET label`** | **Assemble-time** | Hardcodes immediate 16-bit constant address into instruction opcodes (`BA xx xx`). Faster, smaller binary footprint. | Static variables and fixed memory buffers declared in `.DATA`. |
| **`LEA DX, label`** | **Run-time** | CPU calculates Effective Address (EA) dynamically via internal ALU address generator. | Dynamic pointers, array indexing with displacements (e.g., `LEA SI, [BX + DI + 4]`). |

> [!NOTE]
> For simple direct labels like `MSG1`, `LEA` adds slight CPU runtime calculation overhead compared to `OFFSET`, but is widely readable across assemblers.

#### Code Listing: Primary Subtractive Approach (`6.1_CP.asm`)
```assembly
; ============================================================
; Lab 6: Lowercase to Uppercase Case Conversion (Subtraction)
; File: 6.1_CP.asm
; ============================================================
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

    ; Prompt for Input
    mov dx, offset msg1
    mov ah, 09h
    int 21h

    ; Read Lowercase Character into AL
    mov ah, 01h
    int 21h

    ; Convert to Uppercase
    sub al, 20h                     ; Subtract 32 (20h)
    mov char, al

    ; Print CRLF manually
    mov ah, 02h
    mov dl, 10
    int 21h
    mov ah, 02h
    mov dl, 13
    int 21h

    ; Display Output Prompt
    mov dx, offset msg2
    mov ah, 09h
    int 21h

    ; Print Converted Uppercase Character
    mov ah, 02h
    mov dl, char
    int 21h

exit:
    mov ah, 4ch
    int 21h
main endp
end main
```

#### Code Listing: Alternative XOR Toggling Approach (`6.1_CP-alt.asm`)
```assembly
; ============================================================
; Lab 6 Alternative: Case Toggling via Bitwise XOR Masking
; File: 6.1_CP-alt.asm
; Reference: 8086 Assembly Cheatsheet / 6.1_CP.asm Alternative
; ============================================================
.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'Input: $'
    MSG2 DB 13, 10, 'Output: $'      ; Embedded CR (13) and LF (10) for automated newline

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Display Input Prompt
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    ; 2. Read Single Character from Keyboard into AL
    MOV AH, 01H
    INT 21H

    ; 3. Universal Case Toggling (Invert Bit 5)
    ; 'a' (61h) XOR 20h -> 'A' (41h)
    ; 'A' (41h) XOR 20h -> 'a' (61h)
    XOR AL, 32

    ; 4. Preserve Converted Character in BL
    MOV BL, AL

    ; 5. Display Output Message (Automatically issues CRLF first)
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H

    ; 6. Display Converted Character
    MOV DL, BL
    MOV AH, 02H
    INT 21H

    ; 7. Return to DOS
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
```

---

### 2.7 Lab 7: Loops, Conditional Filtering & 1D Array Processing

#### 2.7.1 Hardware Loops & Alphabet Traversal
* **Files Analyzed**: [`7.1_loop.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/7.1_loop.asm).
* **Core Problem**: Sequentially display all 26 lowercase English alphabet characters ('a' through 'z') using the hardware loop counter register.

#### Key Mechanics & Architectural Insights
* **The 8086 `LOOP` Instruction**:
  - The `LOOP` instruction is hardwired to use the `CX` (Count) register.
  - Every time `loop label` executes, the CPU performs two sequential actions atomically:
    1. Decrements `CX`: $\text{CX} \leftarrow \text{CX} - 1$
    2. Tests condition: If $\text{CX} \ne 0$, branch to `label`; otherwise continue to the next instruction.
  - Note: `LOOP` does **not** modify the Zero Flag (`ZF`) in the `FLAGS` register.
* **Initialization**:
  - To print 26 characters, load `CX` with 26 (`mov cx, 26`).
  - Initialize the character carrier in `DL` with `'a'` (`mov dl, 'a'`).
  - Advance the character each iteration using `inc dl`.

```assembly
; ============================================================
; Lab 7.1: Alphabet Traversal using Hardware LOOP
; File: 7.1_loop.asm
; ============================================================
.model small
.stack 100h
.code
main proc
    mov cx, 26                      ; Counter for 26 letters
    mov dl, 'a'                     ; Start at 'a'

level:
    mov ah, 2h                      ; Print current character in DL
    int 21h
    inc dl                          ; Move to next ASCII letter ('a' -> 'b')
    loop level                      ; CX = CX - 1; if CX != 0 jump to level

exit:
    mov ah, 4ch
    int 21h
main endp
end main
```

---

#### 2.7.2 Conditional Element Filtering & Jump-Based Loops
* **Files Analyzed**: [`7.2_task.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/7.2_task.asm) and [`array_sum_Semim[7.4].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/array_sum_Semim%5B7.4%5D.asm) *(which actually contains Semim's upper-case A-Z filtering algorithm skipping 'S')*.
* **Core Problem**: Iterate through an alphabet sequence while skipping a specific character (e.g., skip letter `'s'` or `'S'`).

#### Key Mechanics & Architectural Insights
* **Selective Branching with `CMP` and `JE`**:
  - In each iteration, test `DL` against the target skip character: `cmp dl, 's'`.
  - If equal (`je skip`), bypass the `int 21h` character print service.
* **The Counter / Increment Sync Trap**:
  - Ensure `inc dl` and `loop level` are placed **after** or **at** the `skip` label so that:
    1. `DL` still gets incremented to the next letter.
    2. `CX` is decremented properly.
  - If `skip` jumped directly to `loop level` without incrementing `DL`, the loop would compare `'s'` forever, locking into an infinite loop.
* **Alternative: Bound Comparison Loop without `CX` (`array_sum_Semim`)**:
  - Rather than relying on `CX` and `LOOP`, you can increment `DL` and compare directly against the terminal boundary (`cmp dl, 'Z'`; `jbe level`).

```assembly
; ============================================================
; Lab 7.2: Alphabet Loop with Conditional Skip ('s')
; File: 7.2_task.asm
; ============================================================
.model small
.stack 100h
.code
main proc
    mov cx, 26
    mov dl, 'a'

level:
    cmp dl, 's'                     ; Check if current char is 's'
    je skip                         ; If matched, bypass printing

    mov ah, 2h                      ; Print character
    int 21h

skip:
    inc dl                          ; Increment to next letter ('s' -> 't')
    loop level                      ; Decrement CX and repeat

exit:
    mov ah, 4ch
    int 21h
main endp
end main
```

---

#### 2.7.3 1D Array Declaration & Pointer Traversal
* **Files Analyzed**: [`7.3_Array.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/7.3_Array.asm) and [`array_Jannat[7.3].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/array_Jannat%5B7.3%5D.asm).
* **Core Problem**: Define a contiguous 1-dimensional array of byte-sized integers in the data segment, load its base address into a pointer index register, and traverse it using indexed addressing to print each element separated by spaces.

#### Key Mechanics & Architectural Insights
* **Memory Buffer Declaration (`db`)**:
  ```assembly
  array db 1, 2, 3, 4, 5
  ```
  Allocates 5 contiguous bytes in memory: `[array+0] = 1`, `[array+1] = 2`, etc.
* **Base Pointer Indexing with Source Index (`SI`)**:
  - `mov si, offset array`: Loads the starting memory offset of the array into `SI`.
  - Dereferencing `[si]`: Retrieves the byte stored at memory address `DS:SI`.
* **Pointer Arithmetic**:
  - Because elements are defined as bytes (`db`), the pointer advances by 1 byte per element: `inc si`.
  - (If arrays were declared as 16-bit words `dw`, the pointer would need `add si, 2`).
* **Conversion During Display**:
  - Array elements stored as raw integers (1, 2, 3...) must have 48 added (`add dl, 48`) before passing to `INT 21H / AH=02H`.

```assembly
; ============================================================
; Lab 7.3: 1D Array Traversal and Space-Delimited Output
; File: 7.3_Array.asm
; ============================================================
.model small
.stack 100h
.data
    array db 1, 2, 3, 4, 5          ; 5-element byte array

.code
main proc
    mov ax, @data
    mov ds, ax

    mov si, offset array            ; Load base memory address of array
    mov cx, 5                       ; Array length into loop counter

my_loop:
    mov ah, 2
    mov dl, [si]                    ; Dereference pointer: DL = array[i]
    add dl, 48                      ; Convert integer to ASCII
    int 21h

    ; Print Space delimiter
    mov dl, 32
    int 21h

    inc si                          ; Advance pointer to next byte
    loop my_loop                    ; Repeat for all elements

exit:
    mov ah, 4ch
    int 21h
main endp
end main
```

---

#### 2.7.4 Linear Array Summation & Accumulator Patterns
* **Files Analyzed**: [`7.4_Array_sum.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/7.4_Array_sum.asm), [`array_sum_Jannat[7.4].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/array_sum_Jannat%5B7.4%5D.asm), and [`array_sum_Semim[7.4].asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-7/array_sum_Semim%5B7.4%5D.asm).
* **Core Problem**: Traverse an integer array, sum all its values into an accumulator register, and print the single-digit sum.

#### Key Mechanics & Critical Bug Analysis
* **Accumulator Initialization**:
  - An 8-bit register (such as `BL`) is initialized to zero: `mov bl, 0`.
* **Addressing / Transfer Logic Bug in `7.4_Array_sum.asm`**:
  - In `7.4_Array_sum.asm`, the loop was written as:
    ```assembly
    mov ah, 2
    mov dl, [si]
    add bl, al      ; BUG: AL was never loaded from [si]! AL contains garbage or leftover @data!
    inc si
    loop my_loop
    ```
  - Here, the array element was moved to `DL`, but `BL` was accumulating `AL`. This results in completely incorrect sum values.
* **The Correct Pattern (`array_sum_Jannat[7.4].asm`)**:
  - Load the memory byte directly into the transfer register `AL`, then add `AL` to accumulator `BL`:
    ```assembly
    mov al, [si]    ; Dereference current array element
    add bl, al      ; Accumulate into BL
    inc si          ; Advance memory pointer
    loop my_loop
    ```
  - *Note on Jannat's variant*: `cx` was set to 5 for a 3-element array (`array db 1,2,3`), which reads 2 bytes of out-of-bounds unallocated memory past the array boundary. The loop count `cx` must strictly match the array's declared size.

```assembly
; ============================================================
; Lab 7.4: Robust 1D Array Accumulation and Sum Output
; Merged & Corrected Reference Implementation
; ============================================================
.model small
.stack 100h
.data
    array db 1, 2, 3, 4             ; 4-element byte array (Sum = 1+2+3+4 = 10)
    ; For single-digit test: array db 1, 2, 3 (Sum = 6)

.code
main proc
    mov ax, @data
    mov ds, ax

    mov si, offset array            ; SI points to array[0]
    mov cx, 4                       ; Loop counter matches array size
    mov bl, 0                       ; Accumulator cleared to 0

sum_loop:
    mov al, [si]                    ; Load current array element into AL
    add bl, al                      ; Accumulate: BL = BL + AL
    inc si                          ; Move pointer to next element
    loop sum_loop                   ; CX = CX - 1; repeat until CX == 0

    ; Output single-digit sum (or decompose via DIV 10 if sum >= 10)
    mov dl, bl
    add dl, 48                      ; Convert integer sum to ASCII
    mov ah, 2
    int 21h

exit:
    mov ah, 4ch
    int 21h
main endp
end main
```

---

## 3. High-Yield Exam Cheat Sheet & Architecture Mechanics

### 3.1 DOS Interrupt 21h Service Summary

| Service (`AH`) | Purpose | Input Arguments | Output / Side Effects |
| :--- | :--- | :--- | :--- |
| `01h` | **Read Character with Echo** | *None* | `AL` = ASCII character code read from standard input. |
| `02h` | **Write Character** | `DL` = ASCII character to display | Writes character to standard output. |
| `09h` | **Write String** | `DX` = Offset address of `$`-terminated string | Writes characters to standard output until `$` is encountered. |
| `4Ch` | **Terminate Process** | `AL` = Return exit code (optional) | Relinquishes CPU control cleanly back to DOS environment. |

---

### 3.2 8086 Hardware Division Rules

| Division Type | Divisor Size | Dividend Register | Quotient Destination | Remainder Destination | Overflow Condition |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `div reg8` / `div mem8` | **8-bit** (Byte) | **`AX` (16-bit)**<br>*(Must ensure `AH = 0`)* | **`AL`** (8-bit) | **`AH`** (8-bit) | Quotient $> 255$ triggers **Divide Error (Fault #DE)** |
| `div reg16` / `div mem16` | **16-bit** (Word) | **`DX:AX` (32-bit)**<br>*(Must ensure `DX = 0`)* | **`AX`** (16-bit) | **`DX`** (16-bit) | Quotient $> 65535$ triggers **Divide Error (Fault #DE)** |

---

### 3.3 ASCII & Radix Conversion Rules

```
                      +-------------------+
                      |   ASCII to Int    |  --> SUB AL, 48  ('0' -> 0)
                      +-------------------+
                      |   Int to ASCII    |  --> ADD AL, 48  (0 -> '0')
                      +-------------------+
                      | Lower to Upper    |  --> SUB AL, 20h ('a' -> 'A')
                      +-------------------+
                      | Upper to Lower    |  --> ADD AL, 20h ('A' -> 'a')
                      +-------------------+
                      | Case Toggle (XOR) |  --> XOR AL, 32 / 20h ('a' <-> 'A')
                      +-------------------+
                      | Hex Digit (10-15) |  --> ADD AL, 48 + 7 ('A'-'F')
                      +-------------------+
```

---

### 3.4 Address Loading & String Formatting Cheatsheet

#### 1. String Definition & Formatting Control Bytes

| Element | Syntax / Value | Architectural Function & Impact |
| :--- | :--- | :--- |
| **Data Byte** | `DB` | Allocates sequential 8-bit bytes in the `.DATA` segment. |
| **Carriage Return** | `13` (`0Dh`) | Moves the console cursor to the far-left column (`\r`). |
| **Line Feed** | `10` (`0Ah`) | Drops the console cursor straight down to the next row (`\n`). |
| **DOS Terminator** | `'$'` (`24h`) | Tells DOS `INT 21H / AH=09H` to stop printing memory. |

* **Embedded CRLF String Pattern**:
  ```assembly
  MSG2 DB 13, 10, 'Output: $'   ; Resets cursor to column 0 on new line, prints "Output: ", halts at $
  ```

#### 2. Address Loading: `MOV DX, OFFSET` vs `LEA DX`

| Directive / Instruction | Evaluation Timing | Execution Mechanism | Primary Recommended Use Case |
| :--- | :--- | :--- | :--- |
| **`MOV DX, OFFSET label`** | Compile / Assemble-time | Hardcodes constant 16-bit address into opcode. Faster, fewer bytes. | Static variables and fixed memory buffers declared in `.DATA`. |
| **`LEA DX, label`** | Run-time | Computes effective address dynamically using the CPU ALU. | Dynamic pointers, array displacements, e.g. `[BX + SI + 4]`. |

---

### 3.5 Top 5 Common Exam Bugs & Pitfalls

1. **Uninitialized Data Segment**:
   - Omitting `mov ax, @data; mov ds, ax` means memory variables and string offsets point to unmapped or invalid physical addresses.
2. **Leftover Garbage in `AH` Before `DIV`**:
   - Leaving `AH` unzeroed before `div bl` causes `AX` to be interpreted as hundreds or thousands, triggering CPU Divide Error (#DE). Always insert `mov ah, 0`.
3. **Omitting Carriage Return (`13`)**:
   - Outputting only Line Feed (`10`) drops the cursor vertically without returning to column 0. Always emit both `10` and `13`, or embed `13, 10` inside the `.DATA` string.
4. **Missing Subroutine `RET`**:
   - A procedure (`proc`) without `ret` falls through into whatever instructions follow sequentially in the code segment.
5. **Array Out-of-Bounds in `LOOP`**:
   - Setting `CX` to a count greater than the declared array size reads unallocated memory bytes, polluting accumulators and arithmetic sums. Ensure `CX` strictly equals the number of elements.
