.model small
.stack 100h
.data
    num1 db ?
    num2 db ?
    quot db ?
    rem db ?
    mult db ?

    msg1 db 'Enter first digit: $'
    msg2 db 0dh,0ah,'Enter second digit: $'
    msg_q db 0dh,0ah,'Quotient = $'
    msg_r db 0dh,0ah,'Remainder = $'
    msg_shr db 0dh,0ah,'After SHR: $'

.code
    main proc
        mov  ax, @data
        mov  ds, ax

        ; Prompt and read first digit
        mov  dx, offset msg1
        mov  ah, 09h
        int  21h

        mov  ah, 01h
        int  21h
        sub  al, 48
        mov  num1, al

        ; Prompt and read second digit
        mov  dx, offset msg2
        mov  ah, 09h
        int  21h

        mov  ah, 01h
        int  21h
        sub  al, 48
        mov  num2, al

        ; Divide second digit (num2) by first digit (num1)
        mov  al, num2
        mov  bl, num1
        mov  ah, 0
        div  bl
        mov  quot, al
        mov  rem, ah

        ; Print Quotient
        mov  dx, offset msg_q
        mov  ah, 09h
        int  21h

        add  quot, 48
        mov  ah, 02h
        mov  dl, quot
        int  21h

        ; Print Remainder
        mov  dx, offset msg_r
        mov  ah, 09h
        int  21h

        add  rem, 48
        mov  ah, 02h
        mov  dl, rem
        int  21h

        ; Multiply first and second digit
        mov  al, num1
        mov  bl, num2
        mul  bl

        ; Shift Right (SHR) operation on multiplication result
        shr  al, 1
        mov  bl, al ; Save result in BL for printing

        ; Print SHR message
        mov  dx, offset msg_shr
        mov  ah, 09h
        int  21h

        ; Print HIGH nibble (Hex format)
        mov  al, bl
        shr  al, 4
        call print_hex

        ; Print LOW nibble (Hex format)
        mov  al, bl
        and  al, 0Fh
        call print_hex

        ; Print 'H' suffix
        mov  dl, 'H'
        mov  ah, 02h
        int  21h

        ; Exit program
        mov  ah, 4Ch
        int  21h
    main endp

    ; -------------------------------
    ; Prints hex digit in AL (0–15)
    ; -------------------------------
    print_hex proc
        add al, 48
        cmp al, 57
        jbe out_label
        add al, 7
out_label:
        mov dl, al
        mov ah, 02h
        int 21h
        ret
    print_hex endp

    end main