; ============================================================
; Lab 6 Alternative: Case Conversion / Toggling via XOR Masking
; File: 6.1_CP-alt.asm
; Target Assembler: MASM / TASM / EMU8086
; Description:
;   Reads a character from keyboard input, toggles its case 
;   between lowercase and uppercase using a bitwise XOR with 32 
;   (20h / 00100000b), and outputs the resulting character.
; Key Concepts Demonstrated:
;   1. String definition with embedded CRLF: DB 13, 10, '...'
;   2. Dynamic effective address loading: LEA DX, label
;   3. ASCII bit 5 toggling using XOR AL, 32 (bidirectional)
; ============================================================

.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 'Input: $'
    MSG2 DB 13, 10, 'Output: $'      ; Embedded CR (13) and LF (10) for automated newline

.CODE
MAIN PROC
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ; ------------------------------------------------------------
    ; 1. Display Input Prompt
    ; ------------------------------------------------------------
    ; LEA (Load Effective Address) computes the offset of MSG1
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H

    ; ------------------------------------------------------------
    ; 2. Read Single Character from Keyboard
    ; ------------------------------------------------------------
    ; INT 21H / AH=01H echoes character and stores ASCII code in AL
    MOV AH, 01H
    INT 21H

    ; ------------------------------------------------------------
    ; 3. Bitwise XOR Case Toggling (Bit 5 Inversion)
    ; ------------------------------------------------------------
    ; Decimal 32 = 20h = 0010 0000b
    ; Toggling Bit 5:
    ;   'a' (0110 0001b) XOR 0010 0000b = 'A' (0100 0001b) [Lower -> Upper]
    ;   'A' (0100 0001b) XOR 0010 0000b = 'a' (0110 0001b) [Upper -> Lower]
    XOR AL, 32

    ; ------------------------------------------------------------
    ; 4. Preserve Converted Character
    ; ------------------------------------------------------------
    ; Save toggled character in BL before setting up string display
    MOV BL, AL

    ; ------------------------------------------------------------
    ; 5. Display Output Message with Embedded Newline
    ; ------------------------------------------------------------
    ; MSG2 contains 13 (CR) and 10 (LF) at start, automatically moving
    ; cursor to the start of the next line before printing "Output: "
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H

    ; ------------------------------------------------------------
    ; 6. Display Converted Character
    ; ------------------------------------------------------------
    MOV DL, BL
    MOV AH, 02H
    INT 21H

    ; ------------------------------------------------------------
    ; 7. Terminate Program Gracefully
    ; ------------------------------------------------------------
    MOV AH, 4CH
    INT 21H

MAIN ENDP
END MAIN
