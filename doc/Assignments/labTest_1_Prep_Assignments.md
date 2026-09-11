# Lab Test 1 Preparation Guide: Assignments Summary & Code Walkthrough

This document serves as the companion revision guide for **Lab Test 1**, synthesizing the theoretical principles, architectural mechanisms, and code implementations covered across the four major course assignments (**A1 through A4**) in the `doc/Assignments/` archive.

---

## Table of Contents
1. [Master Assignment Reference & Algorithm Mapping Table](#1-master-assignment-reference--algorithm-mapping-table)
2. [Assignment Deep Dives & Code Walkthroughs](#2-assignment-deep-dives--code-walkthroughs)
   - [2.1 Assignment 1 (A1): Staged Multi-Character Input & Formatted Console Display](#21-assignment-1-a1-staged-multi-character-input--formatted-console-display)
   - [2.2 Assignment 2 (A2): Fundamental 4-Operation Arithmetic Suite](#22-assignment-2-a2-fundamental-4-operation-arithmetic-suite)
   - [2.3 Assignment 3 (A3): Comprehensive Bitwise Suite, Nibble Decomposition & Exit Control Flow](#23-assignment-3-a3-comprehensive-bitwise-suite-nibble-decomposition--exit-control-flow)
     - [2.3.1 Binary Verification & Bitwise Instruction Matrix](#231-binary-verification--bitwise-instruction-matrix)
     - [2.3.2 Nibble Extraction & Hexadecimal ASCII Subroutine](#232-nibble-extraction--hexadecimal-ascii-subroutine)
     - [2.3.3 The Premature Exit Bug (A_3 vs. A_3_FIXED)](#233-the-premature-exit-bug-a_3-vs-a_3_fixed)
   - [2.4 Assignment 4 (A4): Bidirectional Case Conversion & Conditional Branching Models](#24-assignment-4-a4-bidirectional-case-conversion--conditional-branching-models)
     - [2.4.1 Threshold Comparison Logic & IF-ELSE Branching](#241-threshold-comparison-logic--if-else-branching)
     - [2.4.2 Embedded String Control Codes vs. Manual CRLF Interrupts](#242-embedded-string-control-codes-vs-manual-crlf-interrupts)
     - [2.4.3 Advanced Alternative: Branchless XOR Case Toggle](#243-advanced-alternative-branchless-xor-case-toggle)
3. [High-Yield Exam Cheat Sheet & Architecture Comparison](#3-high-yield-exam-cheat-sheet--architecture-comparison)
   - [3.1 Bitwise & Shift / Rotate Instructions Master Matrix](#31-bitwise--shift--rotate-instructions-master-matrix)
   - [3.2 Conditional Jump Reference for Range Testing](#32-conditional-jump-reference-for-range-testing)
   - [3.3 Top 5 Assignment Debugging Pitfalls](#33-top-5-assignment-debugging-pitfalls)

---

## 1. Master Assignment Reference & Algorithm Mapping Table

The table below outlines each assignment, the implemented and variant files, the core algorithms utilized, and the fundamental 8086 hardware and software concepts required.

| Assignment | Source File(s) | Primary Algorithm / Task | Core Concepts & Prerequisites Required | Key Registers & Services | Common Exam Pitfalls |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Assignment 1 (A1)** | [`A_1.asm`](./A1/A_1.asm) | **Staged Multi-Character Input & Console Formatting**<br>Prompt user, read two distinct single-digit characters, preserve them across registers, and echo them on separate lines. | • Console input interrupt (`AH=01h`) with immediate echo<br>• Register preservation using 8-bit registers (`BL`, `BH`)<br>• DOS character output service (`AH=02h`)<br>• Full CRLF formatting sequence (`10 = LF`, `13 = CR`) | `AL` (input receiver)<br>`BL`, `BH` (character buffers)<br>`DL` (output carrier)<br>`INT 21H / AH=01H, 02H, 09H` | Overwriting `AL` with the second input before saving the first. Omitting `13` (Carriage Return), resulting in diagonal text misalignment. |
| **Assignment 2 (A2)** | [`A-2.asm`](./A2/A-2.asm) | **Fundamental 4-Operation Arithmetic Suite**<br>Read two digits, execute addition, subtraction, multiplication, and division, and output all 4 results separated by spaces. | • ASCII to integer conversion (`SUB reg, 48`)<br>• Integer to ASCII conversion (`ADD reg, 48`)<br>• Unsigned multiplication (`MUL`) with implicit destination in `AX`<br>• Unsigned division (`DIV`) yielding quotient in `AL` and remainder in `AH` | `AL` (arithmetic accumulator & quotient)<br>`AH` (remainder)<br>`AX` (16-bit product / dividend)<br>`INT 21H / AH=02H` | Attempting arithmetic directly on ASCII character glyphs without subtracting 48. Failing to output both quotient and remainder for division. |
| **Assignment 3 (A3)** | [`A_3.asm`](./A3/A_3.asm)<br>[`A_3_FIXED.asm`](./A3/A_3_FIXED.asm)<br>[`assignment-3.asm`](./courtesy/assignment-3.asm)<br>*(Theory: [`A_3-theory.md`](./Learning/A_3-theory.md))* | **Comprehensive Bitwise Manipulation & 2-Digit Hex Subroutine**<br>Apply `AND`, `OR`, `SHL`, `SHR`, `ROL`, `ROR` to 6 byte variables, extract high/low nibbles, and print hex digits via a modular procedure. | • Bitwise masking (`AND 0Fh`), logical shifts (`SHR`, `SHL`), and bit rotations (`ROR`, `ROL`)<br>• High nibble isolation (`SHR reg, 4`) & low nibble masking (`AND reg, 0Fh`)<br>• Modular subroutine calls (`CALL` / `RET`) with stack management (`SP`)<br>• Hex ASCII mapping math (`+48`, `CMP 57`, `JBE`, `+7`)<br>• Single vs. premature program exit control flow | `AL` (data byte / nibble)<br>`BL` (temporary preservation)<br>`DL` (output carrier)<br>`SP`, `IP` (subroutine stack frame)<br>`INT 21H / AH=09H, 02H, 4CH` | Placing `mov ah, 4Ch; int 21h` inside iterative blocks, causing premature program termination after only the first variable. Missing `+7` for digits `'A'-'F'`. |
| **Assignment 4 (A4)** | [`A_4.asm`](./A4/A_4.asm)<br>[`A_4_alt.asm`](./A4/A_4_alt.asm)<br>*(Theory: [`A_4-theory.md`](./Learning/A_4-theory.md))* | **Bidirectional Character Case Conversion & IF-ELSE Branching**<br>Read an arbitrary alphabet character, dynamically determine whether it is uppercase or lowercase, and invert its case. | • Threshold comparison logic (`CMP AL, 60h`) and unsigned branching (`JBE`)<br>• ASCII case offset arithmetic (`+20h` for Upper $\rightarrow$ Lower; `-20h` for Lower $\rightarrow$ Upper)<br>• Structured IF-ELSE-ENDIF control flow using unconditional `JMP`<br>• Embedded control characters (`13, 10`) inside string definitions (`A_4_alt.asm`)<br>• Branchless case flipping via `XOR AL, 20h` | `AL` (character input & processing)<br>`DL` (output carrier)<br>`FLAGS` (CF, ZF from `CMP`)<br>`INT 21H / AH=01H, 02H, 09H` | Inverted condition jump targets (e.g., subtracting `20h` from an already uppercase character). Forgetting the unconditional `JMP to_Output` at the end of the IF body, causing fall-through into the ELSE block. |

---

## 2. Assignment Deep Dives & Code Walkthroughs

### 2.1 Assignment 1 (A1): Staged Multi-Character Input & Formatted Console Display
* **Files Analyzed**: [`A_1.asm`](./A1/A_1.asm) *(Direct counterpart to Lab 2.3)*.
* **Core Problem**: Read two single-digit numeric characters from user input with descriptive prompts, buffer both characters simultaneously in separate hardware registers, and display them sequentially with clean carriage returns and line feeds.

#### Key Mechanics & Architectural Insights
* **Register Preservation Strategy**:
  - The DOS read service (`INT 21H / AH=01h`) automatically returns the entered ASCII character in register `AL`.
  - Because `AL` is overwritten every time an interrupt service is invoked, multiple inputs must be staged into scratchpad registers:
    ```assembly
    mov ah, 1
    int 21h
    mov bl, al      ; Buffer first character in BL
    ...
    mov ah, 1
    int 21h
    mov bh, al      ; Buffer second character in BH
    ```
* **Full CRLF Architecture**:
  - Moving the console cursor to the beginning of the next line requires two ASCII control codes:
    1. **Line Feed (`10` / `0Ah`)**: Advances the screen cursor 1 row vertically downward without resetting the horizontal column position.
    2. **Carriage Return (`13` / `0Dh`)**: Resets the screen cursor horizontally back to column 0.
  - Omitting the carriage return leads to staggered or staircase text output.

```assembly
; ============================================================
; Assignment 1: Staged Multi-Character Input and Formatted Output
; File: A_1.asm
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

    ; 1. Print "Input:" Prompt
    mov dx, offset var1
    mov ah, 09h
    int 21h

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; 2. Read First Digit -> BL
    mov ah, 1
    int 21h
    mov bl, al

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; 3. Read Second Digit -> BH
    mov ah, 1
    int 21h
    mov bh, al

    ; Print Double Line Break before Output Section
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; 4. Print "Output:" Header
    mov dx, offset var2
    mov ah, 09h
    int 21h

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; 5. Output First Preserved Character (BL)
    mov ah, 2
    mov dl, bl
    int 21h

    ; Print CRLF
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    ; 6. Output Second Preserved Character (BH)
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

### 2.2 Assignment 2 (A2): Fundamental 4-Operation Arithmetic Suite
* **Files Analyzed**: [`A-2.asm`](./A2/A-2.asm) *(Direct counterpart to Lab 3.1)*.
* **Core Problem**: Read two single-digit decimal numbers from console input, perform addition (`+`), subtraction (`-`), multiplication (`*`), and division (`/`), and display all results separated by single space characters.

#### Key Mechanics & Architectural Insights
* **The ASCII Conversion Protocol**:
  - Console keyboard input returns the ASCII character representation, which is offset from the raw numeric quantity by $+48$ (`30h`).
  - Arithmetic operations must be preceded by `SUB reg, 48` and followed by `ADD reg, 48` prior to console output.
* **Multiplication Register Topology (`MUL`)**:
  - In 8-bit mode (`mul num2`), `AL` acts as the implicit multiplicand.
  - The 16-bit product is deposited across the full `AX` register (`AL` holds the lower byte; `AH` holds the upper byte).
  - For single-digit inputs whose product is $< 10$, the answer resides entirely within `AL`.
* **Division Register Topology (`DIV`)**:
  - In 8-bit mode (`div num2`), the 16-bit dividend is implicitly sourced from `AX`.
  - After division:
    $$\text{AL} \leftarrow \lfloor \text{AX} \div \text{divisor} \rfloor \quad (\text{Quotient})$$
    $$\text{AH} \leftarrow \text{AX} \pmod{\text{divisor}} \quad (\text{Remainder})$$
  - The program preserves and outputs both the quotient and the remainder, converting each to ASCII independently.

```assembly
; ============================================================
; Assignment 2: 4-Operation Single-Digit Arithmetic Suite
; File: A-2.asm
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

    ; Delimiter Space
    mov ah, 2
    mov dl, 32
    int 21h

    ; Read Second Number
    mov ah, 1
    int 21h
    sub al, 48                      ; Convert ASCII -> Integer
    mov num2, al

    ; Delimiter Space
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

    ; Print Space
    mov ah, 2
    mov dl, 32
    int 21h

    ; 2. SUBTRACTION
    mov al, num1
    sub al, num2
    add al, 48
    mov subt, al
    mov dl, subt
    mov ah, 2
    int 21h

    ; Print Space
    mov ah, 2
    mov dl, 32
    int 21h

    ; 3. MULTIPLICATION
    mov al, num1
    mul num2                        ; AX = AL * num2
    add al, 48
    mov multi, al
    mov dl, multi
    mov ah, 2
    int 21h

    ; Print Space
    mov ah, 2
    mov dl, 32
    int 21h

    ; 4. DIVISION
    mov al, num1
    mov ah, 0                       ; Clear AH to prevent divide exception
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

### 2.3 Assignment 3 (A3): Comprehensive Bitwise Suite, Nibble Decomposition & Exit Control Flow
* **Files Analyzed**: [`A_3.asm`](./A3/A_3.asm), [`A_3_FIXED.asm`](./A3/A_3_FIXED.asm), [`assignment-3.asm`](./courtesy/assignment-3.asm), and [`A_3-theory.md`](./Learning/A_3-theory.md).
* **Core Problem**: Apply 6 distinct logical, shift, and rotate bitwise operations to memory variables (`num1` through `num6`), decompose the resulting bytes into high and low nibbles, and output the 2-digit hexadecimal representations line by line via a modular procedure.

#### 2.3.1 Binary Verification & Bitwise Instruction Matrix

| Variable | Initial Hex / Binary | Instruction | Bitwise Operation Performed | Binary Result | Final Hex Output |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `num1` | `18h` (`0001 1000b`) | `and al, 0Fh` | Bitwise AND with lower-nibble mask (`0000 1111b`) | `0000 1000b` | **`08h`** |
| `num2` | `2Ah` (`0010 1010b`) | `or al, 0D1h` | Bitwise OR with pattern (`1101 0001b`) | `1111 1011b` | **`FBh`** |
| `num3` | `C4h` (`1100 0100b`) | `shl al, 3` | Shift Left by 3 bits (zeroes filled from right) | `0010 0000b` | **`20h`** |
| `num4` | `6Bh` (`0110 1011b`) | `shr al, 6` | Shift Right by 6 bits (zeroes filled from left) | `0000 0001b` | **`01h`** |
| `num5` | `FFh` (`1111 1111b`) | `rol al, 2` | Rotate Left by 2 bits (bits wrapped around) | `1111 1111b` | **`FFh`** |
| `num6` | `7Ah` (`0111 1010b`) | `ror al, 7` | Rotate Right by 7 bits (equivalent to `ROL 1`) | `1111 0100b` | **`F4h`** |

---

#### 2.3.2 Nibble Extraction & Hexadecimal ASCII Subroutine
* **The High Nibble Extraction**:
  - An 8-bit byte stores bits 7..4 in the upper nibble.
  - Executing `shr al, 4` slides the top 4 bits down to bit positions 3..0 while padding bit positions 7..4 with zeroes:
    $$1111\ 0100_2 \xrightarrow{\text{SHR 4}} 0000\ 1111_2 \quad (15_{10} = \text{'F'})$$
* **The Low Nibble Extraction**:
  - Mask the original value with `0Fh` (`00001111b`):
    $$1111\ 0100_2 \ \& \ 0000\ 1111_2 = 0000\ 0100_2 \quad (4_{10} = \text{'4'})$$
* **The Hex ASCII Procedure (`print_hex`)**:
  - If nibble $\le 9$: `add al, 48` converts $0..9 \rightarrow \text{'0'}..\text{'9'}$.
  - If nibble $\ge 10$: `add al, 48` yields $58..63$ (special symbols). An additional $+7$ adjustment brings the code to $65..70$ ($\text{'A'}..\text{'F'}$):
    $$\text{ASCII Glyph} = \text{Nibble} + 48 + 7 = \text{Nibble} + 55$$

---

#### 2.3.3 The Premature Exit Bug (`A_3.asm` vs. `A_3_FIXED.asm`)
* **The Bug in `A_3.asm`**:
  - Inside `A_3.asm`, every operation block concluded with:
    ```assembly
    mov ah, 4Ch
    int 21h
    ; CRLF instructions placed here...
    ```
  - `INT 21H / AH=4Ch` unconditionally halts the CPU and returns control to DOS immediately.
  - As a result, only `num1` ever executed. The program required six separate modifications and executions to view all results.
* **The Fix in `A_3_FIXED.asm`**:
  - Removed all premature `4Ch` calls.
  - Implemented proper sequential CRLF printing (`13` followed by `10`) between blocks.
  - Placed a single `INT 21H / AH=4Ch` termination interrupt at the very end of `main proc`.

```assembly
; ============================================================
; Assignment 3: Comprehensive Bitwise Suite & Hex Subroutine
; File: A_3_FIXED.asm
; ============================================================
.model small
.stack 100h
.data
    num1 db 018h 
    num2 db 02Ah
    num3 db 0C4h
    num4 db 06Bh
    num5 db 0FFh
    num6 db 07Ah
    
    msg1 db "num1: $"  
    msg2 db "num2: $"  
    msg3 db "num3: $"  
    msg4 db "num4: $"  
    msg5 db "num5: $"  
    msg6 db "num6: $"  

.code   
main proc 
    mov ax, @data
    mov ds, ax
    
    ; --- NUM 1: Bitwise AND ---
    mov dx, offset msg1
    mov ah, 09h
    int 21h
    
    mov al, num1
    and al, 0Fh
    mov bl, al  
    
    mov al, bl 
    shr al, 4                       ; Extract high nibble
    call print_hex
    mov al, bl
    and al, 0Fh                     ; Extract low nibble
    call print_hex
    
    ; Print CRLF
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    ; --- NUM 2: Bitwise OR ---
    mov dx, offset msg2
    mov ah, 09h
    int 21h
    
    mov al, num2
    or al, 0D1h
    mov bl, al  
    
    mov al, bl 
    shr al, 4
    call print_hex
    mov al, bl
    and al, 0Fh
    call print_hex
    
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    ; --- NUM 3: Shift Left (SHL) ---
    mov dx, offset msg3
    mov ah, 09h
    int 21h
    
    mov al, num3
    shl al, 3
    mov bl, al  
    
    mov al, bl 
    shr al, 4
    call print_hex
    mov al, bl
    and al, 0Fh
    call print_hex
    
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    ; --- NUM 4: Shift Right (SHR) ---
    mov dx, offset msg4
    mov ah, 09h
    int 21h
    
    mov al, num4
    shr al, 6
    mov bl, al  
    
    mov al, bl 
    shr al, 4
    call print_hex
    mov al, bl
    and al, 0Fh
    call print_hex
    
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    ; --- NUM 5: Rotate Left (ROL) ---
    mov dx, offset msg5
    mov ah, 09h
    int 21h
    
    mov al, num5
    rol al, 2
    mov bl, al  
    
    mov al, bl 
    shr al, 4
    call print_hex
    mov al, bl
    and al, 0Fh
    call print_hex
    
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    ; --- NUM 6: Rotate Right (ROR) ---
    mov dx, offset msg6
    mov ah, 09h
    int 21h
    
    mov al, num6
    ror al, 7
    mov bl, al  
    
    mov al, bl 
    shr al, 4
    call print_hex
    mov al, bl
    and al, 0Fh
    call print_hex
    
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
       
    ; Single Graceful Exit
    mov ah, 4Ch
    int 21h
main endp

; ------------------------------------------------------------
; Subroutine: print_hex
; Input: AL = nibble (0..15)
; Output: Prints character ('0'..'9', 'A'..'F') via INT 21H / AH=02H
; ------------------------------------------------------------
print_hex proc
    add al, 48
    cmp al, 57
    jbe print_char
    add al, 7

print_char:
    mov dl, al
    mov ah, 02h
    int 21h
    ret                             ; Pop IP from stack, return to caller
print_hex endp

end main
```

---

### 2.4 Assignment 4 (A4): Bidirectional Case Conversion & Conditional Branching Models
* **Files Analyzed**: [`A_4.asm`](./A4/A_4.asm), [`A_4_alt.asm`](./A4/A_4_alt.asm), and [`A_4-theory.md`](./Learning/A_4-theory.md).
* **Core Problem**: Read an arbitrary letter from standard input, classify whether it is uppercase or lowercase using hardware comparison flags, and convert it to its inverted case.

#### 2.4.1 Threshold Comparison Logic & IF-ELSE Branching
* **ASCII Layout Boundaries**:
  - Uppercase letters: `'A'` ($41h = 65_{10}$) through `'Z'` ($5Ah = 90_{10}$).
  - Character immediately following `'Z'`: `'['` ($5Bh = 91_{10}$).
  - Character immediately preceding `'a'`: ``'`'`` ($60h = 96_{10}$).
  - Lowercase letters: `'a'` ($61h = 97_{10}$) through `'z'` ($7Ah = 122_{10}$).
* **The Threshold Test**:
  - `cmp al, 60h`:
    - If `AL <= 60h` (Condition `JBE` true): The character belongs to the uppercase set $\le 'Z'$.
    - If `AL > 60h` (Condition `JBE` false): The character belongs to the lowercase set $\ge 'a'$.
* **Structured IF-ELSE Architecture**:
  ```assembly
      mov al, char
      cmp al, 60h
      jbe to_SMALL        ; IF (AL <= 60h) -> Go to Uppercase-to-Lowercase branch

      ; ELSE BLOCK: Already Lowercase, convert to Uppercase
      sub al, 20h         ; 'a' - 20h = 'A'
      jmp to_Output       ; CRITICAL: Bypass the IF block

  to_SMALL:
      add al, 20h         ; 'A' + 20h = 'a'

  to_Output:
      mov char, al
      ; print character...
  ```

---

#### 2.4.2 Embedded String Control Codes vs. Manual CRLF Interrupts
* **Manual Interrupt Calls (`A_4.asm`)**:
  - Uses 4 separate instructions to emit newline characters (`mov ah, 02h; mov dl, 10; int 21h; mov dl, 13; int 21h`).
* **Embedded Control Bytes (`A_4_alt.asm`)**:
  - Embeds the Carriage Return (`13`) and Line Feed (`10`) bytes directly into the string declaration:
    ```assembly
    msg2 db 13, 10, "Output : $"
    ```
  - When `INT 21H / AH=09h` executes on `msg2`, the DOS service automatically processes the `13` and `10` control bytes before printing `"Output : "`, eliminating manual newline interrupts entirely.

---

#### 2.4.3 Advanced Alternative: Branchless XOR Case Toggle
* **Binary Analysis of the Case Bit**:
  - The only difference between uppercase and lowercase ASCII letters is **Bit 5** ($2^5 = 32_{10} = 20_{16}$):
    $$\text{'A'} = 01\mathbf{0}0\ 0001_2 \quad (41h)$$
    $$\text{'a'} = 01\mathbf{1}0\ 0001_2 \quad (61h)$$
* **The Single-Instruction Inversion**:
  - By XORing with $20_{16}$ (`xor al, 20h`), bit 5 is unconditionally inverted ($0 \rightarrow 1$ and $1 \rightarrow 0$):
    - If uppercase: Bit 5 becomes 1 $\rightarrow$ Converts to lowercase!
    - If lowercase: Bit 5 becomes 0 $\rightarrow$ Converts to uppercase!
  - **Zero branches, zero conditional jumps, zero labels required.**

```assembly
; ============================================================
; Assignment 4: Bidirectional Case Converter (Embedded CRLF)
; File: A_4_alt.asm
; ============================================================
.model small
.stack 100h
.data
    msg1 db "Input: $"
    msg2 db 13, 10, "Output : $"    ; Embedded CRLF bytes streamline console flow
    char db ?

.code
main proc     
    mov ax, @data
    mov ds, ax
    
    ; Display Prompt
    mov dx, offset msg1
    mov ah, 09h
    int 21h  
    
    ; Read Character
    mov ah, 01h
    int 21h
    mov char, al 
    
    ; Display Output String (CRLF triggered automatically)
    mov dx, offset msg2
    mov ah, 09h
    int 21h
      
    ; Dynamic Case Conversion Branch
    mov al, char
    cmp al, 60h                     ; Compare against boundary 60h
    jbe to_SMALL                    ; If <= 60h, character is Uppercase
    
    ; Case: Lowercase -> Convert to Uppercase
    sub al, 20h 
    jmp to_Output                   ; Skip to_SMALL block
    
to_SMALL:
    ; Case: Uppercase -> Convert to Lowercase
    add al, 20h
    
to_Output: 
    mov char, al
    mov ah, 02h
    mov dl, char
    int 21h
    
exit: 
    mov ah, 4ch
    int 21h      
main endp  
end main
```

---

## 3. High-Yield Exam Cheat Sheet & Architecture Comparison

### 3.1 Bitwise & Shift / Rotate Instructions Master Matrix

| Instruction | Full Name | Operation Description | CPU Flags Affected | Typical Assembly Use Case |
| :--- | :--- | :--- | :--- | :--- |
| `AND dest, src` | Logical AND | `dest = dest & src` | `CF=0`, `OF=0`, updates `SF`, `ZF`, `PF` | Masking out specific bits (e.g., lower nibble: `AND AL, 0Fh`). |
| `OR dest, src` | Logical OR | `dest = dest \| src` | `CF=0`, `OF=0`, updates `SF`, `ZF`, `PF` | Setting specific bits without altering others. |
| `XOR dest, src` | Logical Exclusive OR | `dest = dest ^ src` | `CF=0`, `OF=0`, updates `SF`, `ZF`, `PF` | Inverting bits, toggling case (`XOR AL, 20h`), zeroing registers (`XOR AX, AX`). |
| `NOT dest` | One's Complement | Inverts all bits ($0 \leftrightarrow 1$) | **None** (Flags remain completely unchanged) | Bitwise negation and inversion. |
| `SHL dest, count` | Shift Logical Left | Bits shift left; zeroes enter bit 0; MSB enters `CF` | `CF`, `OF` (for 1-bit shifts), updates `SF`, `ZF` | Multiplying by powers of 2 ($2^{\text{count}}$). |
| `SHR dest, count` | Shift Logical Right | Bits shift right; zeroes enter bit 7; LSB enters `CF` | `CF`, `OF` (for 1-bit shifts), updates `SF`, `ZF` | Dividing unsigned numbers by powers of 2, isolating high nibble. |
| `ROL dest, count` | Rotate Left | Bits rotate left; bit 7 moves to bit 0 and into `CF` | `CF`, `OF` | Bit rearrangement without losing bits. |
| `ROR dest, count` | Rotate Right | Bits rotate right; bit 0 moves to bit 7 and into `CF` | `CF`, `OF` | Bit rearrangement without losing bits. |

---

### 3.2 Conditional Jump Reference for Range Testing

For unsigned ASCII character classification (`CMP AL, Value`):

| Jump Opcode | Condition Tested | Flag State Required | Practical Meaning in ASCII Range Testing |
| :--- | :--- | :--- | :--- |
| `JE` / `JZ` | Equal / Zero | `ZF = 1` | `AL == Value` (Exact character match). |
| `JNE` / `JNZ` | Not Equal / Not Zero | `ZF = 0` | `AL != Value`. |
| `JB` / `JNAE` | Below / Not Above or Equal | `CF = 1` | `AL < Value` (Strictly below boundary). |
| `JBE` / `JNA` | Below or Equal / Not Above | `CF = 1` or `ZF = 1` | `AL <= Value` (Belongs to lower category $\le 60h$). |
| `JA` / `JNBE` | Above / Not Below or Equal | `CF = 0` and `ZF = 0` | `AL > Value` (Strictly above boundary). |
| `JAE` / `JNB` | Above or Equal / Not Below | `CF = 0` | `AL >= Value` (Belongs to higher category). |

---

### 3.3 Top 5 Assignment Debugging Pitfalls

1. **Premature `INT 21H / AH=4Ch` Termination**:
   - Calling service `4Ch` prematurely inside iterative logic or sequential blocks terminates the entire program immediately, stranding subsequent output code. Use `4Ch` strictly once at the end of the program.
2. **Missing Unconditional Jump (`JMP`) in IF-ELSE Blocks**:
   - Omitting `JMP to_Output` at the end of the `IF` body causes execution to fall straight through into the `ELSE` block, reversing the operation immediately.
3. **Register Clobbering in Subroutines**:
   - Calling `INT 21H / AH=02h` modifies `AL` in some DOS implementations. When implementing subroutines like `print_hex`, ensure all shared registers are preserved via the stack or scratchpad registers.
4. **Incorrect Hex Adjustment Offset**:
   - Adding only $+48$ to values between $10$ and $15$ prints ASCII symbols (`:`, `;`, `<`, `=`, `>`, `?`). An additional $+7$ offset must be conditionally added to reach `'A'` through `'F'`.
5. **Direct ASCII Arithmetic Without Normalization**:
   - Performing addition or multiplication directly on ASCII numbers without subtracting $48$ produces invalid characters due to double ASCII biasing ($48 + 48 = 96$).
