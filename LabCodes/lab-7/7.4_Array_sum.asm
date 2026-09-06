.model small
.stack 100h

.data
    array db 1,2,3,4,5              ; db =  data byte

.code

main proc 
    
    mov ax, @data
    mov ds,  ax
    
    mov si, offset array             ; si = source index
    mov cx,5  
    mov bl, 0
    
    my_loop:
    mov ah, 2
    mov dl, [si]
    add bl, al
    inc si
    
    loop my_loop  
    
    mov dl, bl
    add dl, 48
    mov ah, 2
    int 21h                       
    ;int 21h
    
    ;mov dl, 32
    ;int 21h
    ;inc si
    
    exit:
    mov ah, 4ch
    int 21h
    
    main endp
end main