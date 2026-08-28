.model small
.stack 100h
.data
    num1 db 018h
    
    msg1 db "num1 : $"  
 
.code   
    main proc 
        mov ax, @data
        mov ds, ax  
        
        ;NUM 1 | AND op 
        
        mov dx, offset msg1
        mov ah, 09h
        int 21h
        
        mov al, num1
        or al, 0D1h
        mov bl, al  
                
        ; PRINT
        
        mov al, bl 
        shr al, 4
        call print_hex
        
        mov al, bl
        and al, 0Fh
        call print_hex
        
        mov ah, 4Ch
        int 21h
  
        main endp
     
    
    
    print_hex proc
        add al, 48
        cmp al, 57
        jbe out
        add al, 7
        
       out:
        mov dl, al
        mov ah, 02h 
        int 21h
        ret
        
    print_hex endp    
    
   end main