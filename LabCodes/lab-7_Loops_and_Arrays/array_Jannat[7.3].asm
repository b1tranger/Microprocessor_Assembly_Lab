.model small
.stack 100h 

.data
array db 1,2,3

.code
main proc
    
    mov ax,@data
    mov ds,ax
    mov si, offset array
    mov cx, 5
    
    level:
    mov ah,2h
    int 21h
    inc dl
    loop level
    
    exit:
    mov ah, 4ch
    int 21h
    
    main endp
end main
