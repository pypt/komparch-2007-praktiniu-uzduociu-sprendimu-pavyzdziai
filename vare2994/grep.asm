; Laurynas Litvinas, Informatika IIk, 5gr.
; lauris0144@hotmail.com

.model tiny
.code
org 100h

;programos pradzia

start:


	jmp endproc
;===================== proceduros/kintamieji
writeln PROC FAR		;[ds:si]=>ASCIIZ string, limitas 128
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
	mov dl, 13
	int 21h
	mov dl, 10
	int 21h
	ret
writeln ENDP

klaida PROC FAR
	mov si, OFFSET msgLinija
	call writeln
	mov ah, 4ch     
	int 21h
klaida ENDP

; kintamieji
	msgLinija DB '================================================================================',0
	msgParam DB 'Parametras yra',0
	msgNoParam DB 'Parametro nera',0
	varFlagai DB 0
	varStringas DB 128 dup(0)
	varFailas DB 128 dup(0)
	varBuferis DB 128 dup(0)

;===================== proceduros/kintamieji galas
endproc:

	mov al, byte ptr [es:80h]	;kaip atrodo komandine eilute?
	cmp al, 0
	je noparam_trans	
param:
	mov varFlagai, 0
	mov si, 82h
	mov di, offset varStringas
	cmp al, 2
	jne ciki1
	mov al, byte ptr [es:si]
	mov [ds:di], al
	jmp endparam
ciki1:
	mov ax, word ptr [es:si]
	inc si
	inc si
	cmp ax, 6E2Dh			;'-n'?	(1)
	jne skip1
	or varFlagai, 1
	inc si
	jmp ciklas1
skip1:
	mov [ds:di], ax
	inc di
	inc di
ciklas1:
	mov al, byte ptr [es:si]
	inc si
	cmp al, 20h
	je endciklas1
	cmp al, 0Dh
	je noparam
	mov [ds:di], al
	inc di
	jmp ciklas1
endciklas1:
	mov di, offset varFailas
	mov ax, word ptr [es:si]
	inc si
	inc si
	cmp ax, 6E2Dh			;'-n'?	(2)
	jne skip2
	or varFlagai, 1
	inc si
	jmp ciklas2
skip2:

	jmp endnoparam_trans
noparam_trans:
	jmp noparam
endnoparam_trans:

	mov [ds:di], ax
	inc di
	inc di
ciklas2:
	mov al, byte ptr [es:si]
	inc si
	cmp al, 20h
	je endciklas2
	cmp al, 0Dh
	je noparam
	mov [ds:di], al
	inc di
	jmp ciklas2
endciklas2:

	mov ax, word ptr [es:si]
	inc si
	inc si
	cmp ax, 6E2Dh			;'-n'?	(3)
	je ciki2
	call klaida
ciki2:
	or varFlagai, 1
endparam:
	mov al, byte ptr [es:si]
	cmp al, 0Dh
	je noparam
	call klaida
noparam:

; parametrai gauti


	cmp varFlagai, 0
	jne yra
	mov si, offset msgNoParam
	call writeln
	jmp endyra
yra:
	mov si, offset msgParam
	call writeln
endyra:

	mov si, offset varStringas
	call writeln
	mov si, offset varFailas
	call writeln

;programos pabaiga

	mov ah, 4Ch
	int 21h

end start