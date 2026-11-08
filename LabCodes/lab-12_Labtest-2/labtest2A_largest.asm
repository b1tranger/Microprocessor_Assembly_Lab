.model small
.stack 100h



.data 

    msg1 db 13,10,"input A : $"
    msg2 db  "input B : $"
    msg3 db 13,10, "$"

    msg4 db 13,10, "C = $"
    msg5 db 13,10, "D = $"
    
    msg6 db 13,10, "C Largest$"
    msg7 db 13,10, "D Largest$" 
    
        msg8 db 13,10, "Largest between C and D$"
    
    var1 db ?
    var2 db ? 
    var3 db ?
    var4 db ?



.code 

main proc
    mov ax, @data
    mov ds, ax
    
    ; ##################################
    
     mov ah, 09h
    lea dx, msg2 
    int 21h
    
    xor ah, ah 
    
    mov ah,01h
    int 21h
        sub al, '0'
    mov var2, al    ; input B
       
    mov ah, 09h
    lea dx, msg1 
    int 21h
    
    xor ah, ah 
    
    mov ah,01h
    int 21h
    sub al, '0'
    mov var1, al    ; input A  
    
    

     
    
    ; ##################################
    
    
    xor ah, ah
    
    mov al, var2
    mov bl, al
    mov al, var1
    div bl
    
    mov var3, al    ; C
    mov var4, ah    ; D 
    
  
    
    xor ah,ah
    
    mov al, var3
    mov bl, var4
    cmp al, bl
    
    ja C_larger
    jb D_larger
    
    jmp Exit
    
    
    
    C_larger:
    
     mov ah, 09h
    lea dx, msg8 
    int 21h  
    
    jmp Exit    
    
    
    D_larger:
    
     mov ah, 09h
    lea dx, msg8 
    int 21h  
    
    jmp Exit    
    
    
    
        
    
    
    ; ##################################   
    
    Exit:
        
    mov ah, 4ch
    int 21h
    main endp
end main