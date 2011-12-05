; Programa 'PutChars'.
; (c) Giedrius Noreikis, MIF, 2002.
; -----------------------------------------------------------------------------

	MODEL small		; Atminties modelis: 64K kodui ir 64K duomenims
	STACK 256

; ----- Konstantos ------------------------------------------------------------	
	
; ----- Duomenys (kintamieji) -------------------------------------------------

	DATASEG

msgText DB "Text to print",0

; ----- Kodas -----------------------------------------------------------------

	CODESEG

Strt:
	mov ax,@data		; ds - duomenu segmentas
	mov ds,ax
	
	mov si,OFFSET msgText
	call PrintString
	
Exit:
	mov ax,04C00h
	int 21h			; int 21,4C - programos pabaiga

;--------------------------------------------------------------------------
; PrintString - prints string to STDOUT
;	IN
;	  ds:si - string to print
;--------------------------------------------------------------------------
PrintString	PROC
	push ax			; issaugoti ax
	push dx			; issaugoti dx
	
	cld			; si (di) didinsime
	mov ah,2h		; int 21,2 - simbolio isvedimas
	
@@Repeat:
	lodsb			; al&lt;-[ds:si]
	or al,al
	jz @@Exit		; iseiti, jei al=0
	mov dl,al
	int 21h
	jmp SHORT @@Repeat
	
@@Exit:
	pop dx
	pop ax
	ret
PrintString	ENDP
;--------------------------------------------------------------------------
END 
