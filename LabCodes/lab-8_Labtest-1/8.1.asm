.model small
.stack 100h

.data
msg1 db "Input = $"
msg2 db "Converted Character = $"
msg3 db "Hex code after rotate left = $"

 
 char db ? 
 
 new_char db ?
 
 bin_char db ?
 
.code

main proc      
    mov ax, @data            ; loading .data values in data segment
    mov ds, ax
    
    ; Taking input
    
    mov dx,  offset msg1
    mov ah, 09h
    int 21h  
    
    mov ah,1
    int 21h
    mov char, al
    
    ; Output conversion
    
    
    
    mov ah, 2
    mov dl, 13
    int 21h
    mov ah, 2
    mov dl, 10
    int 21h 
    
    mov dx,  offset msg2
    mov ah, 09h
    int 21h 
    
    mov al, char
    xor al, 32               ; converts the 5th bit in binary [ cap <--> small ]
       
    mov new_char, al         ; storing conversion for next task
    
    mov ah, 2
    mov dl, al
    int 21h  
    
    
    mov al, 0
    
    ; ROL operation on conversion
      
      
       
    mov ah, 2
    mov dl, 13
    int 21h
    mov ah, 2
    mov dl, 10
    int 21h 
      
    mov dx,  offset msg3
    mov ah, 09h
    int 21h  
      
    mov al, new_char
    rol al, 1
    int 21h   
    
    mov ah, 2
    mov dl, al
    int 21h
    
    mov bin_char, al     ; storing rotated value
    
    mov al, 0
    
    ; HEX output
    
    ; output high nibble
    
    mov al, bin_char
    shr al, 4
    int 21h
   
   call print

    mov al, 0
      
     ; output low nibble
    
    mov al, bin_char
    and al, 0Fh
    int 21h
    
    call print
    
    mov al, 0
    
    out:
    mov ah,  4ch             ; code termination instruction
    int 21h
    
    main endp 

print proc
    cmp al, 57
    jbe print2
    
    add al, 7
    
    print2: 
    mov ah, 2
    mov dl, al
    int 21h
    
    ret
    
    print endp



end main