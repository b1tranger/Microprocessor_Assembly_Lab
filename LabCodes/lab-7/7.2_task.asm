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
    
    cmp dl, 's'
    je skip
    mov ah, 2h 
    int 21h
    skip:
    inc dl                 ; increments 'a'; 'a' --> 'b' 
    ;skip:
    loop level
    
    exit:
    mov ah, 4ch
    int 21h
    
    main endp
end main