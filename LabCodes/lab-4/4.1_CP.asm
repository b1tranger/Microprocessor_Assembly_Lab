.model small
.stack 100h

.data
    num1 db ?
    num2 db ?
    num3 db ?
    
    avg db ?
    doub db ?
    
    sum db ?
    quot db ?
    rem db ?   
    
        quot2 db ?
    rem2 db ?  
    
    msg1 db "Subject 1: $"
    msg2 db "Subject 2: $"
    msg3 db "Subject 3: $"
    msg4 db "Total Marks: $"
    msg5 db "Average Marks: $"
    

main proc
    mov ax, @data
    mov ds, ax 
    
    ; SUBJECT 1 
    
    mov dx, offset msg1
    mov ah, 09h
    int 21h
    
    mov ah, 1
    int 21h
    sub al, 48
    mov num1, al
    
    mov ah, 2
    mov dl, 10
    int 21h
    
        mov ah, 2
    mov dl, 13
    int 21h    
    
    ; SUBJECT 2 
    
        mov dx, offset msg2
    mov ah, 09h
    int 21h

    mov ah, 1
    int 21h
    sub al, 48
    mov num2, al
    
       mov ah, 2
    mov dl, 10
    int 21h
    
        mov ah, 2
    mov dl, 13
    int 21h
    
    ; SUBJECT 3  
    
        mov dx, offset msg3
    mov ah, 09h
    int 21h
    
        mov ah, 1
    int 21h
    sub al, 48
    mov num3, al
    
       mov ah, 2
    mov dl, 10
    int 21h
    
        mov ah, 2
    mov dl, 13
    int 21h
    
    
    ; TOTAL MARKS 
    
        mov dx, offset msg4
    mov ah, 09h
    int 21h
    
    mov al, num1
    add al, num2
    add al, num3  
    ; add al, 48
    mov sum, al
    
    mov ah, 2
    mov bl, sum
    add bl, 48
    mov dl, bl
    int 21h    
    
        
    mov ah, 2
    mov dl, 32
    int 21h  
    
    
    ; SHOWING DOUBLE DIGIT
    
     
    ; sub al, 48
    mov bh, 10 
    mov al, sum
    
    mov ah, 0 
    
    div bh
    add al, 48 ; quot
    add ah, 48 ; rem
    mov quot,al
    mov rem, ah
    
    mov ah, 2
    mov dl, quot
    int 21h 
    
    
    mov ah, 2
    mov dl, rem
    int 21h
    
     mov ah, 2
    mov dl, 10
    int 21h
    
        mov ah, 2
    mov dl, 13
    int 21h 
   
    
    
    ; AVERAGE MARKS
    
        mov dx, offset msg5
    mov ah, 09h
    int 21h
    
    
    ;sub al, 48
    mov bl, 3
    mov al, sum
     
    mov ah, 0  ; REMOVING GARBAGE VALUE
    
    div bl
    add al, 48 ; quot
    add ah, 48 ; rem
    mov quot2,al
    mov rem2, ah
    
    mov ah, 2
    mov dl, quot2
    int 21h
    
    mov ah, 2
    mov dl, 32
    int 21h 
    
    
     
    
    
    
    main endp
end main