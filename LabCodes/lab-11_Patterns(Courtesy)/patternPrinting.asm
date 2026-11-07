.MODEL SMALL
.STACK 100H



.CODE
MAIN PROC
    

    MOV CX,10          ; number of rows
    MOV BX, 1          ; stars in first row

ROW_LOOP:
    PUSH CX            ; save outer loop counter
    MOV CX, BX         ; number of stars to print

STAR_LOOP:
    MOV AH, 2
    MOV DL, '*'
    INT 21H
    LOOP STAR_LOOP

    ; print new line
    MOV AH, 2
    MOV DL, 13
    INT 21H

    MOV DL, 10
    INT 21H

    INC BX             ; next row will have one more star
    POP CX             ; restore outer loop counter
    LOOP ROW_LOOP

    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN