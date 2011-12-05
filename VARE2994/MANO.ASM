
segment sseg  stack 'stack'
stk db 256 dup (?)
ends

segment dseg 'data'
tekstas db 'Nu jei veikia tai jega$'
ends

segment cseg
assume cs:cseg, ds:dseg,ss:sseg

writedx proc
	mov ah, 09h                        ; 09h  spec. int 21h funkcija
	int 21h
	ret
endp

Main proc

	push	ds		
	xor	ax, ax		
	push	ax		
	
	mov ax, dseg
	mov ds, ax
	xor ax,ax
	lea dx,[tekstas]
	call writedx
	
	;PAMEGINK SITA NUKOMENTUOT, TADA LYG IR VEIKIA, BET KODEL NEVEIKIA PAPRASTAI??
	;kartot:
	;MOV   AH, 01H                       ; tikrinam ar nepaspaustas mygtukas
	;INT   16H                           ; jei nepaspaustas vel tikrinam
	;JZ    kartot		

	
	

	ret	
endp Main
ends
end Main