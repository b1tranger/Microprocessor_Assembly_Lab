.model small 
.stack 100h


.data      ;data segment
    a_input db 'Enter the value of A: $'
    b_input db 10, 13, 'Enter the value of B: $'
    c_input db 10, 13, 'Enter the value of C: $'


    a db 10, 13, ' A is largest!$'
    b db 10, 13, ' B is largest!$' 
    c db 10, 13, ' C is largest!$'
    s db 10, 13, ' is smallest!$'

    equal db 10, 13, ' Equal values!$'

    n1 db ?
    n2 db ? 
    n3 db ? 
    
    small db ?

.code
    main proc
        mov ax,@data  ;move the data segment in ax
        mov ds, ax

        mov ah, 9  
        lea dx, a_input
        int 21h
        mov ah, 1
        int 21h
        mov n1, al


        mov ah, 9
        lea dx, b_input
        int 21h
        mov ah, 1  
        int 21h      
        mov n2, al

        mov ah, 9
        lea dx, c_input
        int 21h
        mov ah, 1  
        int 21h       
        mov n3, al

        ;cmp bl, bh  ; compare  
        mov al, n1
        mov ah, n2
        cmp al, ah
        jg  a_is_big  ; if bl bigger than bh then jg flag on
        jl  b_is_big  ; if bh bigger than bl then jl flag on
        je  both_are_equal  ; if bl and bh both are equal then je

a_is_big:
        ; bl is big so print variable a 

        mov al, n1  
        mov ah, n3 

        cmp al, ah
        jg  a_is_big2  
        jl  c_is_big 
        je  both_are_equal2


b_is_big:

        mov al, n2  
        mov ah, n3 

        cmp al, ah 
        jg  b_is_big2  
        jl  c_is_big 
        je  both_are_equal

b_is_big2:
        mov ah, 9
        lea dx, b
        int 21h
        jmp exit 


both_are_equal:

        mov ah, 9
        lea dx, equal
        int 21h 
        jmp exit

a_is_big2:
        mov ah, 9
        lea dx, a
        int 21h
        jmp exit 

c_is_big:
        mov ah, 9
        lea dx, c
        int 21h
        jmp exit  

both_are_equal2:
        mov ah, 9
        lea dx, equal
        int 21h 

        jmp exit 


exit:
        mov ah, 4ch

    main endp
    end main