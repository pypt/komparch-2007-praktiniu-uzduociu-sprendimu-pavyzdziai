.model tiny
.code
org 100h

start:
	xor cx, cx
	mov si, offset varInputas

read:	mov ah, 00h
	int 16h
	mov [ds:si], byte ptr al
	inc si
	inc cx
	cmp cx, 0Fh
	jb read

	mov [ds:si], byte ptr '$'
	mov dx, offset varInputas
	mov ah, 09h
	int 21h

	mov ah, 4Ch
	int 21h

	varInputas DB 10h

end start