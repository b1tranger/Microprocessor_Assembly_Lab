.model small
.stack 100h

.code

main proc
    
    mov ah, 1
    int 21h
    mov bl,al      
    
    ; PRINTING SPACE
    
    mov ah,2
    mov dl, 32 ; printing a space 
    int 21h
     mov ah,2
    mov dl, 32 ; printing a space  
    int 21h
     mov ah,2
    mov dl, 32 ; printing a space
    int 21h
     mov ah,2
    mov dl, 32 ; printing a space   
    int 21h 
    
    ; PRINTING NEW LINE 
    
    mov ah, 2
    mov dl, 10 
    int 21h
    
    mov ah, 2
    mov dl, 13
    int 21h
    
    mov ah,2
    int 21h
    mov dl,bl
    int 21h
    
    
    exit:
    mov ah,4ch
    int 21h
    main endp
end main