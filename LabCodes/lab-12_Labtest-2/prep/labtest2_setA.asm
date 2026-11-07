; ============================================================================
; Program: labtest2_setA.asm
; Course: CSE0611324 - Microprocessors & Microcontrollers Lab
; Assessment: Lab Test 2, Autumn 2026 (Section 6A - Set A)
; Description:
;   Suppose A is divided by B and C is quotient while D is the remainder.
;   1. Take single-digit inputs for B and A (Note: Prompt order in sample is B then A).
;   2. Print a right-angled triangle pattern of ($) with exactly B rows.
;      Row 1 has 1 ($), Row 2 has 2 ($), ..., Row B has B ($).
;   3. Find the largest number between C (quotient) and D (remainder).
;   4. Print as per the official sample output.
;
; Sample Output:
;   Enter B: 2
;   Enter A: 9
;   $
;   $$
;   Largest between C and D: 4
; ============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    ; User prompt strings with embedded CRLF (13, 10)
    msg_b       DB 'Enter B: $'
    msg_a       DB 13, 10, 'Enter A: $'
    msg_largest DB 13, 10, 'Largest between C and D: $'

    ; Storage variables for inputs, arithmetic results, and extremum
    val_a       DB ?            ; Input A (Dividend)
    val_b       DB ?            ; Input B (Divisor & Row Count)
    val_c       DB ?            ; Quotient (C = A / B)
    val_d       DB ?            ; Remainder (D = A % B)
    max_val     DB ?            ; Holds largest of C and D

.CODE
MAIN PROC
    ; ------------------------------------------------------------------------
    ; 1. Initialize Data Segment
    ; ------------------------------------------------------------------------
    MOV AX, @DATA
    MOV DS, AX

    ; ------------------------------------------------------------------------
    ; 2. Read Single-Digit Input B (Divisor and Pattern Height)
    ; ------------------------------------------------------------------------
    LEA DX, msg_b
    MOV AH, 09H
    INT 21H

    MOV AH, 01H                 ; DOS service: Read character with echo
    INT 21H
    SUB AL, '0'                 ; Convert ASCII character to raw numerical integer
    MOV val_b, AL               ; Store in val_b

    ; ------------------------------------------------------------------------
    ; 3. Read Single-Digit Input A (Dividend)
    ; ------------------------------------------------------------------------
    LEA DX, msg_a
    MOV AH, 09H
    INT 21H

    MOV AH, 01H                 ; DOS service: Read character with echo
    INT 21H
    SUB AL, '0'                 ; Convert ASCII character to raw numerical integer
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
    XOR AH, AH                  ; CRITICAL: Clear high byte of AX to prevent #DE fault
    DIV val_b                   ; Unsigned 8-bit division: AX / val_b

    MOV val_c, AL               ; Save quotient in C
    MOV val_d, AH               ; Save remainder in D

    ; ------------------------------------------------------------------------
    ; 5. Print Right-Angled Triangle Pattern of ($) with B Rows
    ;    Outer Loop: CX = B rows
    ;    Inner Loop: CX = current row number (tracked in BX, starts at 1)
    ; ------------------------------------------------------------------------
    XOR CX, CX
    MOV CL, val_b               ; Outer loop counter = B rows
    JCXZ SKIP_PATTERN           ; Guard against B = 0

    MOV BX, 1                   ; BX holds number of '$' to print on current row

ROW_LOOP:
    PUSH CX                     ; Save outer loop counter onto stack

    MOV CX, BX                  ; Inner loop counter = number of '$' for this row

DOLLAR_LOOP:
    MOV AH, 02H                 ; DOS service: Character output
    MOV DL, '$'                 ; Character to print
    INT 21H
    LOOP DOLLAR_LOOP            ; Decrement CX, repeat until CX = 0

    ; Emit newline (Carriage Return + Line Feed) after finishing row
    MOV AH, 02H
    MOV DL, 13                  ; Carriage Return (\r)
    INT 21H
    MOV DL, 10                  ; Line Feed (\n)
    INT 21H

    INC BX                      ; Next row will contain one more '$'
    POP CX                      ; Restore outer loop counter from stack
    LOOP ROW_LOOP               ; Repeat for all B rows

SKIP_PATTERN:

    ; ------------------------------------------------------------------------
    ; 6. Find the Largest Number Between C (Quotient) and D (Remainder)
    ; ------------------------------------------------------------------------
    MOV AL, val_c               ; Load quotient C
    CMP AL, val_d               ; Compare C with remainder D (evaluates C - D)
    JAE C_IS_GREATER            ; If C >= D (unsigned above or equal), jump

    MOV AL, val_d               ; Else, D is larger: load D into AL

C_IS_GREATER:
    MOV max_val, AL             ; Store largest value in max_val

    ; ------------------------------------------------------------------------
    ; 7. Display Final Result According to Sample Output
    ; ------------------------------------------------------------------------
    LEA DX, msg_largest
    MOV AH, 09H
    INT 21H

    MOV DL, max_val
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

