.MODEL small

	CR = 0Dh
	LF = 0Ah

.STACK 256
.DATA
	
indigit	DB 17
	DB 0
	DB 18 DUP(?)

du db 2h

.CODE
strt:
mov cl,[ds:80h]
mov dx,81h

mov si,dx

call printbuf

mov ax,4c00h
int 21h

printbuf PROC

@@repeat:

	or cl,cl
	je @@exit

	dec cl
	lodsb
	or al,al
	jz @@exit

	mov dl,al
	mov ah,2h
	int 21h

	xor ax,ax
	jmp short @@repeat
@@exit:
	ret
	printbuf ENDP


END strt