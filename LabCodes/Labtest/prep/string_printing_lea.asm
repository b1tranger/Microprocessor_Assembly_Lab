; =============================================================================
; File: string_printing_lea.asm
; Directory: LabCodes/Labtest/prep/string_printing_lea.asm
; Description: Dedicated 8086 Assembly demonstration of String Printing techniques:
;              1. LEA (Load Effective Address) vs MOV DX, OFFSET comparison.
;              2. Multi-line string printing using embedded CRLF (ASCII 13, 10).
;              3. Manual string printing loop via pointer traversal [SI] (AH=02H)
;                 terminating on null-byte (00h) without relying on '$'.
; Target: MASM / TASM / EMU8086
; =============================================================================

.model small
.stack 100h

.data
    ; Method 1 & 2: Standard DOS strings terminated with '$' (ASCII 24h)
    msg_title       db '=== 8086 STRING PRINTING DEMONSTRATION ===$', 0
    
    ; Multi-line string with embedded Carriage Return (13) and Line Feed (10)
    msg_lea_demo    db 13, 10, '[Approach 1: LEA + Embedded CRLF]'
                    db 13, 10, ' Line 1: Using LEA DX, label'
                    db 13, 10, ' Line 2: Multi-line emitted in a SINGLE INT 21H call!'
                    db 13, 10, ' Line 3: No repeated INT 21H (AH=02h) calls needed.$'

    msg_offset_demo db 13, 10, 13, 10, '[Approach 2: OFFSET Direct Assembler Immediate]'
                    db 13, 10, ' Loaded via: MOV DX, OFFSET msg_offset_demo$'

    ; Method 3: Null-terminated string (C-style, ends with 0 byte instead of '$')
    msg_null_term   db 13, 10, 13, 10, '[Approach 3: Pointer Loop Traversal (AH=02h)]'
                    db 13, 10, ' Traversed byte-by-byte using [SI] until 00h (Null).'
                    db 13, 10, ' No "$" sentinel required!', 0

    crlf            db 13, 10, '$'

.code
main proc
    ; -------------------------------------------------------------------------
    ; 1. Data Segment Initialization
    ; -------------------------------------------------------------------------
    mov ax, @data
    mov ds, ax

    ; -------------------------------------------------------------------------
    ; APPROACH 1: Using LEA DX, string (Load Effective Address)
    ; Advantages of LEA:
    ;   - Can compute dynamic addresses at runtime (e.g. LEA DX, [BX+SI+2]).
    ;   - Works transparently for both static offsets and complex addressing modes.
    ; -------------------------------------------------------------------------
    lea dx, msg_title
    mov ah, 09h                 ; DOS function: print '$'-terminated string
    int 21h

    lea dx, msg_lea_demo        ; Load effective address of multi-line block
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; APPROACH 2: Using MOV DX, OFFSET string
    ; Characteristics:
    ;   - Evaluated at compile/link time as an immediate 16-bit constant.
    ;   - Slightly faster on original 8086 hardware for purely static addresses.
    ; -------------------------------------------------------------------------
    mov dx, offset msg_offset_demo
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; APPROACH 3: Byte-by-byte traversal with Pointer SI (C-style Null String)
    ; Demonstrates:
    ;   - Register-indirect addressing [SI]
    ;   - Character output service INT 21H / AH=02H
    ;   - Independent from DOS '$' sentinel restriction
    ; -------------------------------------------------------------------------
    lea si, msg_null_term       ; Load base address into Source Index register

print_null_loop:
    mov dl, [si]                ; Fetch character at pointer [SI]
    cmp dl, 0                   ; Check for null-terminator (00h)
    je done_null_loop           ; If byte == 0, end of string

    mov ah, 02h                 ; DOS function: print single character in DL
    int 21h

    inc si                      ; Advance pointer to next byte
    jmp print_null_loop

done_null_loop:

    ; Trailing newline
    lea dx, crlf
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; Exit Program
    ; -------------------------------------------------------------------------
    mov ah, 4ch
    int 21h
main endp

end main
