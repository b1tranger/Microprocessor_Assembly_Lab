.MODEL SMALL
.STACK 100H

.DATA
    msg_n1      DB 'Enter N1: $'
    msg_n2      DB 13, 10, 'Enter N2: $'
    msg_n3      DB 13, 10, 'Enter N3: $'
    msg_largest DB 13, 10, 'Largest among N1, N2, N3: $'

    val_n1      DB ?
    val_n2      DB ?
    val_n3      DB ?
    max_val     DB ?

.CODE
    MAIN PROC
        MOV  AX, @DATA
        MOV  DS, AX

        ; Read N1
        LEA  DX, msg_n1
        MOV  AH, 09H
        INT  21H
        MOV  AH, 01H
        INT  21H
        SUB  AL, '0'
        MOV  val_n1, AL

        ; Read N2
        LEA  DX, msg_n2
        MOV  AH, 09H
        INT  21H
        MOV  AH, 01H
        INT  21H
        SUB  AL, '0'
        MOV  val_n2, AL

        ; Read N3
        LEA  DX, msg_n3
        MOV  AH, 09H
        INT  21H
        MOV  AH, 01H
        INT  21H
        SUB  AL, '0'
        MOV  val_n3, AL

        ; CRLF before pattern
        MOV  AH, 02H
        MOV  DL, 13
        INT  21H
        MOV  DL, 10
        INT  21H

        ; ------------------------------------------------------------------------
        ; NUMBER TRIANGLE PATTERN:
        ; Rows = val_n1
        ; In each row, print numbers: 1, 2, ..., currentRowNumber
        ; BX tracks current row limit (1 .. val_n1)
        ; ------------------------------------------------------------------------
        XOR  CX, CX
        MOV  CL, val_n1
        JCXZ SKIP_PATTERN

        MOV  BX, 1                   ; Current row upper limit (starts at 1)

ROW_LOOP:
        PUSH CX                     ; Save outer loop counter

        MOV  CX, BX                  ; Inner loop iterates BX times
        MOV  DH, 1                   ; DH tracks digit to print (starts at 1)

NUMBER_COL:
        ; Print current number in DH
        MOV  AH, 02H
        MOV  DL, DH
        ADD  DL, '0'                 ; Convert digit to ASCII
        INT  21H

        ; Print space after digit
        MOV  DL, ' '
        INT  21H

        INC  DH                      ; Next column number: 1 -> 2 -> 3...
        LOOP NUMBER_COL

        ; CRLF at end of row
        MOV  AH, 02H
        MOV  DL, 13
        INT  21H
        MOV  DL, 10
        INT  21H

        INC  BX                      ; Next row has one more number
        POP  CX                      ; Restore outer loop counter
        LOOP ROW_LOOP

SKIP_PATTERN:

        ; ------------------------------------------------------------------------
        ; FIND LARGEST AMONG THREE NUMBERS (N1, N2, N3):
        ; Algorithm:
        ;   AL = N1
        ;   if N2 > AL -> AL = N2
        ;   if N3 > AL -> AL = N3
        ;   max_val = AL
        ; ------------------------------------------------------------------------
        MOV  AL, val_n1              ; Assume N1 is initially largest
        CMP  AL, val_n2              ; Compare with N2
        JAE  CHECK_N3                ; If AL >= N2, AL is still largest
        MOV  AL, val_n2              ; Else, N2 is larger

CHECK_N3:
        CMP  AL, val_n3              ; Compare current max with N3
        JAE  STORE_MAX               ; If AL >= N3, AL is the absolute max
        MOV  AL, val_n3              ; Else, N3 is the absolute max

STORE_MAX:
        MOV  max_val, AL

        ; ------------------------------------------------------------------------
        ; Display Result
        ; ------------------------------------------------------------------------
        LEA  DX, msg_largest
        MOV  AH, 09H
        INT  21H

        MOV  DL, max_val
        ADD  DL, '0'
        MOV  AH, 02H
        INT  21H

        ; Exit
        MOV  AH, 4CH
        INT  21H

    MAIN ENDP
    END MAIN