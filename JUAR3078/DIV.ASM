

	MODEL small		; Atminties modelis: 64K kodui ir 64K duomenims
	STACK 256
; ----- Konstantos ------------------------------------------------------------	
	
; ----- Duomenys (kintamieji) -------------------------------------------------
	DATASEG
as db 33
	CODESEG

Strt:
	mov ax,@data
	mov ds,ax
	xor dx, dx

        mov ax,99
        mov bx,30
        div [as]
        mov cl,ah
        
        mov ah,02h
        mov dl,al
        add dl,30h
        int 21h

        mov ah,02h
        mov dl,cl
        add dl,30h
        int 21h

        mov ax,4c00h
        int 21h 
end strt