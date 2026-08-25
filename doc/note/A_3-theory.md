# Theory & Working Mechanism: Bitwise Operations, Control Flow, and Output Formatting in 8086 Assembly

This document explains the microprocessor architecture rules, bitwise manipulation logic, control flow mechanisms, and debugging details for [A_3.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/A_3.asm) and its corrected version [A_3_FIXED.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/A_3_FIXED.asm).

---

## 1. Overview of Tasks and Bitwise Operations

The program performs six distinct logical/shift/rotate operations on predefined 8-bit memory variables (`num1` through `num6`), extracts their high and low nibbles, and prints the resulting two-digit hexadecimal representations on separate lines.

```
Expected Output:
num1: 08
num2: FB
num3: 20
num4: 01
num5: FF
num6: F4
```

### Detailed Mathematical & Binary Verification

| Variable | Initial Value | Operation | Instruction | Binary Computation | Final Hex Result |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `num1` | `18h` (`0001 1000b`) | Bitwise AND with `0Fh` | `and al, 0Fh` | `0001 1000` $\&$ `0000 1111` = `0000 1000` | `08h` |
| `num2` | `2Ah` (`0010 1010b`) | Bitwise OR with `0D1h` | `or al, 0D1h` | `0010 1010` $\vert$ `1101 0001` = `1111 1011` | `FBh` |
| `num3` | `C4h` (`1100 0100b`) | Shift Left by 3 | `shl al, 3` | `1100 0100` $\ll 3$ = `0010 0000` | `20h` |
| `num4` | `6Bh` (`0110 1011b`) | Shift Right by 6 | `shr al, 6` | `0110 1011` $\gg 6$ = `0000 0001` | `01h` |
| `num5` | `FFh` (`1111 1111b`) | Rotate Left by 2 | `rol al, 2` | `1111 1111` rotated left by 2 = `1111 1111` | `FFh` |
| `num6` | `7Ah` (`0111 1010b`) | Rotate Right by 7 | `ror al, 7` | `0111 1010` ROR 7 $\equiv$ ROL 1 = `1111 0100` | `F4h` |

---

## 2. Root Cause Analysis: The Premature DOS Exit Problem

### What `INT 21H, AH = 4Ch` Does

In MS-DOS and Emu8086:
- `AH = 4Ch` is the **Terminate Process with Return Code** service.
- When `INT 21h` is triggered with `AH = 4Ch`, the operating system immediately terminates the program and returns control back to DOS / the emulator shell.
- **Any instructions placed after `INT 21h` in the execution flow are unreachable in a single standard run.**

```
[ Print String "num1: " ]
          ↓
[ Compute AL & Mask ]
          ↓
[ Print High & Low Nibbles: "08" ]
          ↓
[ mov ah, 4Ch / int 21h ]  --------> [ PROGRAM HALTS / RETURNS CONTROL TO OS ]
          ↓ (NEVER REACHED)
[ Print Newline CR (13), LF (10) ]
          ↓ (NEVER REACHED)
[ Next block: num2 ... ]
```

### Why the Code Required 6 Consecutive Runs

In [A_3.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/A_3.asm), each block had its own `mov ah, 4Ch / int 21h` before the newline instructions:

```assembly
; In A_3.asm (Buggy Flow):
mov al, bl
and al, 0Fh
call print_hex

mov ah, 4Ch        ; <-- Program exits here on Run 1
int 21h

; NEWLINE and CARRY BACK
mov ah, 2
mov dl, 10
int 21h
mov dl, 13
int 21h

; NUM 2 section follows...
```

1. **Run 1**: Prints `num1: 08` and executes `INT 21H, AH=4Ch`. Program halts with `"PROGRAM HAS RETURNED CONTROL TO THE OPERATING SYSTEM"`. The newline code is skipped.
2. **Run 2**: In Emu8086, clicking "Run" again without reloading leaves the Instruction Pointer (`IP`) pointing directly at the instruction after the last `INT 21H` (the newline code!). It executes the newline, computes and prints `num2: FB`, and hits the next `INT 21H, AH=4Ch`.
3. **Runs 3 to 6**: Repeats the same cycle for `num3`, `num4`, `num5`, and `num6`.

