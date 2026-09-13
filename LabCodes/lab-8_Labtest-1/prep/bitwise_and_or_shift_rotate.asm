; =============================================================================
; File: bitwise_and_or_shift_rotate.asm
; Directory: LabCodes/Labtest/prep/bitwise_and_or_shift_rotate.asm
; Description: Dedicated 8086 Assembly demonstration of Bitwise Logic & Shifting:
;              - AND (Bit Masking / Clearing)
;              - OR  (Bit Setting / Combining)
;              - XOR (Bit Inversion / Parity)
;              - SHL (Logical Shift Left - Multiply by 2^N via CL register)
;              - SHR (Logical Shift Right - Divide by 2^N via CL register)
;              - ROL (Rotate Left Circular)
;              - ROR (Rotate Right Circular)
;              - Formatted 8-bit Binary Output Subroutine (Print Binary)
; Target: MASM / TASM / EMU8086
; =============================================================================

.model small
.stack 100h

.data
    test_val        db 0C5h     ; Binary: 1100 0101b (Hex: C5h)
    
    banner          db '=== 8086 BITWISE LOGIC, SHIFT & ROTATE DEMO ===$'
    msg_orig        db 13, 10, 'Initial Value (C5h)      : $'
    msg_and         db 13, 10, 'AND with 0Fh (Mask Low)  : $'
    msg_or          db 13, 10, 'OR  with 30h (Set bits)  : $'
    msg_xor         db 13, 10, 'XOR with FFh (Bit Invert): $'
    msg_shl         db 13, 10, 'SHL by 2 bits (via CL)   : $'
    msg_shr         db 13, 10, 'SHR by 3 bits (via CL)   : $'
    msg_rol         db 13, 10, 'ROL by 1 bit             : $'
    msg_ror         db 13, 10, 'ROR by 2 bits (via CL)   : $'

.code
main proc
    ; -------------------------------------------------------------------------
    ; 1. Initialize Data Segment
    ; -------------------------------------------------------------------------
    mov ax, @data
    mov ds, ax

    lea dx, banner
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; 2. Print Initial Value (C5h -> 11000101b)
    ; -------------------------------------------------------------------------
    lea dx, msg_orig
    mov ah, 09h
    int 21h
    mov al, test_val
    call print_binary_8bit

    ; -------------------------------------------------------------------------
    ; 3. AND Operation (Masking out upper nibble: AL AND 0Fh)
    ;    11000101b AND 00001111b = 00000101b (05h)
    ; -------------------------------------------------------------------------
    lea dx, msg_and
    mov ah, 09h
    int 21h
    mov al, test_val
    and al, 0Fh
    call print_binary_8bit

    ; -------------------------------------------------------------------------
    ; 4. OR Operation (Forcing bits 4 and 5 high: AL OR 30h)
    ;    11000101b OR 00110000b = 11110101b (F5h)
    ; -------------------------------------------------------------------------
    lea dx, msg_or
    mov ah, 09h
    int 21h
    mov al, test_val
    or al, 30h
    call print_binary_8bit

    ; -------------------------------------------------------------------------
    ; 5. XOR Operation (Inverting all bits with mask FFh)
    ;    11000101b XOR 11111111b = 00111010b (3Ah)
    ; -------------------------------------------------------------------------
    lea dx, msg_xor
    mov ah, 09h
    int 21h
    mov al, test_val
    xor al, 0FFh
    call print_binary_8bit

    ; -------------------------------------------------------------------------
    ; 6. SHL Operation (Logical Shift Left by 2)
    ;    ARCHITECTURAL NOTE: In pure 8086 architecture, multi-bit shifts
    ;    (count > 1) MUST use the CL register! Direct immediate (SHL AL, 2)
    ;    was introduced only in 80186.
    ;    11000101b SHL 2 = 00010100b (14h), CF = 1
    ; -------------------------------------------------------------------------
    lea dx, msg_shl
    mov ah, 09h
    int 21h
    mov al, test_val
    mov cl, 2                   ; Load shift count into CL
    shl al, cl                  ; Hardware-compliant 8086 multi-bit shift
    call print_binary_8bit

    ; -------------------------------------------------------------------------
    ; 7. SHR Operation (Logical Shift Right by 3)
    ;    11000101b SHR 3 = 00011000b (18h), CF = 1
    ; -------------------------------------------------------------------------
    lea dx, msg_shr
    mov ah, 09h
    int 21h
    mov al, test_val
    mov cl, 3                   ; Load shift count into CL
    shr al, cl
    call print_binary_8bit

    ; -------------------------------------------------------------------------
    ; 8. ROL Operation (Rotate Left Circular by 1)
    ;    Single-bit rotation can use immediate 1 directly in 8086.
    ;    11000101b ROL 1 = 10001011b (8Bh)
    ; -------------------------------------------------------------------------
    lea dx, msg_rol
    mov ah, 09h
    int 21h
    mov al, test_val
    rol al, 1
    call print_binary_8bit

    ; -------------------------------------------------------------------------
    ; 9. ROR Operation (Rotate Right Circular by 2 via CL)
    ;    11000101b ROR 2 = 01110001b (71h)
    ; -------------------------------------------------------------------------
    lea dx, msg_ror
    mov ah, 09h
    int 21h
    mov al, test_val
    mov cl, 2
    ror al, cl
    call print_binary_8bit

    ; -------------------------------------------------------------------------
    ; Exit Program
    ; -------------------------------------------------------------------------
    mov ah, 4ch
    int 21h
main endp

; =============================================================================
; Procedure: print_binary_8bit
; Input:     AL = 8-bit value to display
; Output:    Prints formatted 8 binary digits (e.g. '11000101b') to console
; Mechanics: Iterates 8 times using CX. In each iteration, SHL AL, 1 pushes
;            the MSB into the Carry Flag (CF). Based on CF, prints '0' or '1'.
; =============================================================================
print_binary_8bit proc
    push ax
    push bx
    push cx
    push dx

    mov bl, al                  ; Preserve working value in BL
    mov cx, 8                   ; 8 bits to print

bin_loop:
    shl bl, 1                   ; Shift MSB into Carry Flag (CF)
    jc bit_is_one

    mov dl, '0'                 ; Carry was 0
    jmp emit_bit

bit_is_one:
    mov dl, '1'                 ; Carry was 1

emit_bit:
    mov ah, 02h
    int 21h

    ; Insert aesthetic space between nibbles (after 4th bit, CX=5)
    cmp cx, 5
    jne next_bit
    mov dl, ' '
    mov ah, 02h
    int 21h

next_bit:
    loop bin_loop

    ; Print trailing 'b'
    mov dl, 'b'
    mov ah, 02h
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_binary_8bit endp

end main
