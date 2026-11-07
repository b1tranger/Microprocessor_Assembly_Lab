; ============================================================================
; Program: labtest2_setB.asm
; Course: CSE0611324 - Microprocessors & Microcontrollers Lab
; Assessment: Lab Test 2, Autumn 2026 (Section 6A - Set B)
; Description:
;   Suppose A is divided by B and C is quotient while D is the remainder.
;   1. Take single-digit inputs for B and A (Prompt order in sample: B then A).
;   2. Print a right-angled triangle pattern of (%) with exactly A rows.
;      Row 1 has 1 (%), Row 2 has 2 (%), ..., Row A has A (%).
;   3. Find the smallest number between C (quotient) and D (remainder).
;   4. Print as per the official sample output.
;
; Sample Output:
;   Enter B: 3
;   Enter A: 5
;   %
;   %%
;   %%%
;   %%%%
;   %%%%%
;   Smallest between C and D: 1
; ============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    ; User prompt strings with embedded CRLF (13, 10)
    msg_b        DB 'Enter B: $'
    msg_a        DB 13, 10, 'Enter A: $'
    msg_smallest DB 13, 10, 'Smallest between C and D: $'

    ; Storage variables for inputs, arithmetic results, and extremum
    val_a        DB ?           ; Input A (Dividend & Pattern Height)
    val_b        DB ?           ; Input B (Divisor)
    val_c        DB ?           ; Quotient (C = A / B)
    val_d        DB ?           ; Remainder (D = A % B)
    min_val      DB ?           ; Holds smallest of C and D

.CODE
MAIN PROC
    ; ------------------------------------------------------------------------
    ; 1. Initialize Data Segment
    ; ------------------------------------------------------------------------
    MOV AX, @DATA
    MOV DS, AX

    ; ------------------------------------------------------------------------
    ; 2. Read Single-Digit Input B (Divisor)
    ; ------------------------------------------------------------------------
    LEA DX, msg_b
    MOV AH, 09H
    INT 21H

    MOV AH, 01H                 ; DOS service: Read character with echo
    INT 21H
    SUB AL, '0'                 ; Convert ASCII to raw numerical integer
    MOV val_b, AL               ; Store in val_b

    ; ------------------------------------------------------------------------
    ; 3. Read Single-Digit Input A (Dividend & Pattern Height)
    ; ------------------------------------------------------------------------
    LEA DX, msg_a
    MOV AH, 09H
    INT 21H

    MOV AH, 01H                 ; DOS service: Read character with echo
    INT 21H
    SUB AL, '0'                 ; Convert ASCII to raw numerical integer
    MOV val_a, AL               ; Store in val_a

    ; Print newline before starting pattern output
    MOV AH, 02H
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H

    ; ------------------------------------------------------------------------
    ; 4. Perform Arithmetic Division: A / B
    ;    AX / val_b -> AL = Quotient (C), AH = Remainder (D)
    ; ------------------------------------------------------------------------
    MOV AL, val_a
    XOR AH, AH                  ; CRITICAL: Zero AH before 8-bit division to prevent #DE
    DIV val_b                   ; Unsigned 8-bit division: AX / val_b

    MOV val_c, AL               ; Save quotient in C
    MOV val_d, AH               ; Save remainder in D

    ; ------------------------------------------------------------------------
    ; 5. Print Right-Angled Triangle Pattern of (%) with A Rows
    ;    Outer Loop: CX = A rows (Note: Set B uses A rows instead of B rows)
    ;    Inner Loop: CX = current row number (tracked in BX, starts at 1)
    ; ------------------------------------------------------------------------
    XOR CX, CX
    MOV CL, val_a               ; Outer loop counter = A rows
    JCXZ SKIP_PATTERN           ; Guard against A = 0

    MOV BX, 1                   ; BX holds number of '%' to print on current row

ROW_LOOP:
    PUSH CX                     ; Save outer loop counter onto stack

    MOV CX, BX                  ; Inner loop counter = number of '%' for this row

PERCENT_LOOP:
    MOV AH, 02H                 ; DOS service: Character output
    MOV DL, '%'                 ; Character to print
    INT 21H
    LOOP PERCENT_LOOP           ; Decrement CX, repeat until CX = 0

    ; Emit newline (Carriage Return + Line Feed) after finishing row
    MOV AH, 02H
    MOV DL, 13                  ; Carriage Return (\r)
    INT 21H
    MOV DL, 10                  ; Line Feed (\n)
    INT 21H

    INC BX                      ; Next row will contain one more '%'
    POP CX                      ; Restore outer loop counter from stack
    LOOP ROW_LOOP               ; Repeat for all A rows

SKIP_PATTERN:

    ; ------------------------------------------------------------------------
    ; 6. Find the Smallest Number Between C (Quotient) and D (Remainder)
    ; ------------------------------------------------------------------------
    MOV AL, val_c               ; Load quotient C
    CMP AL, val_d               ; Compare C with remainder D
    JBE C_IS_SMALLER            ; If C <= D (unsigned below or equal), C is minimum

    MOV AL, val_d               ; Else, D is smaller: load D into AL

C_IS_SMALLER:
    MOV min_val, AL             ; Store minimum value in min_val

    ; ------------------------------------------------------------------------
    ; 7. Display Final Result According to Sample Output
    ; ------------------------------------------------------------------------
    LEA DX, msg_smallest
    MOV AH, 09H
    INT 21H

    MOV DL, min_val
    ADD DL, '0'                 ; Convert integer back to ASCII character code
    MOV AH, 02H
    INT 21H

    ; ------------------------------------------------------------------------
    ; 8. Terminate Program Gracefully
    ; ------------------------------------------------------------------------
    MOV AH, 4CH                 ; DOS service: Terminate process
    INT 21H

MAIN ENDP
END MAIN

