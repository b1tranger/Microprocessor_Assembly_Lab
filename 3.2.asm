.model small
.stack 100h
     
.data
     num1 db ?
     num2 db ?
     ; sum db ?
     ; subt db ? 
     multi db ?
     divi db ?  
     
     quot db ?
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
    
    ; OBSERVING THE CASE WHERE DOUBLE DIGITS NEED TO BE OUTPUT
    
    ; MUL    
    
    mov al, num1
    mul num2 ; AL is automatically multiplied by num2
    add al, 48
    mov multi,al
    
    ; separating digits before output
    
     
    
    mov ah, 2
    mov dl, multi  
    int 21h
    
    
    ; ////////////////////   
    mov ah, 2
    mov dl, 32  
    int 21h  
    ; ////////////////////
    
    
    ; DIV      
         
    mov al, num1
    div num2
    add al, 48
    add ah, 48
    mov divi,al
    mov rem,ah 
    
    mov ah, 2
    mov dl, divi  
    int 21h
    
    
    ; ////////////////////   
    mov ah, 2
    mov dl, 32  
    int 21h  
    ; //////////////////// 
    
    mov ah, 2
    mov dl, rem  
    int 21h
    
    ; // ALT
    ; mov al, num1
    ; mov bl, num2
    ; div bl
    ; mov quot,al  
    ; mov rem,ah
    ; add quot, 30h  
    ; add rem, 30h


       main endp
end main