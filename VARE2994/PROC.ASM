; this a procedure to print a block on the screen using memory
; to pass parameters (cursor position of where to print it and
; colour).

.model tiny 
.code
org 100h

Start: 

mov Row,1 	; row to print character
mov Col,20 	; column to print character on
mov Char,'H' 	; ascii value of block to display
mov Colour,00F0h 	; colour to display character (00BF, B - background, F - foreground)

call PrintChar 	; print our character
mov ax,4C00h 	; terminate program 
int 21h

PrintChar PROC NEAR

push ax cx bx 	; save registers to be destroyed

xor bh,bh 	; clear bh - video page 0
mov ah,2 	; function 2 - move cursor
mov dh,Row
mov dl,Col
int 10h 	; call Bios service 

mov al,Char 
mov bl,Colour
xor bh,bh 	; display page - 0
mov ah,9 	; function 09h write char & attrib 
mov cx,1 	; display it once
int 10h 	; call bios service

pop bx cx ax 	; restore registers

ret 		; return to where it was called
PrintChar ENDP

; variables to store data

Row db 		? 
Col db 		?
Colour db 	?
Char db 	?

end Start