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
    
    ; INPUT
    
    mov dx, offset msg1
    mov ah, 09h
    int 21h  
    
    mov ah, 01h
    int 21h
    ; sub al, 20h                   ; WILL BE ADD / SUM only after determining Capital / Small
    mov char, al 
     
     
    ; /////////
    mov ah, 02h  
    mov dl,10
    int 21h
    mov ah, 02h
    mov dl, 13
    int 21h
    ; /////////
    
    ; OUTPUT
    
    mov dx, offset msg2
    mov ah, 09h
    int 21h
      
    ; IF BLOCK
    
    mov al, char                    ; storing `char` value to AL to compare with 61h
    cmp al, 61h
    ; jbe out 
    call to_SMALL
    
    ; ELSE BLOCK
    
    add al, 7 
    
    mov ah, 02h
    mov dl, char
    int 21h
    
    exit: 
    mov ah, 4ch
    int 21h      
     
    main endp  

    to_CAPITAL proc
        sub al, 20h    
        
        ret
    to_CAPITAL endp 
    
  
    to_SMALL proc  
        add al, 20h
        
        ret
    to_SMALL endp




end main  


   