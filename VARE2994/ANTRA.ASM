Title Antra uzduotis

.model small
.stack 1000
.data

	helpas	db	'Kad paleistumete programa rashykite "antra /[ilgis]",',10,13
		db	'ilgis - kvadrato krastines ilgis. 3<ilgis<201.',10,13
		db	'Antra (c), Valdemaras Repsys$'
	ilg	db	'Ivedete netinkama krastines ilgi$'
	ivesk	db	'Iveskite kvadrato krastines ilgi$'
	blog	db	'Ivedete blogus parametrus$'
	blogilg	db	'Ivedete bloga ilgi, 3<ilgis<201. $'
	ineil	db	10,11 dup(0)
	ilgis	db	130			
	posl	dw	?	;posl[inkis] saugos virshutinio kairiojo tashko poslinki
	splv	db	1	;remelio spalva
	fonas	db	0	;fono spalva
	splv1	db	9	;vienos puses spalva
	splv2	db	7	;kitos puses spalva
	ten	dw	10
	hun	dw	100



.code



main proc
pradzia:
	mov ax,@data                    ; ds registro iniciavimas
	mov ds, ax                      

	mov dl, es:[80h]	;kaip atrodo komandine eilute?
	cmp dl, 0
	je parnerajmp		;jei parametru nera shokam prie parametru ivedimo
	cmp dl,2
	jbe blogaijmp
		
	mov di,82h
	mov ax,es:[di]		;jei parametras /?  ishmetame pagalba
	;lodsw
	mov bx,'?/'
	cmp ax,bx
	je pagalba




	mov bl,es:[di]		;tikrinam ar antras parametru eilutes simbolis yra '/', jei ne - blogai
	cmp bl,'/'
	jne blogaijmp
		
	dec dl
	dec dl
	xor dh,dh
	add di,dx		;nustatome, kad di rodytu i paskutini parametru eilutes simboli
	jmp go

blogaijmp:
	jmp blogai		;kad galetume toliau shokinet
parnerajmp:
	jmp parnera
go:
	mov al,es:[di]		;nuskaitome paskutini skaiteni
	sub al,30h
	cmp al,9		;jei tai ne skaitmuo - blogai
	ja blogai
	mov ilgis,al
	
	dec dl			;jei tai nera pirmas ir paskutinis skaitmuo einam toliau
	cmp dl,0
	je paryranzn

	dec di
	
	mov al,es:[di]		;nustatom viduriniji skaitmeni
	sub al,30h
	cmp al,9
	ja blogai
	xor ah,ah
	push dx
	mul ten			;!!!!!!!!
	pop dx
	add ilgis,al

	dec dl
	cmp dl,0
	je paryranzn

	dec di
	
	mov al,es:[di]		;nustatome pirmaji skaitmeni
	sub al,30h
	cmp al,9
	ja blogai
	xor ah,ah
	push dx
	mul hun			;!!!!!!!!
	pop dx
	add ilgis,al

	jmp paryranzn

paryranzn:
	mov al,ilgis		;tikriname ar ne daugiau nei 200
	cmp ax,200
	ja blgilg	


	mov al,ilgis
	cmp al,4		;tikriname ar ilgis ne mazhiau negu 4
	jb blgilg
	jmp paryra
blgilg:
	mov dx, offset blogilg              ; uzrasome ant ekrano eil turini
	mov ah, 09h                        ; 09h  spec. int 21h funkcija
	int 21h
	jmp galas		
	
pagalba:

	mov dx, offset helpas              ; uzrasome ant ekrano eil turini
	mov ah, 09h                        ; 09h  spec. int 21h funkcija
	int 21h
	jmp galas		


	
blogai:
	mov dx, offset blog              ; uzrasome ant ekrano eil turini
	mov ah, 09h                        ; 09h  spec. int 21h funkcija
	int 21h
	jmp galas
parnera:

	mov dx, offset ivesk		; uzrasome ant ekrano eil turini
	mov ah, 09h			; 09h  spec. int 21h funkcija
	int 21h
	call writeln
	call ivedimas
	call writeln
	mov si, offset ineil		;krashtines ilgi ishsaugome ieil
	mov di,80h
	inc si
	mov cl,ds:[si]
	inc cl
	inc cl
	mov es:[di],cl
	inc si		
	inc di
	mov bl,' '
	mov es:[di],bl		;visus duomenis sumetam i es:[80h,81h....]
	inc di			
	mov bl,'/'
	mov es:[di],bl
	inc di
	dec cl
	dec cl
	xor ch,ch
	rep movsb
	jmp pradzia		;ir naudojame jau parashyta algoritma ascii pavertimo i skaichiu
paryra:



	mov ax,13h		;ijungiame 13 grafini rezhima 320x200x256
	int 10h

	mov     cx, 32000;	;ishvalome ekrana
        mov     ax,0A000h
        mov     es,ax
        xor     di,di
        mov     al,fonas
        mov     ah,al
        rep     stosw
	
	
	mov ah,ilgis
	shr ah,1		;ah=ah div 2
	

	mov al,160		;al=160
	sub al,ah		;al=160-ah	 kiek pikseliu linija turi buti pavaziavusi i sona al
	
	push ax			;ishsaugome tai 
	
	mov bl,100
	sub bl,ah				;kiek pikseliu linija turi buti pavaziavusi i apachia bl
	
	push bx	

	
	xor bh,bh
	xor ah,ah
		
	mov dx,bx
	
	mov cl,6
	shl bx,cl

	mov cl,8
	shl dx,cl		;bx=bx*64+bx*256=320*bx


	
	add bx,dx		
	
	
	
	add ax,bx		;suzhinome virshutines linijos poslinki
	mov posl,ax		;ishsaugome poslinki
	
	push ax
	push bx
	push cx
	push dx
	mov dl,splv
	mov dh,splv1
	mov splv,dh
	mov bl,ilgis
ckl1:	
	push ax
	call horlin
	pop ax			;uzhpildome kvadrata spalva splv1
	add ax,320
	dec bl
	cmp bl,0
	jne ckl1
		

	mov splv,dl
	pop dx
	pop cx
	pop bx
	pop ax


		
	call horlin		;nubraizhome virshutine linija


	pop bx
	xor bh,bh
	dec bl
	add bl,ilgis
	mov dx,bx		
	mov cl,6
	shl bx,cl
	mov cl,8
	shl dx,cl		;bx=bx*64+bx*256=320*bx
	add bx,dx
	


	pop ax	
	xor ah,ah
	
	add ax,bx 	;suzhinome apatines linijos poslinki
	
	
	call horlin	;nubraizhome apatine linija

	xor di,di
	add di, posl
	mov ah,splv	;nustatome spalva vertikaliu liniju	
	mov cl,ilgis
	mov al,cl
	mov bl,ilgis
	xor bh,bh
	dec bx
	mov si,di




ckl:
	mov es:[di],ah		;braizhome shonines linijas ir istizhaine
	add di,bx
	mov es:[di],ah
	sub di, bx
	mov es:[si],ah
	
	add di,320
	add si,321                        
	dec cl
	cmp cl,0	
	jne ckl






	mov bl,ilgis
	dec bl
	dec bl
	dec bl
	mov al,splv2
	mov splv,al
	xor ax,ax
	add ax,posl
	add ax,641
	mov ilgis,1
	
	
ckl2:
	
	push di
	push ax
				;uzhpildome puse kvadrato spalva splv2
	call horlin	

	pop ax
	pop di

	add ax,320
	inc ilgis
	dec bl
	cmp bl,0
	jne ckl2
	



kartot:
	MOV   AH, 01H                       ; tikrinam ar nepaspaustas mygtukas
	INT   16H                           ; jei nepaspaustas vel tikrinam
	JZ    kartot
	


	mov ax,03h			;grishtame i tekstini rezhima
	int 10h
galas:
	mov ah, 4ch                     ; baigiam programa ir griztam i os
	int 21h                         
endp

horlin proc
	mov di,ax		;ax - poslinkis
	xor ch,ch
	mov cl,ilgis
	mov al,splv
again: 	rep stosb		
	jcxz next	;ishvemgiame rep klaidos
	loop again
next:
	ret
endp

writeln proc
	mov dl, 0dh                     ;
	mov ah, 06h                     ; uzrasome ant ekrano #13 #10
	int 21h                         ;
	mov dl, 0ah                     ;
	int 21h                         ;
	ret
endp

ivedimas proc                     ; nuskaito eilute is klaviaturos
	mov dx, offset ineil            ;
	mov ah, 0ah                     ; skaitome is klaviaturos
	int 21h                         ;
	ret
endp

	
   
END