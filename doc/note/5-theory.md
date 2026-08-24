# Theory & Working Mechanism: Operating on Hex Values and Nibble Separation in 8086 Assembly

This document explains the fundamental concepts, microprocessor architecture rules, and step-by-step logic behind [5.1.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/5.1.asm). Specifically, it addresses:
1. **Why we operate on Hex/Binary values in the CPU registers.**
2. **Why we cannot directly output a raw Hex byte to the screen.**
3. **Why and how we split an 8-bit byte into High and Low Nibbles.**
4. **How each nibble is converted into its human-readable ASCII representation.**

---

## 1. Operating on Hexadecimal Values in 8086 Assembly

In an 8086 microprocessor, registers like `AL`, `BL`, `AH`, etc., are **8-bit storage registers** (1 byte). 

```
+---+---+---+---+---+---+---+---+
| 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |  <-- 8 bits (1 Byte)
+---+---+---+---+---+---+---+---+
```

- Microprocessors internally execute operations on **binary bits** (`0`s and `1`s).
- Programmers and assemblers use **Hexadecimal (Base 16)** as a compact, human-readable shorthand for binary:
  - $1 \text{ Hex digit} = 4 \text{ binary bits} = 1 \text{ Nibble}$.
  - $2 \text{ Hex digits} = 8 \text{ binary bits} = 1 \text{ Byte}$.

