.model small
.stack 100h

.data

.code

main proc 
    
    mov ax, @data
    mov ds,  ax
    
    mov cx, 26
    mov dl, 'a'
    
    level:
    mov ah, 2h 
    int 21h 
    inc dl                 ; increments 'a'; 'a' --> 'b'
    loop level
    
    exit:
    mov ah, 4ch
    int 21h
    
    main endp
end main