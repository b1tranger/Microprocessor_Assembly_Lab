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
    mul num2 ; AL is automatically multiplied by num2
    add al, 48
    mov multi,al
    
    ; separating digits before output
    
    mov al, multi
    mov bl, 10
    div bl
    add al, 48
    add ah, 48
    mov quot,al
    mov rem,ah     
    
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
    
    

       main endp
end main