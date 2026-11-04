.MODEL SMALL
.STACK 100H

.CODE
MAIN PROC

    MOV CX, 5        ; Number of rows

ROW_LOOP:
    PUSH CX          
    MOV CX, 5        ; Number of stars in each row

STAR_LOOP:
    MOV AH, 2
    MOV DL, '*'
    INT 21H

    LOOP STAR_LOOP   

    ; Print new line
    MOV AH, 2
    MOV DL, 13
    INT 21H

    MOV DL, 10
    INT 21H

    POP CX          
    LOOP ROW_LOOP   

    MOV AH, 4CH
    INT 21H

MAIN ENDP
END MAIN



