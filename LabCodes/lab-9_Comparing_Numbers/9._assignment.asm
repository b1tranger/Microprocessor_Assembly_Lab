; ASSIGNMENT USING 3 NUMBERS



.model small 
.stack 100h


.data      ;data segment
a_input db 'Enter the value of A: $'
b_input db 'Enter the value of B: $'
c_input db 'Enter the value of C: $'


largest db ?
l_out db ' is largest$'
middle db ?            
m_out db ' is middle$'
smallest db ?          
s_out db ' is smallest$'


num1 db ?
num2 db ?
num3 db ?

temp db ?


.code
    main proc
mov ax,@data  ;move the data segment in ax
mov ds, ax

mov ah, 9   
lea dx, a_input
int 21h

mov ah, 1
int 21h
mov num1, al
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
mov num2, al
mov ah, 2  ; line break
mov dl, 10
int 21h
mov dl, 13
int 21h  

mov ah, 9
lea dx, c_input
int 21h 

mov ah, 1  ; take input in bh
int 21h
mov num3, al
mov ah, 2  ; line break
mov dl, 10
int 21h
mov dl, 13
int 21h 

; ///////////////////////////////////////

mov al, num1
mov ah, num2

cmp al, ah  ; compare
jg 1_is_big  ; if bl(num1) bigger than bh(num2) then jg flag on
jl 2_is_big  ; if bh bigger than bl then jl flag on
je both_are_equal  ; if bl and bh both are equal then je


; ///////////////////////////////////////

1_is_big:  ; bl is big so print variable a
;mov ah, 9
;lea dx, a
;int 21h
;jmp exit

mov al, num1
mov ah, num3

cmp al, ah
jg 1_is_big_again 
jl 3_is_big 
je both_are_equal  


1_is_big_again:
mov al, num1
mov largest, al
  
mov ah, 9
lea dx, largest
int 21h

mov ah, 9
lea dx, l_out
int 21h     

mov ah, 2
mov dl, 10
int 21h
mov dl, 13
int 21h

; ///////////////////////////////////////

2_is_big:  ; bh is big so print variable b
mov ah, 9
;lea dx, b
int 21h
;jmp exit


; ///////////////////////////////////////
  
both_are_equal:  ; both are equal so print variable c

mov ah, 9
;lea dx, c
int 21h  

; ///////////////////////////////////////

exit:
mov ah, 4ch

main endp
    end main














