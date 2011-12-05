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

print_buf PROC FAR		;[ds:si]=>buferis, 16B; [ds:di]=>eilute, 78B
	mov Dest, di
	cmp Eilute2, 0FFFFh
	je virshyta
	inc Eilute2
	jmp eiluteend
virshyta:
	cmp Eilute1, 0FFFFh
	jne nevirshyta
	jmp klaida
nevirshyta:
	inc Eilute1
eiluteend:
	mov ax, Eilute1		;pirmi 2 skaitmenys
	mov al, ah
	and al, 0Fh
	shr ah, 4

	cmp ah, 0Ah
	jb dec1
	add ah, 7
dec1:
	add ah, 30h
dec1end:
	mov [ds:di], ah
	inc di
	cmp al, 0Ah
	jb dec2
	add al, 7
dec2:
	add al, 30h
dec2end:
	mov [ds:di], al
	inc di

	mov ax, Eilute1		;antri 2 skaitmenys
	mov ah, al
	and al, 0Fh
	shr ah, 4

	cmp ah, 0Ah
	jb dec3
	add ah, 7
dec3:
	add ah, 30h
dec3end:
	mov [ds:di], ah
	inc di
	cmp al, 0Ah
	jb dec4
	add al, 7
dec4:
	add al, 30h
dec4end:
	mov [ds:di], al
	inc di

	mov ax, Eilute2		;treti 2 skaitmenys
	mov al, ah
	and al, 0Fh
	shr ah, 4

	cmp ah, 0Ah
	jb dec5
	add ah, 7
dec5:
	add ah, 30h
dec5end:
	mov [ds:di], ah
	inc di
	cmp al, 0Ah
	jb dec6
	add al, 7
dec6:
	add al, 30h
dec6end:
	mov [ds:di], al
	inc di

	mov ax, Eilute2		;ketvirti 2 skaitmenys
	mov ah, al
	and al, 0Fh
	shr ah, 4

	cmp ah, 0Ah
	jb dec7
	add ah, 7
dec7:
	add ah, 30h
dec7end:
	mov [ds:di], ah
	inc di
	cmp al, 0Ah
	jb dec8
	add al, 7
dec8:
	add al, 30h
dec8end:
	mov [ds:di], al
	inc di

	mov [ds:di], byte ptr ':'
	inc di
	mov [ds:di], byte ptr ' '
	inc di

	mov cx, 0Fh
f_ciklas:
	mov al, [ds:si]
	mov ah, al
	and al, 0Fh
	shr ah, 4
	cmp ah, 0Ah
	jb dec9
	add ah, 7
dec9:
	add ah, 30h
dec9end:
	cmp al, 0Ah
	jb dec10
	add al, 7
dec10:
	add al, 30h
dec10end:
	mov bx, 0Fh
	sub bx, cx
	mov di, Dest
	add di, 0Ah
	cmp bx, 7
	jna norma1
	add di, 2
norma1:
	mov Tmp, bx
	shl bx, 1
	add bx, Tmp
	add di, bx
	mov [ds:di], ah
	inc di
	mov [ds:di], al
	mov al, [ds:si]
	cmp al, 32
	jnb range_ok
	mov al, 20h
range_ok:
	mov di, Dest
	mov bx, 0Fh
	sub bx, cx
	add di, 3Eh
	add di, bx
	mov [ds:di], al

	dec Dydis
	cmp Dydis, 0
	jne dydis_ok1
	jmp galas
dydis_ok1:

	inc si
	loop f_ciklas
	mov si, Dest
	call write
	ret
print_buf ENDP

; kintamieji
	msgLinija DB '================================================================================',0
	msgKlaida DB 'Klaida!',13,10,0
	msgAnyKey DB '                        *** Spauskite Klavisa ***',0
	msgNL DB 13,10,0
	masFailas DB 128 dup(?)
	masBuferis DB 16 dup(?)
	DTA DB 128 dup(?)
	Rankena DW ?
	Dydis DW ?
	Dest DW ?
	Tmp DW ?
	Ekranas DW ?
	Eilute1 DW 1 dup(0)
	Eilute2 DW 1 dup(0)
	masEilute DB '00000000: 00 00 00 00 00 00 00 00 | 00 00 00 00 00 00 00 00   0000000000000000',13,10,0
;'00000000: 53 57 9E C0 2F 3F 94 A0 ¦ 51 C1 A2 C6 29 AE 69 C5   SW×+/?öÂQ-óØ)«i+'	- viso 78B
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

	mov dx, offset DTA
	mov ah, 1AH
	int 21h 

	mov cx, 3Fh
	mov dx, bp
	mov ah, 4Eh
	int 21h

	jnc failas_yra
	jmp klaida
failas_yra:

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

	jc klaida

	dec Ekranas
	cmp ekranas, 0
	je anykey
pause:
	call print_buf
	jmp getbuf
anykey:
	mov bp, si
	mov si, offset msgNL
	call write
	mov si, offset msgAnyKey
	call write
	xor ah, ah
	int 16h
	mov Ekranas, 20
	jmp pause

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