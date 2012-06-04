.model small
.Stack 256
	cr = 0Dh
	lf = 0Ah

.data
	msg db "Iveskite desimtaini sakiciu nuo 0 iki 65535: $"
	ats db cr,lf,"Jusu ivestas skaicius dvejatainiu pavidalu yra: $"
	inbuf db 255
	      db 0
	      db 255 dup (?)
.code
start:
	mov ax, @data
	mov ds, ax

	mov ah, 09h
	mov dx, offset msg
	int 21h

	mov ah, 0Ah
	mov dx, offset inbuf
	int 21h

	mov ah, 09h
	mov dx, offset ats
	int 21h

	mov cl, [inbuf + 1] 
	mov si, offset inbuf + 2
	xor bx, bx
	xor ah, ah
	push si
	push dx
	xor dx,dx
	cld
repeat:
	lodsb
	xor ah,ah
	cmp al,0Dh	
	je exit
	cmp al,"0"
	jb exit
	cmp al,"9"
	ja exit

	sub al,30h
	add ax,dx
	cmp cl,01h
	jne daug
	jmp nedaug
daug:
	mov bx,000Ah
	mul bx
nedaug:
	mov dx,ax
	dec cl
	jmp repeat
	
Exit:
	mov bx,dx
;------------------------Isvedimas------------------------------
	push bx
	mov ah,02h
	xor cx,cx
	mov cl,0Fh		
	xor dx,dx
ciklas:		
	test bx,8000h
	jz nul
	jmp nenul
nul:
	mov dl,30h
	int 21h
	jmp nesp
nenul:
	mov dl,31h
	int 21h
nesp:
	inc ch
	cmp ch,04h
	je tarp
	cmp ch,08h
	je tarp
	cmp ch,0Ch
	je tarp
	jmp skip
tarp:
	mov dl,20h
	int 21h
skip:
	shl bx,01h
	cmp cl,00h
	je  lauk
loop ciklas
lauk:
	pop bx
	pop dx
	pop si	

	mov ax,4C00h
	int 21h

end start