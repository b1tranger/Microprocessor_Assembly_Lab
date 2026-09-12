.model small
.stack 100h
        
.data       ; DATA SEGMENT
     var1 db 'Input:$' 
     var2 db 'Output:$' 
        
.code

main proc
         
    mov ax, @data
    mov ds,ax    
      
    ; PRINT "INPUT"
      
    mov dx, offset var1  
    mov ah, 09h 
    int 21h  
            
    ; PRINT NEW LINE 
        
    mov ah, 2
    mov dl, 10
    int 21h

    ; CARRY BACK
        
    mov ah, 2
    mov dl, 13
    int 21h 
            
    ; INPUT 5
    
    mov ah, 1     
    int 21h
    mov bl, al 
    
    ; PRINT NEW LINE 
        
    mov ah, 2
    mov dl, 10
    int 21h

    ; CARRY BACK
        
    mov ah, 2
    mov dl, 13
    int 21h
    
    ; INPUT 3
    
    mov ah, 1
    int 21h
    mov bh, al 
    
    ; PRINT NEW LINE 
        
    mov ah, 2
    mov dl, 10
    int 21h 
    
        
    ; PRINT NEW LINE 
        
    mov ah, 2
    mov dl, 10
    int 21h

    ; CARRY BACK
        
    mov ah, 2
    mov dl, 13
    int 21h     
    
    ; PRINT "OUTPUT"
    
    mov dx, offset var2  
    mov ah, 09h 
    int 21h 
 
    ; PRINT NEW LINE 
        
    mov ah, 2
    mov dl, 10
    int 21h

    ; CARRY BACK
        
    mov ah, 2
    mov dl, 13
    int 21h  
    
    ; OUTPUT  5
    
    mov ah,2
    mov dl, bl
    int 21h 
    
    
    ; PRINT NEW LINE 
        
    mov ah, 2
    mov dl, 10
    int 21h

    ; CARRY BACK
        
    mov ah, 2
    mov dl, 13
    int 21h  
    
    ; OUTPUT  3
    
    mov ah,2
    mov dl, bh
    int 21h  
    
   
       
    
    exit:
    mov ah,4ch
    int 21h
    main endp
end main