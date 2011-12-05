Title Antra uzduotis

.model tiny
.stack 1000
.data

	helpas	db	'Kad paleistumete programa rashykite "trecia"',10,13
		db	'Toliau klausykite programos nurodymu',10,13
		db	'Antra (c), Valdemaras Repsys $'
	ivesk1	db	'Iveskite pirmaji skaichiu $'
	ivesk2	db	'Iveskite antraji skaichiu $'
	sk1	db	255,256 dup(0)
	sk2	db	255,256 dup(0)
	sk1off	dw	?
	sk2off	dw	?	
	suma	db	'Pirmojo ir antrojo skaichiu suma =$'
	ats	db	300 dup(0)
	bla	db	'$'
	ilgis	dw	0
	blog	db	'Ivedete blogus parametrus$'



.code


main proc

	mov ax,@data
	mov ds,ax
	push ax



	mov dl, es:[80h]	;kaip atrodo komandine eilute?
	cmp dl, 0
	je pradzia		;jei parametru nera shokam prie parametru ivedimo
		
	mov di,82h
	mov ax,es:[di]		;jei parametras /?  ishmetame pagalba
	;lodsw
	mov bx,'?/'
	cmp ax,bx
	je pagalba
	mov dx, offset blog	; uzrasome ant ekrano eil turini
	mov ah, 09h		; 09h  spec. int 21h funkcija
	int 21h
	jmp galas

pagalba:	
	mov dx, offset helpas              ; uzrasome ant ekrano eil turini
	mov ah, 09h                        ; 09h  spec. int 21h funkcija
	int 21h
	jmp galas

pradzia:
	
	call writeln
	pop ax
	mov es,ax

	mov sk1off, offset sk1
	mov sk2off, offset sk2

	mov dx,offset ivesk1
	call writedx
	mov dx, sk1off
	call ivedimas
	mov dx,offset ivesk2		;skaichiu ivedimas
	call writedx
	mov dx, sk2off
	call ivedimas

	mov di, offset ats
	mov al,' '
	mov cx,300
	rep stosb			;uzhpildome tarpais ats

	dec di			;es:[di] rodo i paskutini ats baita


	inc sk2off
	mov si, sk2off
	mov dl,ds:[si]			;ishsaugome antrojo skaichiaus skaitmenu skaichiu

	inc sk1off
	mov si, sk1off
	mov cl,ds:[si]			;ishsaugome pirmojo skaichiaus skaitmenu skaichiu
	

	xor dh,dh			;dx antrojo skaichiaus skaitmenu skaichius
	xor ch,ch			;cx pirmojo skaichiaus kaitmenu skaichius
	
	
	add sk1off,cx			;ishsaugom poslinkius kintamuosiuose
	add sk2off,dx

	mov si,sk1off	

	mov ah,ds:[si]
	sub ah,30h
	dec sk1off
		
		
	mov si, sk2off

	mov al,ds:[si]
	sub al,30h
	dec sk2off

	

	add al,ah			;sudedam du paskutinius skaichiu skaitmenis


	cmp al,9
	ja skcarry
	jmp toliau
skcarry:
	mov bl,1
	sub al,10		
toliau:
	add al,30h
	mov es:[di],al			;atsakyma saugome masyve ats
	
	inc ilgis

	dec di
	dec cx
	dec dx

	cmp cx,0			;tikrinam ar nepasibaige ne vienas skaichius
	je pirmbaig
	
	cmp dx,0
	je antrbaig
go:
	mov si,sk1off
	mov ah,ds:[si]
	sub ah,30h
	dec sk1off

	mov si, sk2off
	mov al,ds:[si]
	sub al,30h
	dec sk2off			;vieno skaichiaus skaitmeni irashome i ah kito i al

	add al,ah			;juos sudedame ir pridedame carry
	add al,bl
	xor bl,bl
	cmp al,9
	ja skcarry1
	jmp toliau1
skcarry1:
	mov bl,1
	sub al,10		
toliau1:
	add al,30h	
	mov es:[di],al
	dec di

	inc ilgis

	dec cx
	dec dx

	cmp cx,0			;tikrinam ar nepasibaige ne vienas skaichius
	je pirmbaig
	
	cmp dx,0
	je antrbaig
jmp go
		



pirmbaig:

	mov si,sk2off
ckl1:
	cmp dx,0
	je ishvedimas			;tikrinam ar nepasibaige antras skaichius
	mov al,ds:[si]	
	sub al,30h		
	add al,bl			;carry tampa 1, o skaitmuo=skaichius-10
	xor bl,bl
	cmp al,9
	ja skcarry2
	jmp toliau2
skcarry2:
	mov bl,1
	sub al,10		
toliau2:	
	dec si
	add al,30h
	mov es:[di],al
	dec di
	
	inc ilgis

	dec dx
	jmp ckl1





antrbaig:
	mov si,sk1off
ckl2:
	cmp cx,0
	je ishvedimas			;tikrinam ar nepasibaige pirmas skaichius
	mov al,ds:[si]	
	sub al,30h		
	add al,bl			
	xor bl,bl
	cmp al,9
	ja skcarry3			;jei skaichius didesnis uzh 9
	jmp toliau3
skcarry3:
	mov bl,1			;carry tampa 1, o skaitmuo=skaichius-10
	sub al,10		
toliau3:	
	dec si
	add al,30h
	mov es:[di],al
	dec di
	dec cx
	jmp ckl2


ishvedimas:
	cmp bl,0
	je toliau4
	mov al,'1'			;pasizhiurime ar carry netushchia
	mov es:[di],al			;jei netushchia prirashome vienetuka
toliau4:
	call writeln	

	mov dx,offset suma
	call writedx

	mov ax,ilgis
	mov dx,300		
	sub dx,ax
	add dx,offset ats
	
	
	call writedx
galas:	
	mov ah, 4ch                     ; baigiam programa ir griztam i os
	int 21h                         
	
endp


writeln proc
	mov dl, 0dh                     ;
	mov ah, 06h                     ; uzrasome ant ekrano #13 #10
	int 21h                         ;
	mov dl, 0ah                     ;
	int 21h                         ;
	ret
endp

ivedimas proc				; nuskaito eilute is klaviaturos i dx
	mov ah, 0ah			; skaitome is klaviaturos
	int 21h                      
	call writeln
	ret
endp

writedx proc
	mov ah, 09h                        ; 09h  spec. int 21h funkcija
	int 21h
	call writeln
	ret
endp
	
   
END