.model
.stack 100h

.code
main proc
    
   
    
    
    mov dl, 'A'  
    
    

    
    level: 
     
     cmp dl,'S'
      je skip
    
    mov ah,2h
    int 21h 
    
    skip:
    inc dl
   cmp dl,'Z'
    jbe level
    
  
    
    exit:
    mov ah, 4ch
    int 21h
    
    main endp
end main