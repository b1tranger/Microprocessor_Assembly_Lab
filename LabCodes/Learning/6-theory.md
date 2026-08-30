# Understanding `AX` Register Overwrites & Register Aliasing in 8086 Assembly

In 8086 microprocessor assembly programming, unexpected bugs often arise from accumulator register overwrites. This document explains the architectural reasons why the `AX` register (and its sub-registers `AH` and `AL`) can be modified or corrupted during code execution, followed by two comparative code examples.

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
