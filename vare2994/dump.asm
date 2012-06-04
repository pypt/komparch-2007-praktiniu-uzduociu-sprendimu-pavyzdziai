; Laurynas Litvinas, Informatika IIk, 5gr.
; lauris0144@hotmail.com

.model tiny
.code
org 100h

;programos pradzia

start:


	jmp endproc
;===================== proceduros/kintamieji
write PROC FAR		;[ds:si]=>ASCIIZ string, limitas 128
	mov ah, 2
	xor cl, cl
charout:
	mov dl, byte ptr [ds:si]
	inc si
	cmp dl, 0
	je endcharout
	int 21h
	inc cl
	cmp cl, 128
	jne charout
endcharout:
	ret
write ENDP

; kintamieji
	msgLinija DB '================================================================================',0
	msgKlaida DB 'Klaida!',13,10,0
	msgAnyKey DB '                        *** Spauskite Klavisa ***',0
	msgNL DB 13,10,0
	masFailas DB 128 dup(?)
	masBuferis DB 17 dup(?)
	DTA DB 128 dup(?)
	Rankena DW ?
	Dydis DW ?
	Ekranas DW ?
;===================== proceduros/kintamieji galas
endproc:
	mov bp, offset masFailas
	mov sp,	offset masBuferis
	mov al, [es:80h]
	cmp al, 0
	jne param
	jmp noparam
param:
	mov si, 80h
	mov di, bp
	mov ax, [es:si]
	mov [ds:di], ax
	inc si
	inc si
	inc di
	inc di
ciklas:
	mov al, [es:si]
	cmp al, 0Dh
	jne negalas
	jmp endparam
negalas:
	mov [ds:di], al
	inc si
	inc di
	jmp ciklas
noparam:
	mov di, bp
	mov [ds:di], byte ptr 80h
	mov dx, di
	mov ah, 0Ah
	int 21h
	inc di
	xor ax, ax
	add al, byte ptr [ds:di]
	add di, ax
	inc di
	mov [ds:di], byte ptr 0
endparam:
	inc bp
	inc bp		;bp => ASCIZ string
; parametrai gauti

	mov dx, offset DTA 	; DS:DX points to DTA 
	mov ah, 1AH 		; function 1Ah - set DTA
	int 21h 		; call DOS service

	mov cx, 3Fh 		; attribute mask - all files
	mov dx, bp		; DS:DX points ASCIZ filename
	mov ah, 4Eh 		; function 4Eh - find first
	int 21h 		; call DOS service

	;jc klaida

	mov bp, offset DTA + 26
	mov ax, word ptr [ds:bp]
	mov Dydis, ax
	inc bp
	inc bp
	mov ax, word ptr [ds:bp]
	cmp ax, 0
	je dydis_ok
	jmp klaida
dydis_ok:
	inc bp
	inc bp

; ishvedimas
	mov Ekranas, 20

	mov dx, bp
	mov al, 0
	mov ah, 3Dh
	int 21h

	mov Rankena, ax
	jnc getbuf
	jmp klaida
getbuf: 
	mov si, sp
	mov dx, sp
	mov bx, Rankena
	mov cx, 16
	mov ah, 3Fh
	int 21h

	jnc print
	jmp klaida
print:
	mov dl, [ds:si]
	inc si
	cmp dl, 0
	je getbuf
	mov ah, 2
	int 21h
	dec Dydis
	cmp Dydis, 0
	je galas
	cmp dl, 10
	jne print
	dec Ekranas
	cmp ekranas, 0
	je anykey
	jmp print
anykey:
	mov bp, si
	mov si, offset msgNL
	call write
	mov si, offset msgAnyKey
	call write
	xor ah, ah
	int 16h
	mov Ekranas, 20
	jmp print

galas:
	mov bx, Rankena
	mov ah, 3Eh
	int 21h

	mov ah, 4Ch
	int 21h
klaida:
	mov si, offset msgLinija
	call write
	mov si, offset msgKlaida
	call write
	mov si, offset msgLinija
	call write
	jmp galas
end start