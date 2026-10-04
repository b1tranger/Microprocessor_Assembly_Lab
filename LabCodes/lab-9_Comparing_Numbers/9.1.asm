.model small 
.stack 100h


.data      ;data segment
a_input db 'Enter the value of A: $'
b_input db 'Enter the value of B: $'


a db ' A is bigger than B!$'
b db ' B is bigger than A!$'
c db ' Both A and B is equal!$'


.code
    main proc
mov ax,@data  ;move the data segment in ax
mov ds, ax

mov ah, 9  ; print  
lea dx, a_input
int 21h

mov ah, 1
int 21h
mov bl, al

mov ah, 2
mov dl, 10
int 21h

mov dl, 13
int 21h

mov ah, 9
lea dx, b_input



int 21h
mov ah, 1  ; take input in bh
int 21h
mov bh, al
mov ah, 2  ; line break
mov dl, 10
int 21h
mov dl, 13
int 21h 


cmp bl, bh  ; compare
jg a_is_big  ; if bl bigger than bh then jg flag on
jl b_is_big  ; if bh bigger than bl then jl flag on
je both_are_equal  ; if bl and bh both are equal then je

a_is_big:  ; bl is big so print variable a
mov ah, 9
lea dx, a
int 21h
jmp exit

b_is_big:  ; bh is big so print variable b
mov ah, 9
lea dx, b
int 21h
jmp exit
   
both_are_equal:  ; both are equal so print variable c

mov ah, 9
lea dx, c
int 21h

exit:
mov ah, 4ch

main endp
    end main














