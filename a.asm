	.MODEL SMALL

	.STACK 256h

	.DATA

	buf1		Dw 255 dup (?)

	buf2		Dw 255 dup (?)

	buf3		Dw 256 dup (0)

	ErrMsgOpen  	db  "Error opening$"
	rezerror  	db  "Error creating$"
	writeerror	db  "Error writing$"

	rezopenerror  	db  "Error opening result file $"

	tempbuf		Dw 30 dup (?)
	file1name	Dw 10 dup (?)
	file2name	Dw 10 dup (?)

	help	db  "help$"
	Sintakse	db  "neteisinga sintakse. pabandykite a.exe /? $"
	File3Name	db  "rez.txt",0

	desim		db 10h

	.CODE
START:

	mov cl,[ds:80h]
	xor ch,ch
	mov bx,cx
	or cx,cx
	je neteisinga

	mov ax,@data
	mov es,ax

	mov di, offset tempbuf
	mov si,81h
	xor ax,ax
kar:
	movsb
	dec cx
	jne kar

	mov ax,@data
	mov ds,ax


mov si, offset tempbuf
	lodsb
	cmp al,"/"
	jne vardu_formavimas

	lodsb
	cmp al,"?"
	jne vardu_formavimas

	mov dx, offset help
	mov ah,9h
	int 21h
	jmp koniec

vardu_formavimas:
	mov cx,bx
	mov si, offset tempbuf
	mov di, offset file1name
	xor ax,ax

pirmas_failas:
	lodsb
	dec cx
	cmp al,20h
	je vardo_pabaiga
	stosb
	or cx,cx
	je gerai
	jmp pirmas_failas


vardo_pabaiga:
	mov ax,0h
	stosb

	mov di, offset file2name
kitas_failas:
	lodsb
	dec cx
	cmp al,20h
	je gerai
	stosb
	or cx,cx
	jne kitas_failas

gerai:
	mov ax,0h
	stosb
	jmp vykdyti_proceduras

neteisinga:
	mov ax,@data
	mov ds,ax
	mov dx, offset sintakse
	mov ah,9h
	int 21h
	jmp koniec

vykdyti_proceduras:

	mov ax,@data
	mov ds,ax
	mov es,ax


	call open_file
	jc file_open_error

	call count
	jmp koniec

file_open_error:
	mov ah,09h
	mov dx,offset ErrMsgOpen
	int 21h
	jmp koniec

	
koniec:
	mov ax,4c00h
	int 21h

open_File PROC

;--------------1 failas --------------------------------
	mov ax,3d00h
	mov dx,offset File1Name
	int 21h
	jc @@end_file

	mov bx,ax

	mov dx, offset buf1
	mov ah,3fh
	mov cx,0FFFFh
	int 21h
	
	push ax

;---------------2failas-----------
	mov ax,3d00h
	mov dx,offset File2Name
	int 21h
	jc @@file2_error

	mov bx,ax

	mov dx, offset buf2
	mov ah,3fh
	mov cx,0FFFFh
	int 21h

	mov cx,ax

	mov ah,3eh
	int 21h

@@file2_error:
	xor ax,ax
	pop ax

@@end_file:

	mov bl,cl
	mov bh,al

	ret
open_file ENDP


;----------------------- count----------------------

count PROC
	xor cx,cx
	xor ax,ax
	xor dx,dx
	std

@@sudeti:
	cmp ch,1h
	je @@next1
	cmp ch,3h
	je @@galas

	mov si, offset buf1

	push bx
	mov bl,bh
	xor bh,bh
	add si, bx
	dec si
	pop bx
	dec bh


	lodsb
	or al,al
	je @@empty1
	aaa
	add al,dl
	daa
	mov dl,al
	jmp @@next1

@@empty1:
	add ch,1h

@@next1:
	cmp ch,2h
	je @@next2
	cmp ch,3h
	je @@galas

	mov si, offset buf2
	push bx
	xor bh,bh
	add si, bx
	dec si
	pop bx
	dec bl


	lodsb
	or al,al
	je @@empty2
	aaa
	add al,dl
	daa
	mov dl,al
	jmp @@next2

@@empty2:
	add ch,2h

@@next2:
	or dx,dx
	je @@galas
	mov al,dl
	div desim
	mov dl,ah
	add dl, 30h


	push dx
	inc cl

	xor dx,dx
	mov dl,al
	xor ax,ax
	jmp @@sudeti

@@galas:

	xor ch,ch
	mov bx,cx

	mov di,offset buf3
	cld

	cmp dl,1h
	jne @@nepliusvienas

	add dl,30h
	push dx
	inc cx
	inc bx

@@nepliusvienas:
	pop dx
	mov al,dl
	stosb
	dec cx
jne @@nepliusvienas
	mov al,"$"
	stosb
	inc bx

	mov ah, 9h
	mov dx,offset buf3
	int 21h

	ret
count ENDP

END START