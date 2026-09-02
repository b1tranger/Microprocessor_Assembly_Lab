# High-Level Programming Concepts in 8086 Assembly: Register & Flag Mechanics

This document provides a comprehensive mapping of modern high-level programming language (HLL) constructs—such as conditionals, loops, functions, arrays, and pointer manipulation—to their equivalent 8086 assembly implementations. It explains precisely how each construct executes at the CPU hardware level, specifically focusing on the **FLAGS register**, the **Instruction Pointer (`IP`)**, and the **Stack Pointer (`SP`)**.

---

## Table of Contents

1. [The Foundation: CPU Execution & The Decoupled FLAGS Model](#1-the-foundation-cpu-execution--the-decoupled-flags-model)
2. [Variables & Assignment (`x = 10;`)](#2-variables--assignment-x--10)
3. [Simple IF Statement (`if (condition)`)](#3-simple-if-statement-if-condition)
4. [IF-ELSE Statement (`if-else`)](#4-if-else-statement-if-else)
5. [ELSE-IF Ladder / Chained Conditionals](#5-else-if-ladder--chained-conditionals)
6. [Compound Conditions: Logical AND (`&&`) & Logical OR (`||`)](#6-compound-conditions-logical-and---logical-or-)
7. [Switch / Case Statements (Jump Tables)](#7-switch--case-statements-jump-tables)
8. [Loops: While, Do-While, and For](#8-loops-while-do-while-and-for)
   - [8.1 While Loop (Pre-tested Loop)](#81-while-loop-pre-tested-loop)
   - [8.2 Do-While Loop (Post-tested Loop)](#82-do-while-loop-post-tested-loop)
   - [8.3 For Loop (Counter-Controlled with `CX` & `LOOP`)](#83-for-loop-counter-controlled-with-cx--loop)
   - [8.4 Loop Control: `break` and `continue`](#84-loop-control-break-and-continue)
9. [Functions & Procedures (`CALL` / `RET`)](#9-functions--procedures-call--ret)
10. [Arrays & Indexing (`arr[i]`)](#10-arrays--indexing-arri)
11. [Pointers & Memory Addresses (`*ptr` and `&var`)](#11-pointers--memory-addresses-ptr-and-var)
12. [Complete 8086 Jump Instructions Reference](#12-complete-8086-jump-instructions-reference)
    - [Group 1: Unconditional Jump (`JMP`)](#group-1-unconditional-jump)
    - [Group 2: Unsigned Comparison Jumps (`JA`, `JB`, `JE`, etc.)](#group-2-unsigned-comparison-jumps)
    - [Group 3: Signed Comparison Jumps (`JG`, `JL`, `JGE`, etc.)](#group-3-signed-comparison-jumps)
    - [Group 4: Simple Flag & Register-Based Jumps (`JCXZ`, `JS`, `JO`, etc.)](#group-4-simple-flag--register-based-jumps)
    - [Master Jump Summary Table](#master-jump-summary-table)
    - [High-Level Expression to Flags Mapping Table](#high-level-expression-to-flags-mapping-table)


---

## 1. The Foundation: CPU Execution & The Decoupled FLAGS Model

In high-level languages like C/C++, Java, or Python, a condition and a branch are written as a single composite statement:
```c
if (a > b) { ... }
```

In 8086 CPU architecture, **this single operation is strictly split into two independent machine cycles**:

```
+-------------------------------------------------------------------------+
| STEP 1: ALU Evaluation (Arithmetic / Logic)                             |
| Instruction: CMP, TEST, SUB, AND, etc.                                  |
| -> Computes intermediate result.                                        |
| -> Discards the result (does NOT alter destination for CMP/TEST).       |
| -> Updates Hardware Status Bits in the FLAGS Register.                  |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
| 8086 FLAGS Register Status Bits:                                        |
| [ ... | OF | DF | IF | TF | SF | ZF | AF | PF | CF ]                   |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
| STEP 2: Control Transfer Decision (Branching)                           |
| Instruction: JZ, JNE, JA, JB, JG, JL, etc.                              |
| -> Reads ONLY the flag bits (does not know or care about a or b).       |
| -> If flag condition is MET: IP = Target Address.                       |
| -> If flag condition FAILS: IP advances to next sequential instruction. |
+-------------------------------------------------------------------------+
```

### The 6 Key Status Flags in 8086
- **Zero Flag (`ZF`)**: Set to `1` if result is $0$ (i.e. operands were equal).
- **Carry Flag (`CF`)**: Set to `1` if an unsigned borrow/carry occurred ($A < B$ in unsigned arithmetic).
- **Sign Flag (`SF`)**: Set to `1` if highest bit of result is `1` (negative result).
- **Overflow Flag (`OF`)**: Set to `1` if signed arithmetic overflow occurred (e.g. adding two positive numbers yielded a negative).
- **Parity Flag (`PF`)**: Set to `1` if the lowest byte of the result contains an even number of set bits (`1`s).
- **Auxiliary Carry Flag (`AF`)**: Set on BCD (half-carry from bit 3 to bit 4).

---

## 2. Variables & Assignment (`x = 10;`)

### High-Level Concept
```c
int count = 10;
count = count + 5;
```

### 8086 Assembly Implementation
```assembly
.data
    count dw 10          ; Allocate 16-bit word initialized to 10

.code
    mov ax, count        ; Load value from memory [DS:offset count] into register AX
    add ax, 5            ; ALU computes AX + 5, updates FLAGS
    mov count, ax        ; Store result back to memory
```

### Register-Level Mechanics
- 8086 CPU **cannot perform memory-to-memory operations directly** (`add [count], 5` is valid with immediate, but `mov [dest], [src]` is illegal).
- Registers (`AX`, `BX`, `CX`, `DX`) act as high-speed scratchpads.

---

## 3. Simple IF Statement (`if (condition)`)

### High-Level Concept
```c
if (a == b) {
    do_something();
}
// Next code...
```

### 8086 Assembly Pattern (Inverted Branching)
In assembly, you compare operands and **jump OVER the body if the condition is FALSE**:

```assembly
    mov ax, a
    cmp ax, b            ; Calculates (ax - b), sets ZF
    jne skip_if          ; Hardware Check: If ZF == 0 (a != b), jump past body!

    ; --- [IF BODY] ---
    ; Executed ONLY when a == b (ZF == 1)
    call do_something

skip_if:
    ; Next instructions...
```

### Flag Mechanics
1. `CMP AX, B`: If $a = b$, $(a - b) = 0 \rightarrow \mathbf{ZF = 1}$.
2. `JNE skip_if`: Checks $\mathbf{ZF == 0}$. Because $ZF=1$, the branch is **not taken**.
3. The CPU executes the body and falls into `skip_if`.

---

## 4. IF-ELSE Statement (`if-else`)

### High-Level Concept
```c
if (score >= 50) {
    result = 'P'; // Pass
} else {
    result = 'F'; // Fail
}
```

### 8086 Assembly Implementation
```assembly
    mov al, score
    cmp al, 50           ; Calculates (score - 50)
    jb  else_block       ; Unsigned Check: if score < 50 (CF=1), jump to ELSE

    ; --- [IF BLOCK: score >= 50] ---
    mov result, 'P'
    jmp end_if           ; CRITICAL: Jump past ELSE block to prevent fall-through!

else_block:
    ; --- [ELSE BLOCK: score < 50] ---
    mov result, 'F'

end_if:
    ; Next instructions...
```

### Hardware Execution Trace
```
                    [ CMP AL, 50 ]
                          |
              +-----------+-----------+
              |                       |
          (AL >= 50)              (AL < 50)
          [CF = 0]                [CF = 1]
              |                       |
              v                       v
      mov result, 'P'           (JB triggers)
              |                       |
         [JMP end_if]                 |
              |                       |
              +--------> [ end_if ] <-+
```

---

## 5. ELSE-IF Ladder / Chained Conditionals

### High-Level Concept
```c
if (grade >= 80) {
    gpa = 'A';
} else if (grade >= 60) {
    gpa = 'B';
} else {
    gpa = 'F';
}
```

### 8086 Assembly Implementation
```assembly
    mov al, grade

    ; --- Check Condition 1 ---
    cmp al, 80
    jb check_b           ; If grade < 80, go to next check
    mov gpa, 'A'
    jmp end_ladder       ; Done -> exit entire ladder

check_b:
    ; --- Check Condition 2 ---
    cmp al, 60
    jb check_fail        ; If grade < 60, go to fallback
    mov gpa, 'B'
    jmp end_ladder

check_fail:
    ; --- Fallback (ELSE) ---
    mov gpa, 'F'

end_ladder:
```

---

## 6. Compound Conditions: Logical AND (`&&`) & Logical OR (`||`)

### 6.1 Short-Circuit Logical AND (`if (a > 10 && b < 20)`)

```c
if (a > 10 && b < 20) {
    action();
}
```

In short-circuit AND, **if the first condition fails, immediately abort and skip the body**:

```assembly
    ; Condition 1: a > 10
    cmp a, 10
    jbe skip_and         ; If a <= 10 (CF=1 or ZF=1), fail immediately

    ; Condition 2: b < 20
    cmp b, 20
    jae skip_and         ; If b >= 20 (CF=0), fail immediately

    ; --- Both Conditions Met ---
    call action

skip_and:
```

---

### 6.2 Short-Circuit Logical OR (`if (a == 0 || b == 0)`)

```c
if (a == 0 || b == 0) {
    action();
}
```

In short-circuit OR, **if any condition is true, jump directly into the body**:

```assembly
    ; Condition 1: a == 0
    cmp a, 0
    je do_action         ; If true (ZF=1), take action immediately!

    ; Condition 2: b == 0
    cmp b, 0
    jne skip_or          ; If false (ZF=0), skip action

do_action:
    call action

skip_or:
```

---

## 7. Switch / Case Statements (Jump Tables)

### High-Level Concept
```c
switch(val) {
    case 0: func0(); break;
    case 1: func1(); break;
    case 2: func2(); break;
    default: default_func();
}
```

### 8086 Assembly: Indirect Jump Table via Pointers
A jump table provides $O(1)$ constant-time branching by indexing an array of code offsets:

```assembly
.data
    ; Array of procedure/label offsets (16-bit words)
    jump_table dw offset case_0, offset case_1, offset case_2

.code
    mov bx, val          ; Load selector value
    cmp bx, 2
    ja  default_case     ; Boundary check: if val > 2, goto default

    shl bx, 1            ; Multiply by 2 (each word offset is 2 bytes)
    jmp jump_table[bx]   ; Indirect Near Jump to address stored at [jump_table + BX]

case_0:
    call func0
    jmp end_switch

case_1:
    call func1
    jmp end_switch

case_2:
    call func2
    jmp end_switch

default_case:
    call default_func

end_switch:
```

---

## 8. Loops: While, Do-While, and For

### 8.1 While Loop (Pre-tested Loop)
Checks condition **before** entering the loop body.

```c
while (count > 0) {
    process();
    count--;
}
```

```assembly
while_start:
    cmp count, 0
    jle while_end        ; Pre-test: if count <= 0, terminate immediately

    call process
    dec count
    jmp while_start      ; Repeat

while_end:
```

---

### 8.2 Do-While Loop (Post-tested Loop)
Executes body **at least once**, checking condition at the end.

```c
do {
    process();
    count--;
} while (count > 0);
```

```assembly
do_while_start:
    call process
    dec count

    cmp count, 0
    jg do_while_start    ; Post-test: if count > 0, loop back

; Loop terminates
```

---

### 8.3 For Loop (Counter-Controlled with `CX` & `LOOP`)

```c
for (int i = 5; i > 0; i--) {
    print_star();
}
```

The 8086 CPU has dedicated hardware support for counter loops using the **`CX` (Count Register)** and the **`LOOP` instruction**:

```assembly
    mov cx, 5            ; Set loop iterations

for_loop:
    call print_star
    loop for_loop        ; Hardware: Decrements CX, jumps if CX != 0
```

#### How `LOOP` Operates at Register Level:
1. Performs `CX = CX - 1`.
2. Evaluates `CX != 0`.
3. If `CX != 0`, sets `IP = offset for_loop`.
4. **Crucial Hardware Detail**: `LOOP` **does NOT alter any flags in the FLAGS register**, preserving arithmetic flag states!

---

### 8.4 Loop Control: `break` and `continue`

```c
while (i < 100) {
    if (i == 50) break;
    if (i % 2 == 0) continue;
    process(i);
    i++;
}
```

```assembly
loop_top:
    cmp i, 100
    jae loop_exit        ; Loop termination

    ; --- BREAK EQUIVALENT ---
    cmp i, 50
    je loop_exit         ; `break` jumps straight out of the loop

    ; --- CONTINUE EQUIVALENT ---
    test i, 1            ; Check if even
    jz loop_next         ; `continue` jumps to the step/increment section

    call process

loop_next:
    inc i
    jmp loop_top

loop_exit:
```

---

## 9. Functions & Procedures (`CALL` / `RET`)

### High-Level Concept
```c
int square(int x) {
    return x * x;
}

int main() {
    int res = square(5);
}
```

### 8086 Assembly Implementation
```assembly
; Calling site:
    mov ax, 5            ; Pass parameter in AX
    call square          ; 1. PUSH next IP to stack, 2. Jump to square
    mov res, ax          ; Store return value received in AX

; Subroutine definition:
square proc
    mul ax               ; AX = AX * AX (DX:AX)
    ret                  ; POP return address from stack into IP
square endp
```

### Register & Stack Mechanics (`CALL` / `RET`):
```
[ BEFORE CALL ]              [ AFTER CALL square ]           [ AFTER RET ]
Stack (SS:SP):               Stack (SS:SP):                  Stack (SS:SP):
+---------------+            +---------------+               +---------------+
| Earlier Data  |            | Earlier Data  |               | Earlier Data  |
+---------------+            +---------------+               +---------------+
                             | Return Addr IP| <-- SP (TOS)  
                             +---------------+
                             
SP decrements by 2           Pushes Return IP                SP increments by 2
                             IP = offset square              IP = popped Return IP
```

---

## 10. Arrays & Indexing (`arr[i]`)

### High-Level Concept
```c
char arr[5] = {'A', 'B', 'C', 'D', 'E'};
char val = arr[2];
```

### 8086 Assembly Base-Index Addressing
```assembly
.data
    arr db 'A', 'B', 'C', 'D', 'E'
    val db ?

.code
    mov bx, offset arr   ; BX holds base pointer of array
    mov si, 2            ; SI holds index i = 2
    mov al, [bx + si]    ; Effective Address EA = DS: (BX + SI) -> 'C'
    mov val, al
```

### Hardware Addressing Modes
The 8086 hardware supports compound memory addressing registers:
$$\text{Physical Address} = (\text{DS} \times 16) + \text{Base} (\text{BX/BP}) + \text{Index} (\text{SI/DI}) + \text{Displacement}$$

---

## 11. Pointers & Memory Addresses (`*ptr` and `&var`)

### High-Level Concept
```c
int num = 42;
int *ptr = &num;    // Address-of
int val = *ptr;     // Dereference
*ptr = 99;          // Indirect store
```

### 8086 Assembly Implementation
```assembly
.data
    num dw 42
    ptr dw ?
    val dw ?

.code
    ; 1. Address-of (&num)
    lea bx, num          ; Load Effective Address (or: mov bx, offset num)
    mov ptr, bx          ; Store memory address in pointer variable

    ; 2. Dereference (*ptr)
    mov bx, ptr          ; Load pointer address into BX register
    mov ax, [bx]         ; Read 16-bit word at memory address [DS:BX]
    mov val, ax          ; val is now 42

    ; 3. Indirect Store (*ptr = 99)
    mov word ptr [bx], 99 ; Write 99 directly into memory address held in BX
```

---

## 12. Master Flags & Conditional Jumps Reference Table

| High-Level Expression | Type | Assembly Instruction | Jump Mnemonic | Hardware Flag Condition |
| :--- | :--- | :--- | :--- | :--- |
| **`a == b`** | Any | `cmp a, b` | **`JE` / `JZ`** | $\text{ZF} = 1$ |
| **`a != b`** | Any | `cmp a, b` | **`JNE` / `JNZ`** | $\text{ZF} = 0$ |
| **`a > b`** | Unsigned | `cmp a, b` | **`JA` / `JNBE`** | $\text{CF} = 0 \land \text{ZF} = 0$ |
| **`a >= b`** | Unsigned | `cmp a, b` | **`JAE` / `JNB`** | $\text{CF} = 0$ |
| **`a < b`** | Unsigned | `cmp a, b` | **`JB` / `JNAE`** | $\text{CF} = 1$ |
| **`a <= b`** | Unsigned | `cmp a, b` | **`JBE` / `JNA`** | $\text{CF} = 1 \lor \text{ZF} = 1$ |
| **`a > b`** | Signed | `cmp a, b` | **`JG` / `JNLE`** | $\text{ZF} = 0 \land \text{SF} = \text{OF}$ |
| **`a >= b`** | Signed | `cmp a, b` | **`JGE` / `JNL`** | $\text{SF} = \text{OF}$ |
| **`a < b`** | Signed | `cmp a, b` | **`JL` / `JNGE`** | $\text{SF} \ne \text{OF}$ |
| **`a <= b`** | Signed | `cmp a, b` | **`JLE` / `JNG`** | $\text{ZF} = 1 \lor \text{SF} \ne \text{OF}$ |
| **Bit Check (e.g. `(x & mask) == 0`)** | Bitwise | `test x, mask` | **`JZ`** | $\text{ZF} = 1$ |
| **Counter Loop (`for i=N..1`)** | Counter | *None* | **`LOOP`** | Decrements `CX`, jumps if $\text{CX} \ne 0$ |
| **Zero Guard (`if (cx == 0)`)** | Register | *None* | **`JCXZ`** | Jumps if $\text{CX} == 0$ |
