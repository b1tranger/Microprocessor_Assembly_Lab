.model small
.stack 100h
.data
    num1 db 018h 
    num2 db 02Ah
    num3 db 0C4h
    num4 db 06Bh
    num5 db 0FFh
    num6 db 07Ah
    
    msg1 db "num1 : $"  
    msg2 db "num2 : $"  
    msg3 db "num3 : $"  
    msg4 db "num4 : $"  
    msg5 db "num5 : $"  
    msg6 db "num6 : $"  
 
.code   
    main proc 
        mov ax, @data
        mov ds, ax  
        
        ;NUM 1 | AND op 
        
        mov dx, offset msg1
        mov ah, 09h
        int 21h
        
        mov al, num1
        and al, 0Fh
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
         
        ;NUM 2 | OR op 
        
        mov dx, offset msg2
        mov ah, 09h
        int 21h
        
        mov al, num2
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
         
        ;NUM 3 | SHL op 
        
        mov dx, offset msg3
        mov ah, 09h
        int 21h
        
        mov al, num3
        shl al, 3
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
        
        ;NUM 4 | SHR op 
        
        mov dx, offset msg4
        mov ah, 09h
        int 21h
        
        mov al, num4
        shr al, 6
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
        
        ;NUM 5 | ROL op 
        
        mov dx, offset msg5
        mov ah, 09h
        int 21h
        
        mov al, num5
        rol al, 2
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
        
        ;NUM 6 | ROR op 
        
        mov dx, offset msg6
        mov ah, 09h
        int 21h
        
        mov al, num6
        ror al, 7
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
        mov ah, 02h  ; previously set al, causing unwanted output
        int 21h
        ret
        
    print_hex endp    
    
                    end main