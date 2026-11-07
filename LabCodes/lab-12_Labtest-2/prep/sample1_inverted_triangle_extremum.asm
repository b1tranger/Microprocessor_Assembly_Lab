; ============================================================================
; Program: sample1_inverted_triangle_extremum.asm
; Course: CSE0611324 - Microprocessors & Microcontrollers Lab
; Assessment: Lab Test 2 Practice Variant 1
; Topic: Inverted Right-Angled Triangle Pattern + Multiplication & Extremum
; Description:
;   1. Takes two single-digit inputs A and B from the keyboard.
;   2. Prints an INVERTED right-angled triangle pattern of (*) with exactly A rows.
;      Row 1 contains A (*), Row 2 contains A-1 (*), down to Row A with 1 (*).
;   3. Multiplies A * B and divides by 2.
;   4. Finds whether the quotient or remainder is larger and prints the result.
;
; Sample Execution:
;   Enter A (Height): 4
;   Enter B: 3
;   ****
;   ***
;   **
;   *
;   Product A*B = 12, Half = 6 (Quotient: 6, Remainder: 0)
;   Largest is: 6
; ============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    msg_a       DB 'Enter A (Height): $'
    msg_b       DB 13, 10, 'Enter B: $'
    msg_largest DB 13, 10, 'Largest value is: $'

    val_a       DB ?            ; Input A
    val_b       DB ?            ; Input B
    quot        DB ?            ; Quotient
    rem         DB ?            ; Remainder
    max_res     DB ?            ; Maximum

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

    ; Print CRLF before pattern
    MOV AH, 02H
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H

    ; ------------------------------------------------------------------------
    ; INVERTED TRIANGLE PATTERN:
    ; Row 1: A stars
    ; Row 2: A-1 stars
    ; ...
    ; Row A: 1 star
    ; Outer loop runs A times.
    ; BX starts at A, decrements each row!
    ; ------------------------------------------------------------------------
    XOR CX, CX
    MOV CL, val_a
    JCXZ SKIP_INVERTED_PATTERN

    XOR BX, BX
    MOV BL, val_a               ; Start row star count at A

OUTER_ROW:
    PUSH CX                     ; Save outer loop counter
    MOV CX, BX                  ; Inner loop counter = current star count in BX

STAR_COL:
    MOV AH, 02H
    MOV DL, '*'
    INT 21H
    LOOP STAR_COL

    ; CRLF after each row
    MOV AH, 02H
    MOV DL, 13
    INT 21H
    MOV DL, 10
    INT 21H

    DEC BX                      ; Inverted: Decrement star count for next row
    POP CX                      ; Restore outer loop counter
    LOOP OUTER_ROW

SKIP_INVERTED_PATTERN:

    ; ------------------------------------------------------------------------
    ; ARITHMETIC & EXTREMUM:
    ; Product = val_a * val_b
    ; Divide product by 2 -> Quotient in AL, Remainder in AH
    ; ------------------------------------------------------------------------
    MOV AL, val_a
    MUL val_b                   ; AX = AL * val_b
    MOV BL, 2
    DIV BL                      ; AL = AX / 2, AH = AX % 2

    MOV quot, AL
    MOV rem, AH

    ; Find largest between quotient and remainder
    CMP AL, AH
    JAE QUOT_IS_MAX
    MOV AL, AH
QUOT_IS_MAX:
    MOV max_res, AL

    ; Display Largest Result
    LEA DX, msg_largest
    MOV AH, 09H
    INT 21H

    MOV DL, max_res
    ADD DL, '0'
    MOV AH, 02H
    INT 21H

    ; Exit
    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN

