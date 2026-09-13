; =============================================================================
; File: arithmetic_operations.asm
; Directory: LabCodes/Labtest/prep/arithmetic_operations.asm
; Description: Dedicated 8086 Assembly demonstration of all 4 arithmetic
;              operations (ADD, SUB, MUL, DIV) with dynamic user inputs,
;              LEA-based prompt addressing, AH register clearing hygiene,
;              and 2-digit decimal decomposition for output display.
; Target: MASM / TASM / EMU8086
; =============================================================================

.model small
.stack 100h

.data
    ; User Prompts (utilizing embedded CRLF for clean formatting)
    prompt_op1      db 'Enter first single digit (0-9): $'
    prompt_op2      db 13, 10, 'Enter second single digit (1-9): $'
    
    msg_header      db 13, 10, 13, 10, '--- ARITHMETIC RESULTS ---$'
    msg_add         db 13, 10, 'Addition (A + B)       = $'
    msg_sub         db 13, 10, 'Subtraction (A - B)    = $'
    msg_mul         db 13, 10, 'Multiplication (A * B) = $'
    msg_div_q       db 13, 10, 'Division Quotient      = $'
    msg_div_r       db 13, 10, 'Division Remainder     = $'
    msg_neg         db '-$'

    ; Storage variables
    val_a           db ?
    val_b           db ?
    res_add         db ?
    res_sub         db ?
    res_mul         dw ?        ; 16-bit word for product
    res_quot        db ?
    res_rem         db ?
    is_negative     db 0

.code
main proc
    ; -------------------------------------------------------------------------
    ; 1. Segment Register Initialization
    ; -------------------------------------------------------------------------
    mov ax, @data
    mov ds, ax

    ; -------------------------------------------------------------------------
    ; 2. Input First Operand (val_a) using LEA addressing
    ; -------------------------------------------------------------------------
    lea dx, prompt_op1          ; Alternative: LEA instead of MOV DX, OFFSET
    mov ah, 09h
    int 21h

    mov ah, 01h                 ; Read single character into AL
    int 21h
    sub al, '0'                 ; Convert ASCII ('0'-'9') to raw numeric value
    mov val_a, al

    ; -------------------------------------------------------------------------
    ; 3. Input Second Operand (val_b)
    ; -------------------------------------------------------------------------
    lea dx, prompt_op2
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'                 ; Convert ASCII to numeric
    mov val_b, al

    ; Print Results Section Header
    lea dx, msg_header
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; 4. ADDITION: val_a + val_b
    ; -------------------------------------------------------------------------
    mov al, val_a
    add al, val_b
    mov res_add, al

    lea dx, msg_add
    mov ah, 09h
    int 21h

    mov al, res_add
    call print_two_digits       ; Handles 0 to 18 (e.g. 9 + 9 = 18)

    ; -------------------------------------------------------------------------
    ; 5. SUBTRACTION: val_a - val_b (with negative number handling)
    ; -------------------------------------------------------------------------
    lea dx, msg_sub
    mov ah, 09h
    int 21h

    mov al, val_a
    cmp al, val_b
    jae sub_positive

    ; If val_a < val_b, result is negative: print '-' and negate
    lea dx, msg_neg
    mov ah, 09h
    int 21h

    mov al, val_b
    sub al, val_a
    jmp sub_display

sub_positive:
    sub al, val_b

sub_display:
    mov res_sub, al
    call print_two_digits

    ; -------------------------------------------------------------------------
    ; 6. MULTIPLICATION: val_a * val_b (MUL operand)
    ;    8-bit MUL uses AL as implicit multiplicand, product in AX (AH:AL)
    ; -------------------------------------------------------------------------
    lea dx, msg_mul
    mov ah, 09h
    int 21h

    mov al, val_a
    mov bl, val_b
    mul bl                      ; AX = AL * BL (Max: 9 * 9 = 81)
    mov res_mul, ax

    ; AL holds the product because 81 fits in AL
    call print_two_digits

    ; -------------------------------------------------------------------------
    ; 7. DIVISION: val_a / val_b (DIV operand)
    ;    8-bit DIV divides AX by operand. Quotient in AL, Remainder in AH.
    ;    CRITICAL: AH must be cleared to 0 prior to division!
    ; -------------------------------------------------------------------------
    mov al, val_a
    xor ah, ah                  ; Clear AH (register hygiene prevents #DE fault)
    mov bl, val_b
    div bl                      ; AL = AX / BL (Quotient), AH = AX % BL (Remainder)
    mov res_quot, al
    mov res_rem, ah

    ; Display Quotient
    lea dx, msg_div_q
    mov ah, 09h
    int 21h
    mov al, res_quot
    call print_two_digits

    ; Display Remainder
    lea dx, msg_div_r
    mov ah, 09h
    int 21h
    mov al, res_rem
    call print_two_digits

    ; -------------------------------------------------------------------------
    ; 8. Exit to DOS
    ; -------------------------------------------------------------------------
    mov ah, 4ch
    int 21h
main endp

; =============================================================================
; Procedure: print_two_digits
; Input:     AL = numeric value (0 - 99)
; Output:    Prints 2 decimal digits to standard output via INT 21H / AH=02H
; Registers: Modifies AX, BX, DX; restores BX via stack
; Mechanics: Divides AL by 10. Quotient is tens digit; remainder is units digit.
; =============================================================================
print_two_digits proc
    push bx
    push dx

    xor ah, ah                  ; Clear upper byte for clean 8-bit division
    mov bl, 10
    div bl                      ; AL = quotient (tens), AH = remainder (units)

    mov bx, ax                  ; Preserve quotient in BL, remainder in BH

    ; Print Tens Digit
    mov dl, bl
    add dl, '0'                 ; Convert to ASCII
    mov ah, 02h
    int 21h

    ; Print Units Digit
    mov dl, bh
    add dl, '0'                 ; Convert to ASCII
    mov ah, 02h
    int 21h

    pop dx
    pop bx
    ret
print_two_digits endp

end main
