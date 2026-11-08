.model small
.stack 100h



.data 

    msg1 db 13,10,"input A : $"
    msg2 db  "input B : $"
    msg3 db 13,10, "$"
    
    var1 dw ?
    var2 dw ?



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
    mov var2, ax    ; input B
        
    mov ah, 09h
    lea dx, msg1 
    int 21h
    
    xor ah, ah 
    
    mov ah,01h
    int 21h
    mov var1, ax    ; input A  
    
    

       mov ah, 09h
    lea dx, msg3 
    int 21h  
             
 
    ; ##################################
    
    
    ; B row data in `var2`
    
    xor ah, ah
    xor cx, cx 
    
    mov ax, var2
    mov cx, ax  ; ERROR CHECK, maybe `cx` cannot be directly assigned
    mov bx, 1
    
    OuterLoop:
    
    push cx
    mov cx, bx
    
    InnerLoop:
    
    ;xor ah, ah
    mov ah, 02h
    mov dl, "$"
    int 21h
   

    
    Loop InnerLoop
    
       xor ah, ah 
    mov ah, 09h
    ;mov dl, msg3
    lea dx, msg3
    int 21h 
    
    inc bx
    pop cx
    
    loop OuterLoop
    
        
    
    
    ; ##################################
    mov ah, 4ch
    int 21h
    main endp
end main