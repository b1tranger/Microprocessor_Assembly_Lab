.model small
.stack 100h

.code

maion proc
    
    mov ah, 1
    int 21h
    mov bl,al
    
    
    exit:
    mov 4ch
    int 21h
    main endp
end main