### Why the 7th Run Caused an Infinite Loop

On the 7th run:
1. The CPU resumed execution after the 6th `INT 21H, AH=4Ch` and executed the final newline (`DL=10`, `DL=13`).
2. There was no remaining code in `main proc` and **no exit call** after the newline.
3. Execution naturally fell through the end of `main proc` into the adjacent code segment: `print_hex proc`.
4. `print_hex` was executed **without a preceding `CALL` instruction** (meaning no return address was pushed to the stack).
5. When `print_hex` hit the `RET` instruction at line 253, it popped random/garbage values from the stack into `IP`, causing CPU register runaway and an infinite loop.

---

## 3. The Newline Mechanism: Carriage Return vs. Line Feed

In DOS text display systems, moving to the beginning of the next line requires two distinct operations:

```
Carriage Return (CR, ASCII 13 / 0Dh):
Moves cursor from current position back to column 0:
[num1: 08_]  --->  [_um1: 08]

Line Feed (LF, ASCII 10 / 0Ah):
Moves cursor down one row without changing column:
[_um1: 08]
    ↓
[_       ]
```

Combining both (`CR` + `LF` or `LF` + `CR`) places the cursor cleanly at the start of the next line:
```assembly
mov ah, 2
mov dl, 13    ; Carriage Return (CR)
int 21h
mov dl, 10    ; Line Feed (LF)
int 21h
```

---

## 4. Nibble Separation and Hex Conversion Logic

Because standard DOS character printing (`INT 21H, AH=02h`) only outputs one ASCII character at a time, an 8-bit byte must be split into two 4-bit nibbles:

```
                    8-Bit Register AL (e.g. FBh = 1111 1011b)
                    +-------------------+-------------------+
                    | 1   1   1   1     |     1   0   1   1 |
                    +-------------------+-------------------+
                      High Nibble (F)     Low Nibble (B)
```

### High Nibble Extraction
```assembly
mov al, bl
shr al, 4          ; Shift upper 4 bits into lowest 4 positions (AL = 0Fh)
call print_hex     ; Converts 0Fh -> 'F' (ASCII 70) and prints
```

### Low Nibble Extraction
```assembly
mov al, bl
and al, 0Fh        ; Mask off upper 4 bits (AL = 0Bh)
call print_hex     ; Converts 0Bh -> 'B' (ASCII 66) and prints
```

### Conversion Algorithm (`print_hex`)
```assembly
print_hex proc
    add al, 48         ; Add '0' (ASCII 48 / 30h)
    cmp al, 57         ; Check if digit is 0-9 (ASCII <= 57)
    jbe print_char     ; If 0-9, jump straight to output
    add al, 7          ; If A-F, add gap offset of 7 to reach 'A'-'F' (ASCII 65-70)
    
print_char:
    mov dl, al
    mov ah, 02h        ; DOS character display
    int 21h
    ret
print_hex endp
```

> [!NOTE]
> **Label Naming Note**: The original code used `out:` as a label. In x86 assembly, `OUT` is a reserved instruction mnemonic for sending data to hardware I/O ports (`OUT DX, AL`). It is best practice to use labels like `print_char:` to prevent assembler ambiguities.

---

## 5. Comparison: [A_3.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/A_3.asm) vs [A_3_FIXED.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/A_3_FIXED.asm)

| Feature | [A_3.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/A_3.asm) (Buggy) | [A_3_FIXED.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/A_3_FIXED.asm) (Fixed) |
| :--- | :--- | :--- |
| **DOS Exit Calls** | 6 exit calls (one after each number before newline) | **1 single exit call** at the very end of `main proc` |
| **Newline Execution** | Trapped behind `int 21h; ah=4Ch` (never reached on single run) | Executed immediately after printing each number |
| **Program Runs Needed** | 6 manual runs (7th crashes with loop) | **1 single clean run** |
| **Subroutine Fallthrough** | Falls into `print_hex` with empty stack on 7th run | Prevented; main cleanly exits to DOS before procedure declaration |
| **Procedure Label** | `out:` (collides with x86 `OUT` instruction) | `print_char:` (clean, unambiguous label) |
| **Output Format** | Stalled output requiring multiple re-runs | Continuous formatted output matching specification |
