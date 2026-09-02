# Procedures, Labels, and Control Flow in 8086 Assembly

In 8086 assembly programming, structuring code and controlling the flow of execution involves two fundamental concepts: **Subroutines (Procedures)** and **Branching (Jumps)**. This document explains the differences between `PROC` directives, plain labels, `CALL`/`RET` mechanics, and conditional jumps (`JMP`, `JBE`, etc.), using the hexadecimal printing routine as a practical example.

---

## Table of Contents

1. [Procedures (`PROC` / `ENDP`) vs. Plain Labels (`label:`)](#1-procedures-proc--endp-vs-plain-labels-label)
2. [`CALL` / `RET` (Functions) vs. `JMP` / Conditional Jumps (Branching)](#2-call--ret-functions-vs-jmp--conditional-jumps-branching)
3. [Case Study: Dissecting the `print_hex` Routine](#3-case-study-dissecting-the-print_hex-routine)
4. [Key Takeaways & Best Practices](#4-key-takeaways--best-practices)
5. [Branch Label Reach & Jump Ranges](#5-branch-label-reach--jump-ranges)
6. [Implementing IF-ELSE in 8086 Assembly](#6-implementing-if-else-in-8086-assembly)
7. [Calling Procedures (`to_CAPITAL` & `to_SMALL`) in an IF-ELSE Block](#7-calling-procedures-to_capital--to_small-in-an-if-else-block)
8. [Alternative IF-ELSE Methods Without `CMP` / `JBE`](#8-alternative-if-else-methods-without-cmp--jbe)
   - [8.1 `TEST` Instruction (Bit 5 Checking)](#1-test-instruction-bit-5-checking)
   - [8.2 Single-Instruction Case Toggle (XOR 20h)](#2-single-instruction-case-toggle-no-jumps--no-if-else)
9. [Common Bugs to Avoid in `A_4.asm`](#9-common-bugs-to-avoid-in-a_4asm)
10. [Complete 8086 Jump Instructions Reference](#10-complete-8086-jump-instructions-reference)
    - [Group 1: Unconditional Jump (`JMP`)](#group-1-unconditional-jump)
    - [Group 2: Unsigned Comparison Jumps (`JA`, `JB`, `JE`, etc.)](#group-2-unsigned-comparison-jumps)
    - [Group 3: Signed Comparison Jumps (`JG`, `JL`, `JGE`, etc.)](#group-3-signed-comparison-jumps)
    - [Group 4: Simple Flag & Register-Based Jumps (`JCXZ`, `JS`, `JO`, etc.)](#group-4-simple-flag--register-based-jumps)
    - [Master Jump Summary Table](#master-jump-summary-table)
11. [Branching (Jumps) vs. Procedure Calls (`CALL`/`RET`): Standard Practice & Trade-offs](#11-branching-jumps-vs-procedure-calls-callret-standard-practice--trade-offs)

---

## 1. Procedures (`PROC` / `ENDP`) vs. Plain Labels (`label:`)


### What is a Procedure?
A procedure (subroutine) in 8086 assembly is defined using the `PROC` and `ENDP` directives:

```assembly
print_hex PROC
    ; Procedure body
    ret
print_hex ENDP
```

- **`PROC` and `ENDP` are Assembler Directives**: They are instructions for the assembler (MASM, TASM, emu8086), not actual CPU instructions.
- **Memory Model / Return Type Handling**: When you define a procedure, the assembler determines whether it is `NEAR` (within the same code segment) or `FAR` (across different segments). When it encounters `RET`, it automatically generates either a near return (`RETN`, popping 2 bytes for `IP`) or a far return (`RETF`, popping 4 bytes for `IP` and `CS`).
- **Scope & Readability**: They delineate clear modular boundaries for subroutines in your code.

### What is a Plain Label?
A label is simply a symbolic name marking a specific memory offset in the code segment:

```assembly
print_hex:
    ; Routine body
    ret
```

- **Address Marker**: `print_hex:` simply tells the assembler: *"Remember this memory address by the name `print_hex`."*

### Can You Call a Plain Label (`call print_hex:`)?
**Yes.** In 8086 assembly, the CPU's `CALL` instruction only requires an address (offset). Even if defined with a plain label, `CALL print_hex` will push the Instruction Pointer (`IP`) onto the stack and jump to that label. When the CPU reaches `RET`, it will pop `IP` off the stack and return.

> [!NOTE]
> While a plain label works with `CALL` in a `SMALL` memory model, using `PROC ... ENDP` is the standard practice because it prevents segment return bugs and makes the code modular and maintainable.

---

## 2. `CALL` / `RET` (Functions) vs. `JMP` / Conditional Jumps (Branching)

A common misconception is treating branch labels (like `out:`) as user-defined functions called with jump instructions (`jbe`, `jmp`).

### How `CALL` and `RET` Work (Subroutine Calls)
1. **`CALL target`**:
   - The CPU automatically pushes the address of the *next* instruction (the return address in `IP`) onto the Stack.
   - It sets `IP` to the address of `target`.
2. **`RET`**:
   - The CPU pops the top 16-bit value from the Stack into `IP`.
   - Execution resumes seamlessly right after the original `CALL` instruction.

```
Caller Code               Procedure (print_hex)
+-------------------+      +-------------------+
| mov al, bl        |      | add al, 48        |
| call print_hex ---+----->| ...               |
| [Next Inst.] <----+------+--- ret            | (Pops return address)
+-------------------+      +-------------------+
 (Stack saves IP)
```

---

### How `JMP` and Conditional Jumps (`JBE`, `JE`, `JNE`, etc.) Work (Branching)
- **Direct Control Transfer**: Jumps do **not** interact with the Stack. They do not store a return address.
- **One-Way Execution**: A jump simply overwrites `IP` with the target label's address. There is no `RET` mechanism to return back automatically.
- **Purpose**: Used to implement conditionals (`if-else`), loops (`while`, `for`), and multi-way branching.

---

### Comparison Summary

| Feature | `CALL` / `RET` (Procedure / Subroutine) | `JMP` / Conditional Jumps (`JBE`, `JE`, etc.) |
| :--- | :--- | :--- |
| **Stack Usage** | **Pushes** return address (`IP`) to Stack. | **No stack modification**. |
| **Return Mechanism** | `RET` pops `IP` to return to caller. | None. Execution flows forward from the jump target. |
| **High-Level Analogy** | Calling a function: `myFunction();` | `if`, `else`, `goto`, `while`, `for` |
| **Execution Flow** | Deviates temporarily, then returns. | Permanently transfers execution to target. |

---

## 3. Case Study: Dissecting the `print_hex` Routine

Consider the hexadecimal print routine from `5.1.asm`:

```assembly
; In main:
    mov al, bl 
    shr al, 4          ; Get upper 4 bits (nibble)
    call print_hex     ; [1] FUNCTION CALL

    mov al, bl
    and al, 0Fh        ; Get lower 4 bits (nibble)
    call print_hex     ; [2] FUNCTION CALL
    ...

; Subroutine:
print_hex proc
    add al, 48         ; Convert 0-9 to ASCII '0'-'9' (48 = '0')
    cmp al, 57         ; Compare with ASCII '9' (57 = '9')
    jbe out            ; [3] CONDITIONAL JUMP (If al <= '9', skip letter adjustment)
    add al, 7          ; [4] Adjustment for hex digits 10-15 ('A'-'F')
    
   out:                ; [5] BRANCH TARGET LABEL (Not a function)
    mov dl, al
    mov ah, 02h 
    int 21h            ; Print character to console
    ret                ; [6] RETURN to caller

print_hex endp
```

### Trace & Execution Breakdown:

1. **`call print_hex` (Lines 27 & 31)**:
   - Pushes return address onto stack and transfers control to `print_hex`.
2. **ASCII Conversion Math**:
   - Digits `0` through `9` map to ASCII `30h`–`39h` (48–57 in decimal). Adding `48` converts them directly.
   - Digits `10` through `15` (`0Ah`–`0Fh`) must map to ASCII `'A'`–`'F'` (`41h`–`46h` / 65–70 decimal).
   - Adding `48` produces `58` to `63`. To reach `65` (`'A'`), an additional `+7` is needed ($58 + 7 = 65$).
3. **`jbe out` (Line 43)**:
   - If the value in `AL` is $\le 57$ (i.e., it is a digit `'0'`–`'9'`), it jumps directly to `out:`, skipping the `add al, 7`.
   - If `AL` $> 57$, execution falls through and adds `7` to reach `'A'`–`'F'`.
4. **`out:` (Line 46)**:
   - This is **not a function**. It is simply the meeting point (merge label) of the `if-else` path before displaying the character.
5. **`ret` (Line 50)**:
   - Pops the return address stored during step 1 and returns control back to `main`.

### High-Level Language Equivalent (C / C++):
```c
void print_hex(unsigned char al) {
    al += 48;
    if (al > 57) {       // In assembly: inverted condition via `jbe out`
        al += 7;
    }
    // out:
    putchar(al);
}
```

---

## 4. Key Takeaways & Best Practices

1. **Use `PROC ... ENDP` for Functions**: Always wrap reusable subroutines in `proc` blocks and terminate them with `ret`.
2. **Use Labels (`label:`) for Branching**: Use local labels with conditional jumps (`je`, `jne`, `jb`, `jbe`, `ja`, `jae`) for `if-else` logic and loops.
3. **Never Forget `ret` in a Procedure**: Without `ret`, the CPU will not return to `main`; it will fall through and execute whatever instructions follow sequentially in memory, leading to crashes or undefined behavior.
4. **Preserve Registers When Needed**: If a procedure alters registers that the caller depends on, use `PUSH` at the start and `POP` in reverse order before `RET`.

---

## 5. Branch Label Reach & Jump Ranges

A branch label is **not restricted to the immediate next line**. Labels mark arbitrary points in memory, allowing forward jumps (skipping code blocks) or backward jumps (loops).

### 1. Forward Branching (Skipping Code)
Used for conditional execution like `if-else` blocks:
```assembly
    cmp al, 'Q'
    je quit_program       ; Jumps forward over many instructions

    ; Multiple lines of processing...
    mov bx, 10
    add ax, bx

quit_program:
    mov ah, 4Ch
    int 21h
```

### 2. Backward Branching (Loops)
Used to repeat execution:
```assembly
    mov cx, 5
repeat_loop:
    mov ah, 02h
    mov dl, '*'
    int 21h
    dec cx
    jnz repeat_loop       ; Jumps backward to repeat_loop
```

### 3. 8086 Jump Distance Limits
- **Conditional Jumps (`JE`, `JNE`, `JB`, `JBE`, etc.)**: Use an 8-bit signed relative offset, giving a reach of **$-128$ to $+127$ bytes** (roughly 40–60 instructions).
- **Near Unconditional Jump (`JMP label`)**: Uses a 16-bit relative offset, reaching anywhere within the **64 KB segment** ($-32,768$ to $+32,767$ bytes).
- **Far Jump (`JMP FAR PTR label`)**: Reaches across different segments by changing both `CS` and `IP`.

---

## 6. Implementing IF-ELSE in 8086 Assembly

In 8086 assembly, there is no high-level `if / else` syntax. Instead, every branch is implemented using **comparison/test instructions + conditional jumps + unconditional jumps (`JMP`)**.

### Standard IF-ELSE Control Structure Pattern

```
           +------------------+
           |   cmp / test     |
           +------------------+
                     |
            [ Condition True? ]
             /              \
           YES               NO
           /                  \
   +---------------+     +---------------+
   | IF Block Code |     | ELSE Block    |
   | (e.g. CALL A) |     | (e.g. CALL B) |
   | jmp end_if    |     +---------------+
   +---------------+             |
           \                     /
            \                   /
             +-----------------+
             |  end_if / exit  |
             +-----------------+
```

---

## 7. Calling Procedures (`to_CAPITAL` & `to_SMALL`) in an IF-ELSE Block

In `A_4.asm`, the goal is to toggle case:
- If character is **Lowercase (`'a'`–`'z'`)**, call `to_CAPITAL` (`sub al, 20h`).
- If character is **Uppercase (`'A'`–`'Z'`)**, call `to_SMALL` (`add al, 20h`).

### Approach 1: Range-Based IF-ELSE with Procedures

```assembly
    mov al, char            ; Load input character

    ; --- IF (al >= 'a' AND al <= 'z') -> LOWERCASE ---
    cmp al, 'a'
    jb check_upper          ; If < 'a', check uppercase branch
    cmp al, 'z'
    ja check_upper          ; If > 'z', check uppercase branch
    
    call to_CAPITAL         ; Character is lowercase -> convert to uppercase
    jmp display_result      ; Jump past ELSE branch to avoid double conversion!

check_upper:
    ; --- ELSE IF (al >= 'A' AND al <= 'Z') -> UPPERCASE ---
    cmp al, 'A'
    jb display_result       ; Not a letter -> skip conversion
    cmp al, 'Z'
    ja display_result       ; Not a letter -> skip conversion
    
    call to_SMALL           ; Character is uppercase -> convert to lowercase

display_result:
    mov dl, al              ; Print converted AL (not original char!)
    mov ah, 02h
    int 21h
```

---

## 8. Alternative IF-ELSE Methods Without `CMP` / `JBE`

### 1. `TEST` Instruction (Bit 5 Checking)
In ASCII, the only difference between uppercase and lowercase letters is **Bit 5** (`20h` = `0010 0000b`):
- Uppercase `'A'` = `41h` (`0100 0001b`) $\rightarrow$ Bit 5 is **`0`**.
- Lowercase `'a'` = `61h` (`0110 0001b`) $\rightarrow$ Bit 5 is **`1`**.

```assembly
    mov al, char
    test al, 20h            ; Non-destructive AND with 00100000b
    jz is_uppercase         ; If Zero Flag (ZF=1), Bit 5 is 0 -> Uppercase
    
    ; Bit 5 was 1 -> Lowercase
    call to_CAPITAL
    jmp display_result

is_uppercase:
    call to_SMALL

display_result:
```

### 2. Single-Instruction Case Toggle (No Jumps / No IF-ELSE)
If you already know the input is an alphabet letter, XOR with `20h` flips Bit 5 directly:
```assembly
    mov al, char
    xor al, 20h             ; Toggles 'A' <-> 'a', 'B' <-> 'b'
```

---

## 9. Common Bugs to Avoid in `A_4.asm`

1. **`add al, char` instead of `mov al, char`**:
   - `add al, char` adds the ASCII character to whatever residual value was left in `AL` by previous interrupts. Always use `mov al, char`.
2. **Printing `char` instead of `AL`**:
   - `mov dl, char` prints the untouched original variable. To print the procedure's return value, use `mov dl, al`.
3. **Missing `jmp to_Output` after the IF/ELSE branch (Sequential Fall-Through Bug)**:
   - In assembly, **labels (`to_SMALL:`) do NOT stop or redirect the CPU**. If execution reaches a label sequentially, the CPU simply ignores the label marker and executes the instruction right beneath it.
   - If you omit `jmp to_Output` after `sub al, 20h`:
     1. Lowercase input `'a'` ($61h$) is converted: $\text{AL} - 20h = 41h$ (`'A'`).
     2. Without `jmp to_Output`, CPU falls through into `to_SMALL:` and runs `add al, 20h`.
     3. $\text{AL}$ becomes $41h + 20h = 61h$ (`'a'`).
     4. **The subtraction is instantly undone**, and lowercase letters never become uppercase!
4. **Comparing with `60h` vs `'a'` / `'Z'`**:
   - `cmp al, 60h` + `jbe to_SMALL` works because `60h` (backtick `` ` ``) is the character immediately before `'a'`. Since $'A'..'Z' \le 60h$ and $'a'..'z' > 60h$, the condition cleanly separates uppercase and lowercase.
   - However, writing `cmp al, 'a'` with `jb` or `cmp al, 'Z'` with `jbe` is far more readable and self-documenting.

---


## 10. Complete 8086 Jump Instructions Reference


Jump instructions in 8086 are divided into four primary groups: **Unconditional Jumps**, **Unsigned Arithmetic/Comparison Jumps**, **Signed Arithmetic/Comparison Jumps**, and **Single-Flag / Special Register Jumps**.

---

### Group 1: Unconditional Jump
Transfers execution without checking any flags or conditions.

* **`JMP target`**:
  * Overwrites `IP` with target offset.
  * **Short / Near**: Stays within code segment ($-128..+127$ bytes or $64\text{ KB}$).
  * **Far**: Crosses segments by changing both `CS` and `IP`.

---

### Group 2: Unsigned Comparison Jumps
Used after `CMP dest, src` when operands represent **unsigned numbers, ASCII character codes, or memory addresses**.

* **`JE` / `JZ`** (*Equal / Zero*): Jump if `dest == src` ($\text{ZF} = 1$).
* **`JNE` / `JNZ`** (*Not Equal / Not Zero*): Jump if `dest != src` ($\text{ZF} = 0$).
* **`JA` / `JNBE`** (*Above / Not Below or Equal*): Jump if `dest > src` ($\text{CF} = 0 \text{ and } \text{ZF} = 0$).
* **`JAE` / `JNB` / `JNC`** (*Above or Equal / Not Below / No Carry*): Jump if `dest >= src` ($\text{CF} = 0$).
* **`JB` / `JNAE` / `JC`** (*Below / Not Above or Equal / Carry*): Jump if `dest < src` ($\text{CF} = 1$).
* **`JBE` / `JNA`** (*Below or Equal / Not Above*): Jump if `dest <= src` ($\text{CF} = 1 \text{ or } \text{ZF} = 1$).

> [!TIP]
> Always use **Above / Below (`JA`, `JB`, `JAE`, `JBE`)** when comparing ASCII characters (like `'A'`, `'a'`, `'0'`) because ASCII values are strictly unsigned ($0..255$).

---

### Group 3: Signed Comparison Jumps
Used after `CMP dest, src` when operands represent **signed two's complement integers** (where the highest bit represents the sign: $-128..+127$ or $-32768..+32767$).

* **`JG` / `JNLE`** (*Greater / Not Less or Equal*): Jump if signed `dest > src` ($\text{ZF} = 0 \text{ and } \text{SF} = \text{OF}$).
* **`JGE` / `JNL`** (*Greater or Equal / Not Less*): Jump if signed `dest >= src` ($\text{SF} = \text{OF}$).
* **`JL` / `JNGE`** (*Less / Not Greater or Equal*): Jump if signed `dest < src` ($\text{SF} \ne \text{OF}$).
* **`JLE` / `JNG`** (*Less or Equal / Not Greater*): Jump if signed `dest <= src` ($\text{ZF} = 1 \text{ or } \text{SF} \ne \text{OF}$).

---

### Group 4: Simple Flag & Register-Based Jumps

| Instruction | Full Name | Flag / Register Condition | Common Use Case |
| :--- | :--- | :--- | :--- |
| **`JC`** | Jump if Carry | $\text{CF} = 1$ | Unsigned overflow, arithmetic carry |
| **`JNC`** | Jump if No Carry | $\text{CF} = 0$ | Successful unsigned arithmetic |
| **`JZ`** | Jump if Zero | $\text{ZF} = 1$ | Result is zero / strings matched |
| **`JNZ`** | Jump if Not Zero | $\text{ZF} = 0$ | Loop counter $> 0$, non-zero test |
| **`JS`** | Jump if Sign (Negative) | $\text{SF} = 1$ | Number is negative (MSB $= 1$) |
| **`JNS`** | Jump if No Sign (Positive) | $\text{SF} = 0$ | Number is positive or zero |
| **`JO`** | Jump if Overflow | $\text{OF} = 1$ | Signed arithmetic overflow |
| **`JNO`** | Jump if No Overflow | $\text{OF} = 0$ | Safe signed arithmetic |
| **`JP` / `JPE`** | Jump if Parity Even | $\text{PF} = 1$ | Even number of 1-bits (data transmission) |
| **`JNP` / `JPO`** | Jump if Parity Odd | $\text{PF} = 0$ | Odd number of 1-bits |
| **`JCXZ`** | Jump if `CX` is Zero | $\text{CX} = 0$ | Guard before entering `LOOP` blocks |

---

### Master Jump Summary Table

| Mnemonic | Alternate Name | Meaning / Condition Checked | Flag Evaluation | Data Type |
| :--- | :--- | :--- | :--- | :--- |
| **`JMP`** | — | Unconditional Jump | None (Always jumps) | Any |
| **`JE`** | `JZ` | Jump if Equal / Zero ($==$) | $\text{ZF} = 1$ | Any |
| **`JNE`** | `JNZ` | Jump if Not Equal / Not Zero ($\ne$) | $\text{ZF} = 0$ | Any |
| **`JA`** | `JNBE` | Jump if Above ($>$) | $\text{CF} = 0 \land \text{ZF} = 0$ | **Unsigned / ASCII** |
| **`JAE`** | `JNB`, `JNC` | Jump if Above or Equal ($\ge$) | $\text{CF} = 0$ | **Unsigned / ASCII** |
| **`JB`** | `JNAE`, `JC` | Jump if Below ($<$) | $\text{CF} = 1$ | **Unsigned / ASCII** |
| **`JBE`** | `JNA` | Jump if Below or Equal ($\le$) | $\text{CF} = 1 \lor \text{ZF} = 1$ | **Unsigned / ASCII** |
| **`JG`** | `JNLE` | Jump if Greater ($>$) | $\text{ZF} = 0 \land \text{SF} = \text{OF}$ | **Signed Integers** |
| **`JGE`** | `JNL` | Jump if Greater or Equal ($\ge$) | $\text{SF} = \text{OF}$ | **Signed Integers** |
| **`JL`** | `JNGE` | Jump if Less ($<$) | $\text{SF} \ne \text{OF}$ | **Signed Integers** |
| **`JLE`** | `JNG` | Jump if Less or Equal ($\le$) | $\text{ZF} = 1 \lor \text{SF} \ne \text{OF}$ | **Signed Integers** |
| **`JS`** | — | Jump if Sign / Negative | $\text{SF} = 1$ | Signed |
| **`JNS`** | — | Jump if No Sign / Positive | $\text{SF} = 0$ | Signed |
| **`JO`** | — | Jump if Overflow | $\text{OF} = 1$ | Signed Overflow |
| **`JNO`** | — | Jump if No Overflow | $\text{OF} = 0$ | Signed Safe |
| **`JP`** | `JPE` | Jump if Parity Even | $\text{PF} = 1$ | Bit parity check |
| **`JNP`** | `JPO` | Jump if Parity Odd | $\text{PF} = 0$ | Bit parity check |
| **`JCXZ`** | — | Jump if `CX` is Zero | $\text{CX} = 0$ | Loop bounds check |

---

## 11. Branching (Jumps) vs. Procedure Calls (`CALL`/`RET`): Standard Practice & Trade-offs

Neither approach is universally "better"; each serves a specific architectural role in low-level and systems programming.

### 1. Standard Practice Definitions

#### A. Branching (Inline Jumps: `JMP`, `JE`, `JB`, `JBE`, etc.)
- **Definition**: Direct transfer of the CPU Instruction Pointer (`IP`) to a local label within the same procedure.
- **Hardware Mechanism**: Does **not** touch the stack. Modifies `IP` directly in a single step.
- **Standard Purpose**: Implementing **local control flow** structures:
  - `if-then-else` decisions
  - `while`, `for`, `do-while` loops
  - Switch/case jump tables
  - Skipping unneeded blocks

#### B. Procedure Calls (`CALL` / `RET` with `PROC ... ENDP`)
- **Definition**: Invocation of an isolated, modular block of code that executes and automatically returns to the instruction immediately following the call site.
- **Hardware Mechanism**: Pushes the return address (`IP` $\pm$ `CS`) onto the **Stack**, transfers control to the subroutine, and uses `RET` to pop the return address back.
- **Standard Purpose**: Implementing **reusable subroutines and modular functions**:
  - Code called from multiple locations (e.g., `print_hex` called twice in `5.1.asm`)
  - Standalone operations (e.g., string manipulation, mathematical calculations, hardware drivers)
  - Recursive algorithms

---

### 2. Comprehensive Comparison

| Metric | Branching / Inline Jumps (`JMP` / Conditional) | Procedure Calls (`CALL` / `RET`) |
| :--- | :--- | :--- |
| **Stack Usage** | **0 bytes** (No stack interaction) | **2 bytes** (Near) or **4 bytes** (Far) pushed/popped |
| **Execution Overhead** | **Fastest** (~8–15 CPU clock cycles) | **Slower** (~19–23 cycles for `CALL` + `RET`) |
| **Code Reusability** | **Poor** (Can only flow to fixed targets; cannot return to varied callers) | **Excellent** (Can be called from 100 different places and return safely) |
| **Memory Footprint** | Duplicates instructions if repeated throughout program | Saves code memory by consolidating duplicate logic |
| **Scope & Organization** | Local to the current function | Global or modular across files/segments |
| **Risk / Pitfalls** | "Spaghetti code" if overused for non-local flow | Stack overflow if unbalanced or missing `RET` |

---

### 3. Rules of Thumb: When to Use Which?

```
                     [ Is the task a single calculation/step (e.g. 1-2 lines)? ]
                                     /                                  \
                                   YES                                   NO
                                   /                                       \
         [ Called from multiple places in code? ]               [ Complex or multi-step logic ]
                  /                      \                                   |
                YES                       NO                                 v
                 |                         |                          USE `PROC` (`CALL`/`RET`)
                 v                         v                          (Modularity & Organization)
          USE `PROC`                 USE INLINE JUMPS
     (Saves duplicate bytes)       (Faster, no stack overhead)
```

1. **Use Inline Branching (`CMP` + `JB` / `JMP`) When:**
   - The operation inside the branch is tiny (e.g. `sub al, 20h` or `add al, 20h` in `A_4.asm`).
   - The operation is only executed in one place in the program.
   - Micro-performance is critical and stack overhead should be eliminated.

2. **Use Procedure Calls (`CALL` + `RET`) When:**
   - The exact same routine is executed from two or more call sites (e.g., calling `print_hex` for both upper and lower nibbles in `5.1.asm`).
   - The routine is long, complex, or self-contained (e.g. string formatting, reading multicharacter inputs).
   - You want clean separation of concerns and readable, modular code.

---

### 4. Applied to `A_4.asm`

In `A_4.asm`, converting case is just one instruction (`sub al, 20h` or `add al, 20h`):

* **Inline Branch Approach (Clean & Fast)**:
  ```assembly
      cmp al, 'a'
      jb not_lower
      cmp al, 'z'
      ja not_lower
      sub al, 20h        ; Inlined directly (no procedure overhead)
      jmp display

  not_lower:
      cmp al, 'A'
      jb display
      cmp al, 'Z'
      ja display
      add al, 20h        ; Inlined directly

  display:
  ```

* **Procedure Approach (`PROC to_CAPITAL` / `PROC to_SMALL`)**:
  - Ideal if `to_CAPITAL` will be called in several places across a larger program or exported for use by other modules.



