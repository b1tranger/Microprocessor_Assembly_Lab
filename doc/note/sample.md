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
    - [10.1 High-Level Concept (C Equivalent)](#101-high-level-concept-c-equivalent)
    - [10.2 Base-Index Addressing & Static Array Initialization](#102-base-index-addressing--static-array-initialization)
    - [10.3 Uninitialized ("Empty") Arrays (`DUP(?)`)](#103-uninitialized-empty-arrays-dup)
    - [10.4 Taking User Input into an Array via Loop](#104-taking-user-input-into-an-array-via-loop)
    - [10.5 Complete Working Program: Array Input and Output](#105-complete-working-program-array-input-and-output)
    - [10.6 Hardware Addressing Modes](#106-hardware-addressing-modes)
11. [Pointers & Memory Addresses (`*ptr` and `&var`)](#11-pointers--memory-addresses-ptr-and-var)
12. [Complete 8086 Jump Instructions Reference](#12-complete-8086-jump-instructions-reference)
    - [Group 1: Unconditional Jump (`JMP`)](#group-1-unconditional-jump)
    - [Group 2: Unsigned Comparison Jumps (`JA`, `JB`, `JE`, etc.)](#group-2-unsigned-comparison-jumps)
    - [Group 3: Signed Comparison Jumps (`JG`, `JL`, `JGE`, etc.)](#group-3-signed-comparison-jumps)
    - [Group 4: Simple Flag & Register-Based Jumps (`JCXZ`, `JS`, `JO`, etc.)](#group-4-simple-flag--register-based-jumps)
    - [Master Jump Summary Table](#master-jump-summary-table)
    - [High-Level Expression to Flags Mapping Table](#high-level-expression-to-flags-mapping-table)
13. [Double Digit Display Mechanics: Base-10 Arithmetic vs. Base-16 Bitwise Extraction](#13-double-digit-display-mechanics-base-10-arithmetic-vs-base-16-bitwise-extraction)
    - [13.1 BASE-16 (Hex) vs. BASE-10 (Decimal) Architectural Foundation](#131-base-16-hex-vs-base-10-decimal-architectural-foundation)
    - [13.2 Detailed Side-by-Side Comparison: `5.1.asm` vs. `3.2.asm`](#132-detailed-side-by-side-comparison-51asm-vs-32asm)
    - [13.3 Register Lifecycle & Phase Analysis: Does `AL` Store Binary?](#133-register-lifecycle--phase-analysis-does-al-store-binary)
    - [13.4 ASCII Conversion Mechanics: Direct (`+48`) vs. Branching (`+48 / +7`)](#134-ascii-conversion-mechanics-direct-48-vs-branching-48--7)

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

### 10.1 High-Level Concept (C Equivalent)
```c
#include <stdio.h>

// 1. Static Initialized Array & Direct Index Access
char arr[5] = {'A', 'B', 'C', 'D', 'E'};
char val = arr[2];                     // Access element at index 2 ('C')

// 2. Uninitialized Array & Loop Input / Output
char input_arr[5];                     // Empty array of 5 bytes

// Input Loop: Read 5 characters into array
for (int i = 0; i < 5; i++) {
    input_arr[i] = getchar();
}

// Output Loop: Display 5 characters from array
for (int i = 0; i < 5; i++) {
    putchar(input_arr[i]);
}
```

---

### 10.2 Base-Index Addressing & Static Array Initialization
```assembly
.DATA
    arr DB 'A', 'B', 'C', 'D', 'E'
    val DB ?

.CODE
    MOV BX, OFFSET arr   ; BX holds base pointer of array
    MOV SI, 2            ; SI holds index i = 2
    MOV AL, [BX + SI]    ; Effective Address EA = DS:(BX + SI) -> 'C'
    MOV val, AL
```

---

### 10.3 Uninitialized ("Empty") Arrays (`DUP(?)`)

In 8086 assembly, memory for an uninitialized array is allocated in the data segment using the `DUP(?)` directive:

```assembly
.DATA
    ; 1. Initialized Array (Pre-filled values)
    arr_init    DB 'A', 'B', 'C', 'D', 'E'  ; 5 bytes: 41h, 42h, 43h, 44h, 45h
    
    ; 2. Uninitialized / "Empty" Array (Allocates space without fixed values)
    arr_empty   DB 5 DUP(?)                 ; Allocates 5 uninitialized bytes (like char arr[5];)
    
    ; 3. Zero-Initialized Array (Allocates and fills with 0)
    arr_zeros   DB 5 DUP(0)                 ; 5 bytes: 00h, 00h, 00h, 00h, 00h
    
    ; 4. Uninitialized 16-bit Word Array
    arr_words   DW 10 DUP(?)                ; Allocates 10 words (20 bytes total)
```

The `DUP(?)` directive tells the assembler to reserve that number of bytes/words in the segment without assigning pre-determined values (equivalent to `char arr[5];` in C).

---

### 10.4 Taking User Input into an Array via Loop

To fill an empty array from user keyboard input:
1. **Initialize a counter register**: `MOV CX, size` (number of elements to read).
2. **Initialize an index register**: `MOV SI, 0` (or `MOV BX, OFFSET arr`).
3. **Read each character inside the loop**: Call DOS `INT 21H / AH=01H`. The entered character is returned in `AL`.
4. **Store into array memory**: Use indexed addressing `MOV arr[SI], AL` (or `MOV [BX + SI], AL`).
5. **Increment index & repeat**: `INC SI` (or `ADD SI, 2` for words), then `LOOP`.

```assembly
    MOV SI, 0              ; Index i = 0
    MOV CX, 5              ; Loop 5 times

input_loop:
    MOV AH, 01H            ; DOS Service: Read char with echo -> AL
    INT 21H
    MOV arr_empty[SI], AL  ; Store character into arr_empty[i]
    INC SI                 ; i++
    LOOP input_loop        ; Decrement CX, jump if CX != 0
```

---

### 10.5 Complete Working Program: Array Input and Output

This complete program reads 5 characters from the user into an uninitialized array, outputs a newline, and prints the array back out:

```assembly
.MODEL SMALL
.STACK 100H

.DATA
    PROMPT_IN   DB 'Enter 5 characters: $'
    PROMPT_OUT  DB 13, 10, 'Array contents: $'
    ARR         DB 5 DUP(?)        ; Empty array of 5 bytes

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Display Input Prompt
    MOV AH, 09H
    LEA DX, PROMPT_IN
    INT 21H

    ; 2. Read 5 Characters into ARR using Loop
    MOV SI, 0                      ; Index pointer i = 0
    MOV CX, 5                      ; Count = 5

read_loop:
    MOV AH, 01H                    ; DOS character input -> returns in AL
    INT 21H
    MOV ARR[SI], AL                ; Store AL into memory address ARR + SI
    INC SI                         ; SI = SI + 1 (step by 1 byte)
    LOOP read_loop                 ; CX--, if CX != 0 goto read_loop

    ; 3. Display Output Prompt
    MOV AH, 09H
    LEA DX, PROMPT_OUT
    INT 21H

    ; 4. Print Array Elements using Loop
    MOV SI, 0                      ; Reset index pointer to start
    MOV CX, 5                      ; Reset count to 5

print_loop:
    MOV DL, ARR[SI]                ; Load byte from array into DL
    MOV AH, 02H                    ; DOS character output service
    INT 21H
    INC SI                         ; Advance index
    LOOP print_loop                ; Repeat for all elements

    ; 5. Exit Program
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN
```

---

### 10.6 Hardware Addressing Modes
The 8086 hardware supports compound memory addressing registers:
$$\text{Physical Address} = (\text{DS} \times 16) + \text{Base} (\text{BX/BP}) + \text{Index} (\text{SI/DI}) + \text{Displacement}$$

When accessing array bytes, the effective address `EA = ARR + SI` is computed directly by the Bus Interface Unit (BIU). For 16-bit word arrays (`DW`), each element occupies 2 bytes, so `ADD SI, 2` must be used instead of `INC SI`.

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

## 12. Complete 8086 Jump Instructions Reference

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

### High-Level Expression to Flags Mapping Table

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

---

## 13. Double Digit Display Mechanics: Base-10 Arithmetic vs. Base-16 Bitwise Extraction

In high-level languages like C/C++, printing numbers in decimal or hex is abstracted behind format specifiers (`printf("%d", n)` or `printf("%X", n)`). In 8086 assembly, the console service (`INT 21h / AH=02h`) **only outputs one ASCII character byte at a time**. 

When displaying numbers that span two digits, the programmer must explicitly isolate the individual digits and translate each into its corresponding ASCII encoding. Two completely different paradigms exist depending on the numeric base:
1. **Base-16 (Hexadecimal)** via Bitwise Shifts & Masks ([`5.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-5_Bitwise_Hex_Display/5.1.asm)).
2. **Base-10 (Decimal)** via Arithmetic Division ([`3.2.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-3_Arithmetic_Operations/3.2.asm)).

---

### 13.1 BASE-16 (Hex) vs. BASE-10 (Decimal) Architectural Foundation

The hardware reason why bitwise shifts work for Hexadecimal but fail for Decimal stems from whether the number base aligns with powers of 2 ($2^n$):

```
+-------------------------------------------------------------------------------+
|                      BASE-16 (Hex) vs. BASE-10 (Decimal)                      |
+-------------------------------------------------------------------------------+
| Hexadecimal (Base-16):                                                        |
|   - 16 = 2^4 (power of 2).                                                    |
|   - Exactly 4 bits (1 nibble) = 1 hex digit.                                  |
|   - 1 Byte (8 bits) = Exactly TWO 4-bit nibbles: [Upper 4 bits] [Lower 4 bits]|
|   - Digits align with hardware bit boundaries, so SHR and AND work directly!  |
|                                                                               |
| Decimal (Base-10):                                                            |
|   - 10 is NOT a power of 2 (2^3 = 8 < 10 < 2^4 = 16).                         |
|   - Decimal digits do NOT align with bit boundaries.                          |
|   - You cannot shift or mask 0001 1100b (28) to separate 2 and 8.             |
|   - You MUST use mathematical division: DIV 10.                               |
+-------------------------------------------------------------------------------+
```

#### Why Can't We Use `SHR` / `AND` for Decimal?
- An 8-bit byte holding `28` decimal contains the bit pattern `0001 1100b`.
- If you perform `SHR AL, 4`, you get `0000 0001b` ($1$), not the tens digit $2$!
- If you perform `AND AL, 0Fh`, you get `0000 1100b` ($12$), not the units digit $8$!
- Because base-10 digits do not partition on 4-bit boundaries, bit manipulation cannot decompose decimal numbers. Arithmetic division by 10 is mathematically mandatory.

---

### 13.2 Detailed Side-by-Side Comparison: `5.1.asm` vs. `3.2.asm`

```
                  5.1.asm (Hexadecimal)                 3.2.asm (Decimal)
               +--------------------------+         +--------------------------+
Digit          | Bitwise Manipulation:    |         | Arithmetic Division:     |
Separation     | - Upper: SHR AL, 4       |         | - DIV BL (where BL = 10) |
Mechanism      | - Lower: AND AL, 0Fh     |         | - AL = Tens, AH = Units  |
               +--------------------------+         +--------------------------+
                            |                                    |
CPU Clock      | 1 to 2 Clock Cycles      |         | 80 to 90 Clock Cycles    |
Efficiency     | (Extremely fast)         |         | (Microcoded division)    |
               +--------------------------+         +--------------------------+
                            |                                    |
ASCII          | + 48 for digits 0-9      |         | + 48 for both digits     |
Conversion     | + 48 + 7 (+55) for A-F   |         | (Digits never exceed 9)  |
               | (Requires conditional)   |         | (No branching needed)    |
               +--------------------------+         +--------------------------+
                            |                                    |
Modularity     | Reusable Subroutine      |         | Sequential Inline Code   |
               | (CALL print_hex)         |         | (Store in variables)     |
               +--------------------------+         +--------------------------+
```

#### Detailed Comparison Table

| Feature | Base-10 Decimal ([`3.2.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-3_Arithmetic_Operations/3.2.asm)) | Base-16 Hexadecimal ([`5.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-5_Bitwise_Hex_Display/5.1.asm)) |
| :--- | :--- | :--- |
| **Target Representation** | Decimal characters (`'0'`–`'9'`) | Hex characters (`'0'`–`'9'`, `'A'`–`'F'`) |
| **Digit Separation Method** | `DIV BL` (with `BL = 10`):<br>$\text{Quotient} = N / 10$, $\text{Remainder} = N \pmod{10}$ | `SHR AL, 4` (upper nibble)<br>`AND AL, 0Fh` (lower nibble) |
| **Operand Requirements** | Must set up dividend in `AX` (`AH = 0`, `AL = value`) | Single register `AL` can be manipulated directly |
| **CPU Execution Overhead** | **High** (~80–90 clock cycles per division) | **Minimal** (1–2 clock cycles per shift/mask) |
| **Output Storage** | `AL` receives Tens, `AH` receives Units | `AL` receives each 4-bit nibble sequentially |
| **ASCII Transformation** | Unconditional `ADD reg, 48` | `ADD AL, 48`; if $> 57$, `ADD AL, 7` |
| **High-Level Analogy** | `tens = n / 10; units = n % 10;` | `hi = (n >> 4) & 0xF; lo = n & 0xF;` |

---

### 13.3 Register Lifecycle & Phase Analysis: Does `AL` Store Binary?

At the physical silicon level, **`AL` always and exclusively stores binary voltages (`0`s and `1`s)** in both routines. The semantic distinction lies in what those binary bits represent across execution stages:

```
[Phase 1: Raw Numeric Magnitude]
   AL holds binary integer quantity:
   - 3.2.asm: 0001 1100b (Value: 28 decimal)
   - 5.1.asm: 1101 0001b (Value: 0D1h / 209 decimal)
             |
             v
[Phase 2: Separated Digits]
   AL holds individual digit quantities:
   - 3.2.asm: AL = 0000 0010b (2 tens), AH = 0000 1000b (8 units)
   - 5.1.asm: AL = 0000 1101b (Upper: 13d / 'D'), AL = 0000 0001b (Lower: 1d / '1')
             |
             v
[Phase 3: ASCII Glyph Code Encoding]
   AL holds standard 7/8-bit ASCII character codes for INT 21h display:
   - 3.2.asm: AL = 0011 0010b ('2' / 50d / 32h), AH = 0011 1000b ('8' / 56d / 38h)
   - 5.1.asm: AL = 0100 0100b ('D' / 68d / 44h), AL = 0011 0001b ('1' / 49d / 31h)
```

---

### 13.4 ASCII Conversion Mechanics: Direct (`+48`) vs. Branching (`+48 / +7`)

When converting isolated numeric digits to ASCII display codes:

1. **Decimal Digits ($0 \le d \le 9$)**:
   - The ASCII range for digits `'0'`–`'9'` spans `30h`–`39h` (`48`–`57` in decimal).
   - Adding `48` (`'0'`) directly produces the exact printable character.
   - Because a decimal digit never exceeds 9, **no branching or condition checking is needed**.

2. **Hexadecimal Digits ($0 \le d \le 15$)**:
   - Digits $0 \dots 9$ map to `'0'`–`'9'` (`30h`–`39h` / 48–57).
   - Digits $10 \dots 15$ map to `'A'`–`'F'` (`41h`–`46h` / 65–70).
   - Between ASCII `'9'` (57) and `'A'` (65), there is a gap of **7 non-alphanumeric punctuation characters** (`:`, `;`, `<`, `=`, `>`, `?`, `@`).
   - If a nibble is $\ge 10$, adding `48` lands in the punctuation gap ($10 + 48 = 58 = \text{':'}$). Adding an extra `7` bridges this gap ($58 + 7 = 65 = \text{'A'}$):
     ```assembly
     add al, 48
     cmp al, 57         ; '9'
     jbe print_char
     add al, 7          ; Skip 7 ASCII punctuation symbols to reach 'A'-'F'
     print_char:
     ```

