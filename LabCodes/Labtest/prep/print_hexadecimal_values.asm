; =============================================================================
; File: print_hexadecimal_values.asm
; Directory: LabCodes/Labtest/prep/print_hexadecimal_values.asm
; Description: Dedicated 8086 Assembly demonstration of Hexadecimal Output:
;              - Subroutine print_hex_nibble: Converts 4-bit value to '0'-'9' / 'A'-'F'
;              - Subroutine print_hex_byte: Outputs 8-bit byte as 2 hex digits
;              - Subroutine print_hex_word: Outputs 16-bit word as 4 hex digits
;              - Complete stack preservation (PUSH/POP) for register hygiene
; Target: MASM / TASM / EMU8086
; =============================================================================

.model small
.stack 100h

.data
    val_byte1       db 0A5h     ; Test byte 1
    val_byte2       db 03Fh     ; Test byte 2
    val_byte3       db 0F0h     ; Test byte 3
    val_word1       dw 1A4Ch    ; Test 16-bit word

    banner          db '=== 8086 HEXADECIMAL VALUE PRINTING DEMO ===$'
    msg_byte1       db 13, 10, 'Byte 1 (0A5h) printed as Hex: 0x$'
    msg_byte2       db 13, 10, 'Byte 2 (03Fh) printed as Hex: 0x$'
    msg_byte3       db 13, 10, 'Byte 3 (0F0h) printed as Hex: 0x$'
    msg_word1       db 13, 10, 'Word 1 (1A4Ch) 16-bit Hex   : 0x$'
    msg_suffix      db 'h$'

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
    ; 2. Print Byte 1 (0A5h)
    ; -------------------------------------------------------------------------
    lea dx, msg_byte1
    mov ah, 09h
    int 21h

    mov al, val_byte1
    call print_hex_byte

    lea dx, msg_suffix
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; 3. Print Byte 2 (03Fh)
    ; -------------------------------------------------------------------------
    lea dx, msg_byte2
    mov ah, 09h
    int 21h

    mov al, val_byte2
    call print_hex_byte

    lea dx, msg_suffix
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; 4. Print Byte 3 (0F0h)
    ; -------------------------------------------------------------------------
    lea dx, msg_byte3
    mov ah, 09h
    int 21h

    mov al, val_byte3
    call print_hex_byte

    lea dx, msg_suffix
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; 5. Print 16-Bit Word (1A4Ch)
    ; -------------------------------------------------------------------------
    lea dx, msg_word1
    mov ah, 09h
    int 21h

    mov ax, val_word1
    call print_hex_word

    lea dx, msg_suffix
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; 6. Terminate Program
    ; -------------------------------------------------------------------------
    mov ah, 4ch
    int 21h
main endp

; =============================================================================
; Procedure: print_hex_word
; Input:     AX = 16-bit value to print
; Output:    Outputs 4 hex digits (e.g. "1A4C") to standard output
; Mechanics: Prints high byte (AH) first, then low byte (AL).
; =============================================================================
print_hex_word proc
    push ax
    push dx

    push ax                     ; Save full AX for low byte later
    mov al, ah                  ; Print upper 8 bits first
    call print_hex_byte
    pop ax                      ; Restore AX

    call print_hex_byte         ; Print lower 8 bits

    pop dx
    pop ax
    ret
print_hex_word endp

; =============================================================================
; Procedure: print_hex_byte
; Input:     AL = 8-bit value to print
; Output:    Outputs 2 hex characters (e.g. "A5") to standard output
; Mechanics: Isolates upper nibble (bits 7-4), prints it; then isolates lower
;            nibble (bits 3-0) and prints it.
; =============================================================================
print_hex_byte proc
    push ax
    push bx

    mov bl, al                  ; Preserve original value in BL

    ; 1. Process Upper Nibble (shift right 4 bits)
    mov al, bl
    mov cl, 4
    shr al, cl                  ; AL now contains upper nibble (0-15)
    call print_hex_nibble

    ; 2. Process Lower Nibble (mask with 0Fh)
    mov al, bl
    and al, 0Fh                 ; AL now contains lower nibble (0-15)
    call print_hex_nibble

    pop bx
    pop ax
    ret
print_hex_byte endp

; =============================================================================
; Procedure: print_hex_nibble
; Input:     AL = 4-bit value (0 - 15)
; Output:    Prints single ASCII character '0'-'9' or 'A'-'F' via INT 21H (AH=02H)
; Conversion Math:
;   If AL <= 9:  AL = AL + 48 ('0')             --> '0' through '9'
;   If AL >= 10: AL = AL + 48 + 7 = AL + 55     --> 'A' through 'F'
;                (e.g. 10 + 55 = 65 = 'A')
; =============================================================================
print_hex_nibble proc
    push ax
    push dx

    add al, '0'                 ; Add ASCII '0' (48 / 30h)
    cmp al, '9'                 ; Check if within digit range '0'-'9'
    jbe emit_nibble             ; If <= '9', ready to print

    add al, 7                   ; Skip 7 non-alphanumeric ASCII symbols (:;<=>?@)

emit_nibble:
    mov dl, al
    mov ah, 02h
    int 21h

    pop dx
    pop ax
    ret
print_hex_nibble endp

end main
