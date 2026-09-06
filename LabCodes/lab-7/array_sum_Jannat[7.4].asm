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
    mov bl, 0
    
    my_loop:
    mov al,[si]
    add bl, al
    inc si
    
    loop my_loop
    
    mov dl, bl
    add dl, 48
    mov ah, 2
    int 21h
    
    
    exit:
    mov ah, 4ch
    int 21h
    main endp
end main
