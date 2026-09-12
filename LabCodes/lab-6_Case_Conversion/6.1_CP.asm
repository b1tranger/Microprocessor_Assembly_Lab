.model small
.stack 100h

.data
    msg1 db "Input: $"
    msg2 db "Output : $"
    
    char db ?
    
.code

main proc     
    
    mov ax, @data
    mov ds,ax
    
    
    mov dx, offset msg1
    mov ah, 09h
    int 21h  
    
    mov ah, 01h
    int 21h
   ; mov bl, al
    sub al, 20h
    ;int 21h
    mov char, al 
    ;int 21h
    
    mov ah, 02h  
    mov dl,10
    int 21h
    mov ah, 02h
    mov dl, 13
    int 21h
    
    mov dx, offset msg2
    mov ah, 09h
    int 21h 
    
    mov ah, 02h
    mov dl, char
    int 21h
    
    exit: 
    mov ah, 4ch
    int 21h      
     
    main endp
end main