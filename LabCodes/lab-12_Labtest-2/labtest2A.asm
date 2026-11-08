; ============================================================================
; Program: labtest2A.asm (Corrected & Merged Stack-Based Implementation)
; Course: CSE0611324 - Microprocessors & Microcontrollers Lab
; Assessment: Lab Test 2 (Set A - Stack Approach)
; Description:
;   Merged and corrected version of labtest2A_largest.asm and labtest2A_pattern.asm.
;   Implements the pure stack approach (PUSH/POP):
;     1. Reads single-digit inputs B and A from keyboard.
;     2. Divides A by B -> AL = Quotient (C), AH = Remainder (D).
;     3. Pushes quotient/remainder and row count directly onto the stack.
;     4. Pops B into CX to drive the outer loop of the '$' triangle pattern.
;     5. Uses PUSH CX / POP CX to preserve outer counter during inner star printing.
;     6. Pops quotient and remainder back from the stack for comparison.
;     7. Determines the largest value and prints formatted output with the digit!
;
; Sample Output:
;   input B : 2
;   input A : 9
;   $
;   $$
;   Largest between C and D: 4
; ============================================================================

.MODEL SMALL
.STACK 100H

.DATA
    msg_b   DB "input B : $"
    msg_a   DB 13, 10, "input A : $"
    msg_crlf DB 13, 10, "$"
    msg_res DB 13, 10, "Largest between C and D: $"

.CODE
MAIN PROC
    ; 1. Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ; ------------------------------------------------------------------------
    ; 2. Read Input B (Divisor and Pattern Row Count)
    ; ------------------------------------------------------------------------
    LEA DX, msg_b
    MOV AH, 09H
    INT 21H

    MOV AH, 01H                 ; Read character with echo
    INT 21H
    SUB AL, '0'                 ; Convert ASCII code to integer digit
    XOR AH, AH                  ; Clear high byte so AX = integer B
    MOV BX, AX                  ; Save B in BX

    ; ------------------------------------------------------------------------
    ; 3. Read Input A (Dividend)
    ; ------------------------------------------------------------------------
    LEA DX, msg_a
    MOV AH, 09H
    INT 21H

    MOV AH, 01H                 ; Read character with echo
    INT 21H
    SUB AL, '0'                 ; Convert ASCII code to integer digit

    ; ------------------------------------------------------------------------
    ; 4. Perform Arithmetic Division: A / B
    ;    AX = A, BL = B
    ;    DIV BL -> AL = Quotient (C), AH = Remainder (D)
    ; ------------------------------------------------------------------------
    XOR AH, AH                  ; CRITICAL: Clear AH before 8-bit DIV to prevent #DE
    DIV BL                      ; AL = A / B (Quotient), AH = A % B (Remainder)

    ; ------------------------------------------------------------------------
    ; 5. STACK PRESERVATION:
    ;    Save Quotient (AL) & Remainder (AH) in ONE push!
    ;    Save Row Count (BX) in second push!
    ; ------------------------------------------------------------------------
    PUSH AX                     ; Stack holds [Quotient (C) in AL : Remainder (D) in AH]
    PUSH BX                     ; Stack holds [Row count B]

    ; Print CRLF before pattern
    LEA DX, msg_crlf
    MOV AH, 09H
    INT 21H

    ; ------------------------------------------------------------------------
    ; 6. PATTERN PRINTING USING STACK:
    ;    Pop B directly into CX for outer loop counter!
    ; ------------------------------------------------------------------------
    POP CX                      ; CX = B (outer loop counter)
    JCXZ SKIP_PATTERN           ; Guard if B = 0

    MOV BX, 1                   ; BX tracks number of '$' to print in current row

OUTER_LOOP:
    PUSH CX                     ; Preserve outer loop counter onto stack
    MOV CX, BX                  ; Set inner loop counter = current row star count

INNER_LOOP:
    MOV AH, 02H                 ; DOS service: Output character
    MOV DL, '$'
    INT 21H
    LOOP INNER_LOOP             ; Print '$' until CX reaches 0

    ; New line after each row
    LEA DX, msg_crlf
    MOV AH, 09H
    INT 21H

    INC BX                      ; Next row gets one more '$'
    POP CX                      ; Restore outer loop counter from stack
    LOOP OUTER_LOOP             ; Decrement CX and repeat for all B rows

SKIP_PATTERN:

    ; ------------------------------------------------------------------------
    ; 7. STACK RESTORATION & EXTREMUM COMPARISON:
    ;    Retrieve Quotient (C) and Remainder (D) directly from stack!
    ; ------------------------------------------------------------------------
    POP AX                      ; Restore AX: AL = Quotient (C), AH = Remainder (D)

    MOV BL, AH                  ; BL = D (Remainder)
                                ; AL = C (Quotient)
    CMP AL, BL                  ; Compare C and D
    JAE C_IS_LARGEST            ; If C >= D, AL already holds largest!
    MOV AL, BL                  ; Else D is larger, load D into AL

C_IS_LARGEST:
    PUSH AX                     ; Save largest value on stack before printing string

    ; ------------------------------------------------------------------------
    ; 8. Display Formatted Output with the Computed Digit
    ; ------------------------------------------------------------------------
    LEA DX, msg_res
    MOV AH, 09H
    INT 21H

    POP AX                      ; Retrieve largest value
    MOV DL, AL
    ADD DL, '0'                 ; Convert integer digit back to ASCII code
    MOV AH, 02H
    INT 21H

    ; ------------------------------------------------------------------------
    ; 9. Graceful Program Exit
    ; ------------------------------------------------------------------------
    MOV AH, 4CH
    INT 21H

MAIN ENDP
END MAIN
