.model small
.stack 100h

.data
    msg1 db "Input: $"
    msg2 db 13,10,"Output : $"
    
    char db ?
    
.code

main proc     
    
    mov ax, @data
    mov ds,ax
    
    ; INPUT
    
    mov dx, offset msg1
    mov ah, 09h
    int 21h  
    
    mov ah, 01h
    int 21h
    ; sub al, 20h                   ; WILL BE ADD / SUM only after determining Capital / Small
    mov char, al 
     
     
    ; /////////
    ;mov ah, 02h  
    ;mov dl,10
    ;int 21h
    ;mov ah, 02h
    ;mov dl, 13
    ;int 21h
    ; /////////
    
    ; OUTPUT
    
    mov dx, offset msg2
    mov ah, 09h
    int 21h
      
    ; IF BLOCK (if Capital, make Small)
    
    mov al, char                    ; storing `char` value to AL to compare with 61h
    cmp al, 60h                     ; comparing with the character before 'a' (" ' ")
    jbe to_SMALL
    
    ; ELSE BLOCK (if Small, make Capital)
    
    sub al, 20h 
    
    jmp to_Output
    
    to_SMALL:
    add al, 20h
    
    
    to_Output: 
    
    mov char, al
    
    mov ah, 02h
    mov dl, char
    int 21h
    
    exit: 
    mov ah, 4ch
    int 21h      
     
    main endp  




end main  


   