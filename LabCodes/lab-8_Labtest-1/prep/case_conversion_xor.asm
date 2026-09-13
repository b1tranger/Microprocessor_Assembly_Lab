; =============================================================================
; File: case_conversion_xor.asm
; Directory: LabCodes/Labtest/prep/case_conversion_xor.asm
; Description: Dedicated 8086 Assembly demonstration of Bidirectional Case
;              Conversion and Toggling using bitwise XOR AL, 20h (bit 5 toggle).
;              Features:
;              1. Dynamic user character input with boundary validation ('A'-'Z', 'a'-'z').
;              2. Universal XOR toggling: uppercase <-> lowercase with one opcode.
;              3. Batch string in-place toggling demonstration using LEA and SI pointer.
; Target: MASM / TASM / EMU8086
; =============================================================================

.model small
.stack 100h

.data
    banner          db '=== 8086 CASE CONVERSION & XOR TOGGLING DEMO ===$'
    prompt_char     db 13, 10, 13, 10, 'Enter any character from keyboard: $'
    
    msg_orig        db 13, 10, 'Character read            : $'
    msg_type_upper  db 13, 10, 'Classification            : Uppercase Letter [A-Z]$'
    msg_type_lower  db 13, 10, 'Classification            : Lowercase Letter [a-z]$'
    msg_type_other  db 13, 10, 'Classification            : Non-alphabetic character (No toggle)$'
    msg_toggled     db 13, 10, 'Toggled Output via XOR 20h: $'

    ; Batch string demonstration
    msg_batch_head  db 13, 10, 13, 10, '--- BATCH STRING XOR TOGGLING DEMO ---$'
    msg_batch_pre   db 13, 10, 'Original String           : $'
    msg_batch_post  db 13, 10, 'In-Place Toggled String   : $'
    
    sample_str      db 'Microprocessor & Assembly Lab 8086!', '$'

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
    ; 2. Read Single Character Interactively
    ; -------------------------------------------------------------------------
    lea dx, prompt_char
    mov ah, 09h
    int 21h

    mov ah, 01h                 ; Read character with echo into AL
    int 21h
    mov bl, al                  ; Preserve original character in BL

    ; Echo original character
    lea dx, msg_orig
    mov ah, 09h
    int 21h
    mov dl, bl
    mov ah, 02h
    int 21h

    ; -------------------------------------------------------------------------
    ; 3. Alphabet Classification & Safe XOR Toggling
    ; -------------------------------------------------------------------------
    ; Check if within 'A' (41h) to 'Z' (5Ah)
    cmp bl, 'A'
    jb check_lower              ; Below 'A' -> check lowercase
    cmp bl, 'Z'
    jbe is_upper                ; Between 'A' and 'Z' -> uppercase

check_lower:
    ; Check if within 'a' (61h) to 'z' (7Ah)
    cmp bl, 'a'
    jb not_alpha
    cmp bl, 'z'
    jbe is_lower

not_alpha:
    ; Character is a digit, symbol, or control code
    lea dx, msg_type_other
    mov ah, 09h
    int 21h
    jmp run_batch_demo

is_upper:
    lea dx, msg_type_upper
    mov ah, 09h
    int 21h
    jmp perform_xor

is_lower:
    lea dx, msg_type_lower
    mov ah, 09h
    int 21h

perform_xor:
    ; -------------------------------------------------------------------------
    ; 4. Universal XOR Case Toggling:
    ;    ASCII 'A' = 0100 0001b (41h)
    ;    ASCII 'a' = 0110 0001b (61h)
    ;    Mask 20h  = 0010 0000b (32 decimal, bit 5)
    ;
    ;    'A' XOR 20h = 'a' (bit 5 changes 0 -> 1)
    ;    'a' XOR 20h = 'A' (bit 5 changes 1 -> 0)
    ;    A single instruction performs bidirectional conversion!
    ; -------------------------------------------------------------------------
    mov al, bl
    xor al, 20h                 ; Invert bit 5
    mov bh, al                  ; Preserve toggled result in BH

    lea dx, msg_toggled
    mov ah, 09h
    int 21h

    mov dl, bh
    mov ah, 02h
    int 21h

    ; -------------------------------------------------------------------------
    ; 5. Batch In-Place String Toggling Demonstration
    ;    Traverses a mixed-case string and toggles alphabetic characters in-place
    ; -------------------------------------------------------------------------
run_batch_demo:
    lea dx, msg_batch_head
    mov ah, 09h
    int 21h

    lea dx, msg_batch_pre
    mov ah, 09h
    int 21h

    lea dx, sample_str
    mov ah, 09h
    int 21h

    ; String traversal using Source Index (SI)
    lea si, sample_str

batch_loop:
    mov al, [si]
    cmp al, '$'                 ; End of string marker
    je batch_done

    ; Validate if letter is in 'A'-'Z'
    cmp al, 'A'
    jb check_batch_lower
    cmp al, 'Z'
    ja check_batch_lower
    xor al, 20h                 ; Convert Upper -> Lower
    mov [si], al
    jmp batch_next

check_batch_lower:
    ; Validate if letter is in 'a'-'z'
    cmp al, 'a'
    jb batch_next
    cmp al, 'z'
    ja batch_next
    xor al, 20h                 ; Convert Lower -> Upper
    mov [si], al

batch_next:
    inc si
    jmp batch_loop

batch_done:
    lea dx, msg_batch_post
    mov ah, 09h
    int 21h

    lea dx, sample_str
    mov ah, 09h
    int 21h

    ; -------------------------------------------------------------------------
    ; 6. Program Termination
    ; -------------------------------------------------------------------------
    mov ah, 4ch
    int 21h
main endp

end main