In [5.1.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/5.1.asm#L19-L21), we have:
```assembly
mov al, num1      ; num1 is 18h = 0001 1000b
or al, 0D1h       ; 0D1h        = 1101 0001b
mov bl, al        ; Result: D9h = 1101 1001b
```

The CPU computes:
$$\begin{aligned}
\text{num1 } (18\text{h}) &= 0001\ 1000_2 \\
\text{OR } (\text{D}1\text{h}) &= 1101\ 0001_2 \\
\hline
\text{Result } (\text{D}9\text{h}) &= 1101\ 1001_2 \quad (\text{stored in } BL)
\end{aligned}$$

At this point, the register `BL` contains the raw binary value `1101 1001b` (hex value `D9h`, decimal `217`).

---

## 2. Why Can't We Directly Print the Byte `D9h`?

### The Difference Between Numerical Value and ASCII Character Code
Monitors and terminals **do not display raw numeric values**. When DOS interrupt `INT 21h, AH = 02h` is invoked, it interprets the value inside register `DL` as an **ASCII character code**.

| Value in `DL` | How Programmer Sees It | How `INT 21h` Interprets It (ASCII) | What Appears on Screen |
| :--- | :--- | :--- | :--- |
| `30h` (`48d`) | Number 48 | Character `'0'` | `0` |
| `39h` (`57d`) | Number 57 | Character `'9'` | `9` |
| `41h` (`65d`) | Number 65 | Character `'A'` | `A` |
| `44h` (`68d`) | Number 68 | Character `'D'` | `D` |
| `D9h` (`217d`)| Hex number D9 | Extended ASCII index 217 | `┘` (Box drawing character) |

If you directly move `D9h` into `DL` and trigger `INT 21h`, DOS will print `┘` or garbage symbols instead of `"D9"`.

### The Visual Display Requirement
To display `"D9"` on screen, you must output **two distinct characters** one after another:
1. First character: `'D'` (ASCII `44h` / `68d`)
2. Second character: `'9'` (ASCII `39h` / `57d`)

---

## 3. High Nibble vs. Low Nibble Separation

Because an 8-bit byte holds two 4-bit hexadecimal digits:
- **Bits [7:4]** represent the **High Nibble** (the first hex digit, `D`).
- **Bits [3:0]** represent the **Low Nibble** (the second hex digit, `9`).

```
                    8-Bit Byte (D9h = 1101 1001b)
                    +-------------+-------------+
                    | 1 1 0 1     |     1 0 0 1 |
                    +-------------+-------------+
                     High Nibble    Low Nibble
                     (Hex: 'D')     (Hex: '9')
```

To process and print them individually, we isolate each 4-bit nibble using bitwise shift and mask operations.

---

## 4. How Nibbles Are Separated in [5.1.asm](file:///c:/Users/gsmur/Documents/GitHub/UITS/Microprocessor_Assembly_Lab/5.1.asm)

### Step A: Extracting the High Nibble (`SHR AL, 4`)

To isolate the top 4 bits (`1101b`), we shift the bits 4 positions to the right:

```assembly
mov al, bl        ; AL = 1101 1001b (D9h)
shr al, 4         ; AL = 0000 1101b (0Dh = 13 decimal)
call print_hex    ; Converts 0Dh to ASCII 'D' and prints it
```

#### Bitwise Visualization of `SHR AL, 4`:
```
Before SHR:  [1] [1] [0] [1] [1] [0] [0] [1]   (D9h)
Shift >> 4:  [0] [0] [0] [0] [1] [1] [0] [1]   (0Dh)
```
The upper 4 bits are filled with `0`s, and the high nibble `Dh` is now in the lowest 4 bits (`AL = 0Dh`).

---

### Step B: Extracting the Low Nibble (`AND AL, 0Fh`)

To isolate the bottom 4 bits (`1001b`), we apply a bitmask using `0Fh` (`0000 1111b`):

```assembly
mov al, bl        ; AL = 1101 1001b (D9h)
and al, 0Fh       ; AL = 0000 1001b (09h = 9 decimal)
call print_hex    ; Converts 09h to ASCII '9' and prints it
```

#### Bitwise Visualization of `AND AL, 0Fh`:
```
  AL:        1 1 0 1  1 0 0 1   (D9h)
& Mask:      0 0 0 0  1 1 1 1   (0Fh)
-------------------------------------
  Result:    0 0 0 0  1 0 0 1   (09h)
```
The upper 4 bits are cleared to `0`, leaving only the low nibble `9h` in `AL`.

---

## 5. Converting a 4-Bit Nibble (0–F) to ASCII (`print_hex`)

Each isolated nibble is a numerical value between `0` and `15` (`00h` to `0Fh`). 

```assembly
print_hex proc
    add al, 48        ; Step 1: Add '0' (ASCII 48 / 30h)
    cmp al, 57        ; Step 2: Check if <= '9' (ASCII 57 / 39h)
    jbe out           ; If between 0 and 9, jump to print
    add al, 7         ; Step 3: For A-F, add extra offset of 7

out:
    mov dl, al        ; Put character into DL
    mov ah, 02h       ; DOS function 02h: Display character
    int 21h           ; Call DOS interrupt
    ret
print_hex endp
```

### Why Add 48 and then 7?

1. **For Digits `0` – `9` (`0h` – `9h`):**
   - Adding `48` (`30h`) maps:
     - `0 + 48 = 48` $\rightarrow$ ASCII `'0'` (`30h`)
     - `9 + 48 = 57` $\rightarrow$ ASCII `'9'` (`39h`)
   - `cmp al, 57` and `jbe out` immediately jumps to printing.

2. **For Hex Letters `A` – `F` (`Ah` – `Fh` / `10` – `15`):**
   - Adding `48` maps:
     - `10 + 48 = 58` (ASCII character `:` which is immediately after `'9'`)
   - But ASCII `'A'` is `65` (`41h`).
   - The gap between `58` (`:`) and `65` (`A`) is:
     $$65 - 58 = 7$$
   - Therefore, adding `7` bridges the gap:
     - $10 + 48 + 7 = 65 \rightarrow \text{ASCII } \text{'A'}$ (`41h`)
     - $11 + 48 + 7 = 66 \rightarrow \text{ASCII } \text{'B'}$ (`42h`)
     - $12 + 48 + 7 = 67 \rightarrow \text{ASCII } \text{'C'}$ (`43h`)
     - $13 + 48 + 7 = 68 \rightarrow \text{ASCII } \text{'D'}$ (`44h`)
     - $14 + 48 + 7 = 69 \rightarrow \text{ASCII } \text{'E'}$ (`45h`)
     - $15 + 48 + 7 = 70 \rightarrow \text{ASCII } \text{'F'}$ (`46h`)

---

## 6. End-to-End Execution Trace for `5.1.asm`

| Stage | Operation | Register / Variable State | Screen Output |
| :--- | :--- | :--- | :--- |
| **Initial** | `num1 db 018h` | `num1 = 18h` | (none) |
| **String Display** | `mov ah, 09h; int 21h` | Prints `"num1 : "` | `num1 : ` |
| **OR Operation** | `or al, 0D1h; mov bl, al` | `BL = D9h` (`1101 1001b`) | `num1 : ` |
| **High Nibble** | `shr al, 4` $\rightarrow$ `AL = 0Dh` | `AL = 13` | `num1 : ` |
| **Convert High**| `add al, 48 + 7 = 68` (`'D'`) | `DL = 'D'`, `ah = 02h`, `int 21h` | `num1 : D` |
| **Low Nibble** | `and al, 0Fh` $\rightarrow$ `AL = 09h` | `AL = 9` | `num1 : D` |
| **Convert Low** | `add al, 48 = 57` (`'9'`) | `DL = '9'`, `ah = 02h`, `int 21h` | `num1 : D9` |

---

## 7. Summary

- **Why operate on Hex?** Microprocessors natively work with 8-bit bytes (2 hex digits) during logic/arithmetic instructions (`OR`, `AND`, `ADD`, etc.).
- **Why separate nibbles?** Display hardware and DOS interrupts print one ASCII character at a time. A 2-digit hex byte cannot be printed in one step.
- **How to separate?** Use `SHR AL, 4` to extract the high nibble, and `AND AL, 0Fh` to isolate the low nibble.
- **How to print?** Convert each 4-bit nibble value (`0-15`) into its ASCII character code (`'0'-'9'` or `'A'-'F'`) by adding `48` (and `7` if $> 9$), then call `INT 21h, AH=02h`.
