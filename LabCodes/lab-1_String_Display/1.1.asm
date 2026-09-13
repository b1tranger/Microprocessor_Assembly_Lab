; ###############  Header Section  ###############


.model small
.stack 100h ; allocating 100 slots in Hex value


; ###############  Data Section  ###############

.data
    myname db 'my name is Gaus$' ; $ indicates string end


; ###############  Code Section  ###############

.code
    

main proc

    mov ax, @data                   ; source @data goes into ax (destination)
    mov ds,ax
    
    mov dx, offset myname           ; calling the index pointer of myname
    mov ah, 09h                     ; output instruction
    int 21h                         ; interrupt / executing the previous instruction


; ###############  Exit Section  ###############    


exit:                               ; to indicate exit sequence we need to create an "exit level"
  
    mov ah, 4ch                     ; terminate instruction
    int 21h
    
    main endp
end main
    
    