# Lab Test 2 Comprehensive Preparation Guide: Patterns, Extremums & Arithmetic Synthesis

This document provides a complete preparation guide, architectural breakdown, and solution walkthrough for **UITS Microprocessors & Microcontrollers Lab Test 2** (`CSE0611324`). It synthesizes the official questions from [`MM Labtest-2 CSE-55-6A.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/MM%20Labtest-2%20CSE-55-6A.pdf), bridges the new concepts introduced in **Labs 9 through 12**, and expands upon the core foundations documented in [`LabCodes/lab-8_Labtest-1/prep/summary.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-8_Labtest-1/prep/summary.md).

---

## Table of Contents
1. [Official Lab Test 2 Syllabus & Scope](#1-official-lab-test-2-syllabus--scope)
2. [What Was Covered After Lab Test 1 (Labs 9–12 Evolution)](#2-what-was-covered-after-lab-test-1-labs-912-evolution)
   - [Reference to Lab Test 1 Foundations](#reference-to-lab-test-1-foundations)
   - [Lab 9: Number Comparison & Extremums](#lab-9-number-comparison--extremums)
   - [Lab 10: Quiz Review & Architectural Traps](#lab-10-quiz-review--architectural-traps)
   - [Lab 11: Nested Loops & Pattern Printing](#lab-11-nested-loops--pattern-printing)
   - [Lab 12: Lab Test 2 Integration & Synthesis](#lab-12-lab-test-2-integration--synthesis)
3. [Deep-Dive on the Three Syllabus Pillars](#3-deep-dive-on-the-three-syllabus-pillars)
   - [Pillar 1: Creating Patterns in 8086 Assembly](#pillar-1-creating-patterns-in-8086-assembly)
   - [Pillar 2: Finding Largest and Smallest Numbers](#pillar-2-finding-largest-and-smallest-numbers)
   - [Pillar 3: Arithmetic Division & Operand Hygiene](#pillar-3-arithmetic-division--operand-hygiene)
4. [Official Lab Test 2 Questions & Complete Solutions](#4-official-lab-test-2-questions--complete-solutions)
   - [Set A Solution & Walkthrough (`labtest2_setA.asm`)](#set-a-solution--walkthrough-labtest2_setaasm)
   - [Set B Solution & Walkthrough (`labtest2_setB.asm`)](#set-b-solution--walkthrough-labtest2_setbasm)
   - [Comparative Analysis: Set A vs. Set B](#comparative-analysis-set-a-vs-set-b)
5. [Expanded Practice Variants & Immediate Coded Solutions](#5-expanded-practice-variants--immediate-coded-solutions)
   - [Variant 1: Inverted Triangle Pattern + Multiplication & Extremum (`sample1_inverted_triangle_extremum.asm`)](#variant-1-inverted-triangle-pattern--multiplication--extremum-sample1_inverted_triangle_extremumasm)
   - [Variant 2: Number Triangle Pattern + 3-Number Largest (`sample2_number_pattern_largest3.asm`)](#variant-2-number-triangle-pattern--3-number-largest-sample2_number_pattern_largest3asm)
   - [Variant 3: Square Grid Pattern + Absolute Difference & Minimum (`sample3_square_pattern_arithmetic.asm`)](#variant-3-square-grid-pattern--absolute-difference--minimum-sample3_square_pattern_arithmeticasm)
6. [Master Exam-Day Trap Sheet & Checklist](#6-master-exam-day-trap-sheet--checklist)

---

## 1. Official Lab Test 2 Syllabus & Scope

The official exam syllabus specifies three primary domains:
```
+-----------------------------------------------------------------------------+
|                        MCPC LAB TEST 2 SYLLABUS                             |
|                                                                             |
| 1. Creating Pattern Using Assembly Language:                                |
|    - Right-angled triangle patterns (increasing row-by-row)                 |
|    - Inverted right-angled triangle patterns (decreasing row-by-row)        |
|    - Solid square / rectangle grids (N x M)                                 |
|    - Number-based patterns (1 / 1 2 / 1 2 3...)                             |
|    - Dynamic nested loop execution via PUSH CX / POP CX                     |
|                                                                             |
| 2. Finding the Largest and Smallest Number Among Given Numbers:             |
|    - Two-variable extremum comparison (C vs D)                              |
|    - Multi-variable tournament comparison (A vs B vs C)                     |
|    - Unsigned (JA, JB, JAE, JBE) vs Signed (JG, JL, JGE, JLE) jump mechanics|
|                                                                             |
| 3. Arithmetic Operations:                                                   |
|    - Division (DIV operand8): AX / operand8 -> AL (Quotient), AH (Remainder)|
|    - Division register hygiene: XOR AH, AH before 8-bit division            |
|    - Multiplication (MUL operand8): AL * operand8 -> AX                    |
|    - Subtraction & Absolute Difference (|A - B|)                            |
|    - ASCII <-> Integer character conversions (+/- '0' / 48 / 30h)           |
+-----------------------------------------------------------------------------+
```

---

## 2. What Was Covered After Lab Test 1 (Labs 9–12 Evolution)

### Reference to Lab Test 1 Foundations
All foundational concepts covered up to Lab Test 1—including string display with DOS Service `09h`, single-character I/O (`AH=01h`, `AH=02h`), basic addition/subtraction, bitwise logic (`AND`, `OR`, `XOR`), hardware shift/rotate count rules (`CL` constraint), nibble-based hexadecimal conversion, and ASCII case toggling—are comprehensively detailed in [`LabCodes/lab-8_Labtest-1/prep/summary.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-8_Labtest-1/prep/summary.md). Rather than duplicating those basics, this section focuses strictly on the new architectural concepts introduced since then.

### Lab 9: Number Comparison & Extremums
* **Files**: [`9.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/9.1.asm), [`9.2_assignment.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/9.2_assignment.asm), [`9.3_alt_assignment.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/9.3_alt_assignment.asm), [`3value_Semim.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-9_Comparing_Numbers/3value_Semim.asm)
* **Theory Note**: [`9.1-theory.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Learning/9.1-theory.md)
* **What Was Added**:
  - The `CMP dest, src` instruction executes an internal subtraction without modifying the destination register, updating flags `ZF`, `SF`, `OF`, and `CF`.
  - Unsigned jump selection: `JA` (Above) and `JB` (Below) based on `CF` and `ZF`.
  - Signed jump selection: `JG` (Greater) and `JL` (Less) based on `SF` and `OF`.
  - Multi-variable comparison topologies (e.g. finding largest/smallest among three inputs using cascading branches).

### Lab 10: Quiz Review & Architectural Traps
* **Files**: [`studyGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-10_LabQuiz-1/prep/studyGuide.md), [`0.mustKnows.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/doc/note/0.mustKnows.md)
* **What Was Added**:
  - Systematic isolation of the `#DE` Divide Error fault caused by residual garbage in `AH`.
  - Clarification that ALU machine instructions (`ADD`, `SUB`, `DIV`, `CMP`) never invoke `INT 21h`.
  - The `INC`/`DEC` carry flag exemption (updates `ZF`, `SF`, `OF` but preserves `CF`).

### Lab 11: Nested Loops & Pattern Printing
* **Files**: [`patternPrinting.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-11_Patterns(Courtesy)/patternPrinting.asm), [`square pattern_Jawad_6A.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-11_Patterns(Courtesy)/square%20pattern_Jawad_6A.asm)
* **What Was Added**:
  - Nested loop execution on the 8086: Because `LOOP` exclusively uses `CX`, the outer loop counter must be preserved on the stack using `PUSH CX` before loading the inner count, and restored via `POP CX` after the inner loop finishes.
  - Dynamic column counter management: Using general registers (such as `BX` or `DX`) to track incrementing or decrementing star counts across rows.
  - Multi-line console formatting via Carriage Return (`13`) and Line Feed (`10`).

### Lab 12: Lab Test 2 Integration & Synthesis
* **Files**: [`MM Labtest-2 CSE-55-6A.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/MM%20Labtest-2%20CSE-55-6A.pdf), [`Solve Lab test 2.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/Solve%20Lab%20test%202.pdf)
* **What Was Added**:
  - Complete integration of all three topics into a unified assessment: Reading two inputs, executing arithmetic division to produce quotient ($C$) and remainder ($D$), printing a dynamic nested-loop pattern whose height is dictated by an input variable, and performing a conditional extremum comparison between $C$ and $D$.

---

## 3. Deep-Dive on the Three Syllabus Pillars

### Pillar 1: Creating Patterns in 8086 Assembly

#### 1. Why `PUSH CX` / `POP CX` Is Architecturally Mandatory
In the 8086 CPU, the `LOOP` instruction hardcodes the `CX` register as its decrement-and-branch counter. When implementing nested loops (e.g. an outer loop for rows and an inner loop for columns), both loops compete for `CX`.

To prevent the inner loop from destroying the outer loop counter, the stack must be utilized:
```assembly
    MOV CX, row_count       ; Outer loop counter

OUTER_LOOP:
    PUSH CX                 ; Save outer row counter to stack
    MOV CX, stars_this_row  ; Load inner column counter into CX

INNER_LOOP:
    MOV AH, 02H
    MOV DL, '*'
    INT 21H
    LOOP INNER_LOOP         ; Decrements CX until inner row is complete

    ; Emit Newline (CRLF)
    MOV AH, 02H
    MOV DL, 13              ; \r
    INT 21H
    MOV DL, 10              ; \n
    INT 21H

    POP CX                  ; Restore outer row counter from stack
    LOOP OUTER_LOOP         ; Decrements outer CX and repeats
```

> [!CAUTION]
> **Stack Imbalance Trap**: If you `PUSH CX` inside `OUTER_LOOP` but branch out of the loop before reaching `POP CX`, the stack pointer `SP` remains misaligned. When `RET` or subsequent pops execute, the program will crash or jump to an invalid memory location!

#### 2. Pattern Archetypes

| Pattern Type | Outer Loop (`CX`) | Inner Loop Count (`CX`) | Register Updates Per Row |
| :--- | :--- | :--- | :--- |
| **Standard Triangle** | Starts at Total Rows $N$ | Starts at $1$; loaded from `BX` | `INC BX` after each row |
| **Inverted Triangle** | Starts at Total Rows $N$ | Starts at $N$; loaded from `BX` | `DEC BX` after each row |
| **Solid Square / Grid** | Starts at Dimension $N$ | Fixed at Dimension $N$ | Reload $CX = N$ on each iteration |
| **Number Triangle** | Starts at Total Rows $N$ | Starts at $1$; column digit tracked in `DH` | `INC BX` (limit) & reset `DH = 1` |

---

### Pillar 2: Finding Largest and Smallest Numbers

#### 1. Internal Mechanics of `CMP`
The instruction `CMP dest, src` computes $(dest - src)$ internally and updates the `FLAGS` register:
* **Zero Flag (`ZF`)**: Set to `1` if $dest == src$.
* **Carry Flag (`CF`)**: Set to `1` if an unsigned borrow occurred ($dest < src$).
* **Sign Flag (`SF`)** and **Overflow Flag (`OF`)**: Evaluated for signed integers ($dest < src$ if $SF \ne OF$).

Crucially, **`dest` is not modified**.

#### 2. Branch Selection Guide
For single-digit numbers read from the keyboard (`'0'` through `'9'`, ASCII $30\text{h} \dots 39\text{h}$ or raw integers $0 \dots 9$), the values are unsigned positive quantities ($0 \le N \le 9$). Always use unsigned conditional jumps:

* **Finding Largest between A and B**:
  ```assembly
  MOV AL, A
  CMP AL, B
  JAE A_IS_MAX       ; If A >= B, AL already holds largest
  MOV AL, B          ; Else B is larger -> load B into AL
  A_IS_MAX:
  MOV largest, AL
  ```

* **Finding Smallest between A and B**:
  ```assembly
  MOV AL, A
  CMP AL, B
  JBE A_IS_MIN       ; If A <= B, AL already holds smallest
  MOV AL, B          ; Else B is smaller -> load B into AL
  A_IS_MIN:
  MOV smallest, AL
  ```

* **Finding Largest among Three Numbers (Tournament Method)**:
  ```assembly
  MOV AL, N1         ; Assume N1 is largest
  CMP AL, N2
  JAE CHECK_N3       ; If AL >= N2, continue with N3
  MOV AL, N2         ; Else N2 is currently largest

  CHECK_N3:
  CMP AL, N3
  JAE DONE
  MOV AL, N3         ; N3 is the absolute largest

  DONE:
  MOV largest, AL
  ```

---

### Pillar 3: Arithmetic Division & Operand Hygiene

#### 1. Sizing Rules for 8-bit Division
In 8086 assembly, 8-bit division (`DIV divisor8`) divides the entire **16-bit register `AX`** by `divisor8`:
$$\text{Quotient} \rightarrow \text{AL}, \quad \text{Remainder} \rightarrow \text{AH}$$

```
+------------------------------------+
|                 AX                 | (Dividend: 16 bits)
+------------------+-----------------+
|        AH        |       AL        |
|  (Must be 00h)   | (Input Digit A) |
+------------------+-----------------+
                  ÷
           [ Divisor: B ] (8 bits)
                  =
     AL = Quotient,  AH = Remainder
```

#### 2. The Catastrophic `#DE` Divide Error Bug
If you execute:
```assembly
MOV AL, val_a
DIV val_b           ; FATAL BUG if AH contains leftover data!
```
If `AH` previously held `01h` (from reading input via `AH=01h`), `AX` is not $A$; it is $(256 \times 1) + A = 256 + A$.
Dividing $256 + A$ by a small divisor like $2$ produces a quotient of $\ge 128$, which may trigger an immediate **Divide Error Interrupt (`#DE` / Interrupt 0)**.

**The Fix**: Always zero `AH` immediately prior to division:
```assembly
MOV AL, val_a
XOR AH, AH          ; Clears AH to 00h in 2 fast bytes
DIV val_b           ; Guaranteed safe division
```

---

## 4. Official Lab Test 2 Questions & Complete Solutions

The official question paper for Section 6A contains two variants: **Set A** and **Set B**.

### Set A Solution & Walkthrough (`labtest2_setA.asm`)
* **Source Code**: [`labtest2_setA.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/prep/labtest2_setA.asm)
* **Prompt Sequence**: `Enter B: `, then `Enter A: `.
* **Pattern**: Right-angled triangle of `$` with exactly **$B$ rows**.
* **Extremum**: Find the **largest** number between quotient $C$ and remainder $D$.
* **Required Output**:
  ```text
  Enter B: 2
  Enter A: 9
  $
  $$
  Largest between C and D: 4
  ```

#### Execution Trace for Set A ($B=2, A=9$):
1. **Input Phase**: $B$ is read into `val_b = 2`; $A$ is read into `val_a = 9`.
2. **Arithmetic Phase**:
   - `AX = 0009h`, `BL = 2`.
   - `DIV BL` $\implies \text{Quotient } AL = 4$, $\text{Remainder } AH = 1$.
   - $C = 4$, $D = 1$.
3. **Pattern Phase**:
   - Outer loop `CX = B = 2`.
   - Row 1 ($BX=1$): prints `$` followed by CRLF.
   - Row 2 ($BX=2$): prints `$$` followed by CRLF.
4. **Comparison Phase**:
   - `CMP C, D` $\implies 4 - 1 > 0 \implies C \ge D$.
   - Largest $= 4$.
5. **Display**: Emits `Largest between C and D: 4`.

---

### Set B Solution & Walkthrough (`labtest2_setB.asm`)
* **Source Code**: [`labtest2_setB.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/prep/labtest2_setB.asm)
* **Student Reference**: [`Solve Lab test 2.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/Solve%20Lab%20test%202.pdf)
* **Prompt Sequence**: `Enter B: `, then `Enter A: `.
* **Pattern**: Right-angled triangle of `%` with exactly **$A$ rows**.
* **Extremum**: Find the **smallest** number between quotient $C$ and remainder $D$.
* **Required Output**:
  ```text
  Enter B: 3
  Enter A: 5
  %
  %%
  %%%
  %%%%
  %%%%%
  Smallest between C and D: 1
  ```

#### Execution Trace for Set B ($B=3, A=5$):
1. **Input Phase**: $B$ is read into `val_b = 3`; $A$ is read into `val_a = 5`.
2. **Arithmetic Phase**:
   - `AX = 0005h`, `BL = 3`.
   - `DIV BL` $\implies \text{Quotient } AL = 1$, $\text{Remainder } AH = 2$.
   - $C = 1$, $D = 2$.
3. **Pattern Phase**:
   - Outer loop `CX = A = 5` (uses $A$ instead of $B$).
   - Prints 5 rows of `%` from 1 up to 5 characters.
4. **Comparison Phase**:
   - `CMP C, D` $\implies 1 - 2 < 0 \implies C \le D$.
   - Smallest $= 1$.
5. **Display**: Emits `Smallest between C and D: 1`.

---

### Comparative Analysis: Set A vs. Set B

| Feature | Set A ([`labtest2_setA.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/prep/labtest2_setA.asm)) | Set B ([`labtest2_setB.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/prep/labtest2_setB.asm)) |
| :--- | :--- | :--- |
| **Input Order** | `Enter B:` then `Enter A:` | `Enter B:` then `Enter A:` |
| **Pattern Character** | Dollar sign (`$`) | Percent sign (`%`) |
| **Pattern Height** | **$B$ rows** (`MOV CL, val_b`) | **$A$ rows** (`MOV CL, val_a`) |
| **Extremum Goal** | **Largest** between $C$ and $D$ | **Smallest** between $C$ and $D$ |
| **Branch Instruction** | `JAE C_IS_GREATER` | `JBE C_IS_SMALLER` |
| **Label Message** | `'Largest between C and D: $'` | `'Smallest between C and D: $'` |

---

## 5. Expanded Practice Variants & Immediate Coded Solutions

To prepare for tomorrow's lab test, practice with these high-probability variations covering different pattern shapes, arithmetic combinations, and multi-variable comparisons.

---

### Variant 1: Inverted Triangle Pattern + Multiplication & Extremum (`sample1_inverted_triangle_extremum.asm`)
* **Source Code**: [`sample1_inverted_triangle_extremum.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/prep/sample1_inverted_triangle_extremum.asm)
* **Problem Statement**:
  1. Read single-digit inputs $A$ (height) and $B$.
  2. Print an **inverted** right-angled triangle of `*` with exactly $A$ rows (Row 1 has $A$ stars, Row 2 has $A-1$ stars, ..., Row $A$ has 1 star).
  3. Compute $(A \times B) / 2$ to obtain quotient and remainder.
  4. Find and print the larger of the quotient and remainder.
* **Key Focus Points**:
  - Inverted row tracking: Initialize column counter `BX` to $A$, and execute `DEC BX` after each row instead of `INC BX`.
  - Unsigned multiplication: `MUL val_b` produces product in `AX`.
* **Concepts Used**:
  - `DEC` decrement operator in nested loops.
  - 8-bit `MUL` accumulator behavior.
  - Stack preservation during inverted loops.
* **Further Learning**:
  - Notice that `DEC` does not affect `CF`, but `SUB` does. In loops, `DEC BX` safely preserves arithmetic carry flags.

---

### Variant 2: Number Triangle Pattern + 3-Number Largest (`sample2_number_pattern_largest3.asm`)
* **Source Code**: [`sample2_number_pattern_largest3.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/prep/sample2_number_pattern_largest3.asm)
* **Problem Statement**:
  1. Read three single-digit inputs: $N1$, $N2$, and $N3$.
  2. Print a right-angled triangle of incrementing numbers from $1$ up to $N1$:
     ```text
     1 
     1 2 
     1 2 3 
     1 2 3 4 
     ```
  3. Find the absolute largest number among all three inputs ($N1, N2, N3$).
  4. Display the result.
* **Key Focus Points**:
  - Digit generation in inner loop: Track column digit in `DH`, starting at `1`, printing `DH + '0'`, followed by a space `' '`, then `INC DH`.
  - 3-variable tournament comparison logic without redundant branching.
* **Concepts Used**:
  - Dynamic character generation inside nested loops.
  - Multi-variable comparison cascading.
* **Further Learning**:
  - For larger comparisons (e.g. 10 numbers in an array), replace cascading `CMP` with a memory loop indexing through `[SI]` as demonstrated in Lab 7.

---

### Variant 3: Square Grid Pattern + Absolute Difference & Minimum (`sample3_square_pattern_arithmetic.asm`)
* **Source Code**: [`sample3_square_pattern_arithmetic.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-12_Labtest-2/prep/sample3_square_pattern_arithmetic.asm)
* **Problem Statement**:
  1. Read inputs $A$ (grid dimension) and $B$.
  2. Print a solid $A \times A$ square grid of `#` characters separated by spaces.
  3. Compute the **absolute difference** $|A - B|$.
  4. Compute the remainder of $A / B$.
  5. Find and print the smaller of the difference and remainder.
* **Key Focus Points**:
  - Square grid logic: Both outer and inner loops use the exact same count ($A$).
  - Absolute difference logic: If $A \ge B$, compute $A - B$; if $A < B$, compute $B - A$.
* **Concepts Used**:
  - Square grid matrix traversal.
  - Unsigned branch redirection for absolute value computation.
* **Further Learning**:
  - The `NEG` instruction can also be used: compute $A - B$; if negative (`JS`), execute `NEG AL`.

---

## 6. Master Exam-Day Trap Sheet & Checklist

Verify your code against these high-yield rules before submitting in EMU8086:

| Check | Bug / Trap | Correct Assembly Practice |
| :--- | :--- | :--- |
| **Input Conversion** | Forgetting `SUB AL, '0'` | Keyboard character is ASCII ($30\text{h} \dots 39\text{h}$). You **must** subtract `'0'` before arithmetic or loops! |
| **Output Conversion** | Forgetting `ADD DL, '0'` | Numerical integer ($0 \dots 9$) must be converted back to ASCII by adding `'0'` before `INT 21h, AH=02h`. |
| **Division Dividend** | Leftover data in `AH` | Always write `XOR AH, AH` immediately prior to `DIV reg8`. |
| **Nested Loop Registers** | Inner loop destroys outer count | Always wrap inner loop with `PUSH CX` and `POP CX`. |
| **Prompt Order** | Reading $A$ then $B$ when question asks $B$ then $A$ | Read sample output carefully! In Labtest 2, $B$ is prompted first (`Enter B:`), then $A$ (`Enter A:`). |
| **Row Count Variable** | Using wrong input for rows | In Set A, rows $= B$; in Set B, rows $= A$. Verify which variable controls the pattern height. |
| **Extremum Selection** | Using signed jumps (`JG`/`JL`) | For positive ASCII digits, use unsigned jumps: `JAE` (Largest) and `JBE` (Smallest). |
| **CRLF Formatting** | Staircase text output | After printing each row, emit both Carriage Return (`13`) and Line Feed (`10`). |
| **Program Termination** | Omitting `MOV AH, 4CH; INT 21H` | Required at the end of every 8086 executable to surrender control back to DOS. |

