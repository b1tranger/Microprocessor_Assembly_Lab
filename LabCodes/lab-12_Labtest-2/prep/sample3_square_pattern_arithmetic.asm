; ============================================================================
; Program: sample3_square_pattern_arithmetic.asm
; Course: CSE0611324 - Microprocessors & Microcontrollers Lab
; Assessment: Lab Test 2 Practice Variant 3
; Topic: N x N Square Grid Pattern + Subtraction Difference & Smallest Selection
; Description:
;   1. Takes two single-digit inputs A and B from the keyboard.
;   2. Prints an A x A square grid of '#' characters separated by spaces.
;   3. Computes the absolute difference |A - B|.
;   4. Computes remainder of A divided by B.
;   5. Finds and prints the smallest value between the difference and remainder.
;
; Sample Execution:
;   Enter A (Grid Size): 3
;   Enter B: 2
;   # # # 
;   # # # 
;   # # # 
;   Smallest value: 1
; ============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    msg_a       DB 'Enter A (Grid Size): $'
    msg_b       DB 13, 10, 'Enter B: $'
    msg_min     DB 13, 10, 'Smallest value: $'

    val_a       DB ?
    val_b       DB ?
    diff        DB ?
    rem         DB ?
    min_res     DB ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Read Input A
    LEA DX, msg_a
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV val_a, AL

    ; Read Input B
    LEA DX, msg_b
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    SUB AL, '0'
    MOV val_b, AL

    ; CRLF before grid
    MOV AH, 02H
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H

    ; ------------------------------------------------------------------------
    ; SQUARE GRID PATTERN (val_a rows x val_a columns)
    ; Outer Loop: CX = val_a
    ; Inner Loop: CX = val_a
    ; ------------------------------------------------------------------------
    XOR CX, CX
    MOV CL, val_a
    JCXZ SKIP_SQUARE

ROW_LOOP:
    PUSH CX                     ; Save outer loop counter

    XOR CX, CX
    MOV CL, val_a               ; Inner loop: print val_a characters

COL_LOOP:
    MOV AH, 02H
    MOV DL, '#'
    INT 21H

    MOV DL, ' '                 ; Space delimiter
    INT 21H
    LOOP COL_LOOP

    ; CRLF at row end
    MOV AH, 02H
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H

    POP CX                      ; Restore outer loop counter
    LOOP ROW_LOOP

SKIP_SQUARE:

    ; ------------------------------------------------------------------------
    ; ARITHMETIC CALCULATIONS:
    ; 1. Absolute Difference: |val_a - val_b|
    ; ------------------------------------------------------------------------
    MOV AL, val_a
    CMP AL, val_b
    JAE A_GREATER_EQUAL
    ; If A < B: Diff = B - A
    MOV AL, val_b
    SUB AL, val_a
    JMP STORE_DIFF

A_GREATER_EQUAL:
    SUB AL, val_b

STORE_DIFF:
    MOV diff, AL

    ; ------------------------------------------------------------------------
    ; 2. Remainder of val_a / val_b
    ; ------------------------------------------------------------------------
    MOV AL, val_a
    XOR AH, AH                  ; Hygiene before division
    DIV val_b                   ; AH = remainder
    MOV rem, AH

    ; ------------------------------------------------------------------------
    ; 3. Find Smallest Between Difference and Remainder
    ; ------------------------------------------------------------------------
    MOV AL, diff
    CMP AL, rem
    JBE DIFF_IS_MIN
    MOV AL, rem
DIFF_IS_MIN:
    MOV min_res, AL

    ; Display Result
    LEA DX, msg_min
    MOV AH, 09H
    INT 21H

    MOV DL, min_res
    ADD DL, '0'
    MOV AH, 02H
    INT 21H

    ; Exit
    MOV AH, 4CH
    INT 21H

MAIN ENDP
END MAIN

