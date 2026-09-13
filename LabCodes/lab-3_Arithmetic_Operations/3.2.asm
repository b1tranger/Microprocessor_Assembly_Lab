.model small
.stack 100h
     
.data
     num1 db ?
     num2 db ?
     ; sum db ?
     ; subt db ? 
     multi db ?
     divi db ?  
     
     quot db ? ; to be used for digit separation in MUL
     rem db ?
     
     
     
.code                  


 main proc
    mov ax, @data
    mov ds, ax
    
    mov ah, 1
    int 21h
    sub al, 48  ; subtracting to convert from ASCII to Number values for operation
    mov num1, al ; similar to storing to `bh`   

    ; ////////////////////   
    mov ah, 2
    mov dl, 32  
    int 21h  
    ; //////////////////// 
    
    mov ah, 1
    int 21h
    sub al, 48  ; subtracting to convert from ASCII to Number values for operation
    mov num2, al ; similar to storing to `bh`   

    ; ////////////////////   
    mov ah, 2
    mov dl, 32  
    int 21h  
    ; //////////////////// 
    
    ; OBSERVING THE CASE WHERE DOUBLE DIGITS NEED TO BE OUTPUT
    
    ; MUL    
    
    mov al, num1
    mul num2     ; AL is automatically multiplied by num2; result in AX (AL * num2)

   ; add al, 48
    mov multi, al ; FIX: Store RAW binary product (do NOT add 48 here before division)
    
    ; separating digits before output
    
    mov al, multi
    mov ah, 0    ; FIX: Clear AH to ensure AX contains strictly the 16-bit dividend (00:multi)
    mov bl, 10
    div bl       ; AX / 10 -> AL = Quotient (tens digit), AH = Remainder (units digit)
    add al, 48   ; Convert tens digit to ASCII character code ('0'-'9')
    add ah, 48   ; Convert units digit to ASCII character code ('0'-'9')
    mov quot, al
    mov rem, ah     
    
    mov ah, 2
    mov dl, quot  
    int 21h
    mov ah, 2
    mov dl, rem  
    int 21h
    
    
    ; ////////////////////   
    mov ah, 2
    mov dl, 32  
    int 21h  
    ; ////////////////////
    
    ; DOS program termination
    mov ah, 4Ch
    int 21h

   main endp
end main