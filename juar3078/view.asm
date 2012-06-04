;Justas Arasimavicius; Turetu gautis, jei gausis HEXView'eris
.Model small
.Stack 200h

	Cr = 0Dh
	Lf = 0Ah
	Buf_dydis = 50000	
	fix = 336
	Fonas = 00011111b
.data
	PSPsize    equ 80h
	PSPduom    equ 81h

	Esc_key    equ 01h
	End_key    equ 4Fh
	Home_key   equ 47h
	PgUp_key   equ 49h
	PgDown_key equ 51h
	Up_key     equ 48h
	Down_key   equ 50h
	

	Video_memory dw 0B800h
	msgh1 db " Trecias uzdavinys - turetu buti HexView'eris "
	msgh2 db cr,lf,lf,"   Programos autorius Justas Arasimavicius "
	msgh3 db cr,lf," "
	msgh4 db cr,lf,"Programos uzdavinys - atlikti minimalia HexView'erio funkcija"
	msgh5 db cr,lf,"Programai reiketu pateikti failo saltinio varda"
	msgh6 db cr,lf,"Pvz.: view.exe duom.dat$"	
	klai0 db "Klaida, neivesti duomenys! Help iskvieciamas parametru /? $"
	klai1 db "Klaida, Perdaug parametru! $"	
	klai2 db "Failo atidarymo klaida! $"
	klai3 db "Skaitymo is failo klaida! $"	
	klai4 db "Klaida uzdarant faila! $"			
	txt1 db 'Justo Arasimaviciaus treciosios uzduoties HexViewer sprendimas'			;63 simboliai		
	txt2 db '  Valdymo klavisai:  ',24,25,', PageUp, PageDown, Home, End, Esc '	;58 simboliai
	Hexskait db '0123456789ABCDEF'
	ekrano_pabaiga db 0
	eilutes_pabaiga db 1		
	buferio_pabaiga db 0
	pirmas_kartas db 0
	FPointer      dw 2 dup (0)
	BufPos	      dw 0
	EkranoPointer dw 0
	simboliu_yra  db 0
	simboliu_liko db 0
	plius 	      db 1	
	kryptis	      db 0
	adr db 0
	    db 0
	    db 0
	    db 0
	
	pradzia dw ?	
	fshandle dw ?
	fdhandle dw ?		
	param  db 129 	 dup (?)
	skaitbuf db buf_dydis dup (?)		; 21*16 (336 baito)	

	
.code
Start:	
;********************************************************************
;********************* Prefikso nuskaitymas *************************
;****************** Ir irasymas i param buferi **********************
;******* Programos pradzioje DS ir ES rodo i PSP sriti ************** 
;********************************************************************
	mov cl, [ds:PSPsize]	
	xor ch, ch	
	push cx
	mov si, PSPduom
	mov ax, @data
	mov es, ax
	mov di, offset param
	cld
	rep movsb
	mov byte ptr [es:di], 00h
;********************************************************************
;************* Duomenu segmentas turi rodyti i duomenis *************
;********************************************************************
	push ds
	push es
	pop ds
	pop es
;********************************************************************
;******** Ar yra ivesta kieknors parametru ir ar testi darba ********
;********************************************************************
	pop cx
	or cl, cl
	jz klaida0	
	jmp Klaidos_0_nera
Klaida0: 
	mov al, 00h
	call klaida
	jmp exit
;********************************************************************
;********** Jei yra parametru nuliname tarpus ir tabulecijas ********
;********Tuo pat skaiciujame parametrus ir ieskom parametro /? ******
;*************** Di registras rodo failo vardo pradzia **************
;********************************************************************
klaidos_0_nera:
	xor ax, ax
	xor bx, bx
	xor dx, dx				;Parametru skaicius
	mov si, offset param
	push si
	cld
	dec cl
@@Nulinimo_ciklas:
	lodsb 
	mov ah, [si]
	cmp al, 20h
	je short @@nulinam
	cmp al, 09h
	je short @@nulinam	
	cmp al, 00h
	je short @@neplius
	cmp bx, 01h	
	je short @@neplius
	push si
	dec si
	mov di, si
	pop si			
	inc dx
	mov bx, 01h	
@@neplius:
	cmp al, "/"
	je short @@gal_help
@@Atgal:
	
	loop @@Nulinimo_ciklas
	jmp Ciklas_baigtas
@@Nulinam:
	mov byte ptr [ds:(si-1)], 00h	
	xor bx, bx
	jmp @@Nulinimo_ciklas
@@Gal_help:
	cmp ah, "?"	
	jne @@Atgal
	mov al, 07h
	call klaida
	jmp exit
Ciklas_baigtas:
;********************************************************************
;************* Jei Dx > 1, klaida - perdaug parametru ***************
;********************************************************************
	cmp dx, 01h
	je Su_parametrais_viskas_gerai
	mov al, 01h
	call klaida
	jmp exit
Su_parametrais_viskas_gerai:
;********************************************************************
;******************* Duomenu failo atidarymas ***********************	
;********************************************************************	
	mov ah, 3Dh
	mov al, 00h
	mov dx, di
	int 21h
	mov bl, 02h
	jnc short KlaidosF_nera
KlaidaF:
	mov al, bl
	call klaida
	jmp exit
KlaidosF_nera:
	mov [fshandle], ax
;********************************************************************	
;******************** Duomenu failo skaitymas ***********************
;********************************************************************
	xor bl, bl				;Kiek baitu irasyta
	xor cx, cx
	xor dx, dx	
	push es
	mov es,[Video_memory]
;********************************************************************
;***** Procedura i al grazinanti viena baita arba ah klaidos koda ***
;********************************************************************
Getbyte proc
	push bx
	push cx
	push dx
	push si
	or kryptis, kryptis
	jz zemyn	
	cmp bufpos, 353
	jnae tikr2
        sub bufpos, 353
	mov si, offset skaitbuf
	add si, bufpos
	cld
	lodsb
	xor ah, ah
        jmp grisk
tikr2:
	mov cx, fpointer
        mov dx, fpointer + 2
	or cx, cx
	jnz keisk
	cmp dx, 353
	jae keisk
	mov ah, 1
	jmp grisk
keisk:
	call 








Skaitymo_ciklas:
	mov [buferio_pabaiga], 0				
	mov ah, 3Fh
	mov bx, [fshandle]
	mov cx, buf_dydis
	mov dx, offset skaitbuf
	int 21h
	mov bl, 03h
	jc KlaidaF
	;add filepointer, ax	
	or ax, ax
	jnz skip1
	jmp nera_ka_skaityti
skip1:
	mov BuferPointer, ax
;********************************************************************
;*********** Failo duomenu transformavimas i tai kas reikia *********
;********************************************************************
;***** Einamosios eilutes adresas saugomas registru pora Cx:Dx ******
;********************************************************************
	mov bl, pirmas_kartas
	cmp bl, 0
	jne praleisk
	call piesk_titul	
	mov di, 320
	mov pirmas_kartas, 1
praleisk:
	mov si, offset skaitbuf		
klav:
	mov bl, ekrano_pabaiga
	or bl, bl
	jnz short kartok
	call ekranas
	mov bl, Buferio_pabaiga
	or bl, bl
	jnz skaitymo_ciklas	
kartok:
	call readkey	
	cmp ah, Esc_key 
	je @@@Exit1
	jmp kiti
@@@Exit1:
	jmp exit1
kiti:
	cmp ah, End_key    
	je endas
	cmp ah, Home_key   
	je home
	cmp ah, PgUp_key   
	je Pgup
	cmp ah, PgDown_key 
	je pgdown
	cmp ah, Up_key     
	je up
	cmp ah, Down_key   	
	je down
	jmp kartok
endas:
	jmp kartok
Home:
	jmp kartok
Pgup:
	jmp kartok
Pgdown:
	jmp kartok
Up:
	jmp kartok

Down:	
	cmp buferpointer, 336	 		
	jna gal_mazas_buferis
	mov Ekrano_pabaiga, 0
	mov ax, buferpointer
	cmp ax, 352
	jae @@352
	sub si, 320
	mov di, 320
	mov bx, 336
	sub bx, ax
	sub buferpointer, bx
	jmp klav
@@352:	
 	sub si, 320
	mov di, 320
	sub buferpointer, 16
	jmp klav
gal_mazas_buferis:
	jmp kartok
	mov cx, 0FFFFh
	mov dx, 320
	not dx
	inc dx
	call pozicija
	call piesk_titul
	mov di, 320
	mov ekrano_pabaiga, 0	
	jmp skaitymo_ciklas
	jmp kartok
Nera_ka_skaityti:
	mov [buferio_pabaiga], 1
	jmp kartok
exit1:
	call valyk
Exit:	
	call rodyk	
	pop es
	mov ax, 4C00h
	int 21h
;********************************************************************
;*************** Procedura piesianti viena ekrana *******************
;********************************************************************
ekranas proc				;Rodykle i rasymo buferi	
	push ax
	push dx	
	mov dx, ax
cikliukas:
	call linija
	mov al, ekrano_pabaiga
	or al, al
	jnz quitIt	
	mov al, buferio_pabaiga
	or al, al
	jz short cikliukas  	
QuitIt:
	pop dx	
	pop ax	
	ret
endp
;********************************************************************
;************* Procedura piesianti viena ekrano linija **************
;********************************************************************
linija proc
	push ax
	push bx
	push cx		
	mov cl, eilutes_pabaiga
	cmp cl, 1
	jne spausdink
	mov eilutes_pabaiga, 0
	mov simboliu_yra, 0
	xor ch, ch
	mov ah, fonas
	mov cl, 02h
	call tarpas
	call adresas
	cld
	call skaicius	
	mov cl, 02h
	call tarpas
	mov pradzia, di
spausdink:	
	mov bl, simboliu_yra		
ciklas:	
	lodsb
	inc bl	
	call simboliai
	call simbol
	mov bh, al
	xchg ah, al
	mov ah, fonas
	stosw
	mov al, bh
	stosw	
	add EkranoPointer, 1  	
	mov al, 20h
	stosw
	dec dx
	jz exit2
	cmp bl, 16
	je exit2	
	jmp ciklas	
exit2:			
	or dx, dx
	jnz nebufgalas
	mov buferio_pabaiga, 1	
nebufgalas:
	mov bh, 16
	sub bh, bl	
	jz netaip		
	mov simboliu_yra, bl		
	;add EkranoPointer, 	
	xor bh, bh		
	jmp kitaip
netaip:		
	mov simboliu_yra, 16
	;add EkranoPointer, 16
	add di, 34
	mov eilutes_pabaiga, 1
	mov cl, 2
	call tarpas	
kitaip:	
	mov bx, ekranoPointer
	cmp bx, fix
	jne dar_ne_ekrano_galas
	mov ekrano_pabaiga, 1
	mov ekranoPointer, 00h
dar_ne_ekrano_galas:
	call bruksniai
	pop cx
	pop bx
	pop ax
	ret
endp
;********************************************************************
;******* Procedura piesianti bruksnius kas ketvirta simboli *********
;********************************************************************
bruksniai proc
	push di
	push ax
	push cx
	xor ch, ch
	mov di, [pradzia]
	mov cl, 3
@@1:
	add di, 22
	mov ah, fonas
	mov al, '-'
	stosw
	loop @@1
	pop cx
	pop ax
	pop di
	ret
endp
;********************************************************************
;****** Procedura piesianti realius simbolius pagal Al reiksme ******
;********************************************************************
Simboliai proc
	push di
	push ax
	push bx
	add di, 98
	dec bl
	xor ah, ah
	mov al, bl
	mov bl, 4
	mul bl
	sub di, ax	
	pop bx
	pop ax
	mov ah, fonas
	Stosw		
	pop di
	ret
endp
;********************************************************************
;************** Tekstinio rezimo inicializavimas ********************
;********************************************************************
Init_Video proc
	push ax
	mov ah, 00h
	mov al, 03h
	int 10h
	pop ax
	ret
endp
;********************************************************************
;********** Procedura piesianti pradini HexViewer vaizda ************
;********************************************************************
Piesk_titul proc
	call slepk
	call init_video
	push es
	push di
	push si
	push Ax
	push Cx	
	xor cx, cx
	cld
	mov es, [video_memory]
	mov di, 0000h
	mov si, offset txt1
	mov ah, 00000010b		;neblogas fonas 011	
	mov cl, 9
	call tarpas

	mov cl, 62
@@rasyk:
	lodsb
	stosw
	loop @@rasyk	
	mov cl, 9
	call tarpas
	mov cl, 80
	mov ah, 11110000b
	call tarpas
	mov di, 3680
	mov cl, 80
	call tarpas
	mov ah, 00000010b
	mov cl, 11
	call tarpas
	mov si, offset txt2
	mov cl, 58
	cld	
@@rasyk2:
	lodsb
	stosw
	loop @@rasyk2
	mov cl, 10
	call tarpas
	mov ah, fonas	
	mov di, 320
	mov cx, 1680
	call tarpas		
	pop cx
	pop ax
	pop si
	pop di
	pop es
	ret
endp	
;********************************************************************
;*************** Procedura skirta klaidoms apdoroti *****************
;********************************************************************
klaida proc
	cmp al, 00h
	je @@kl0
	cmp al, 01h
	je @@kl1
	cmp al, 02h
	je @@kl2
	cmp al, 03h
	je @@kl3
	cmp al, 04h
	je @@kl4	
	cmp al, 07h
	je @@helpas
@@kl0:
	mov dx, offset klai0
	jmp @@end_klaida
@@kl1:
	mov dx, offset klai1
	jmp @@end_klaida
@@kl2:
	mov dx, offset klai2
	jmp @@end_klaida
@@kl3:
	mov dx, offset klai3
	jmp @@end_klaida
@@kl4:
	mov dx, offset klai4
	jmp @@end_klaida
@@helpas:
	mov dx, offset msgh1
@@end_klaida:
	mov ah, 09h
	int 21h
	ret
endp 
;********************************************************************
;****** Procedura konvertuovanti simbolio koda i du kodus ***********
;********************************************************************
;* Parametrai: registas Al, jo reiksme konvertuojama i du registrus *
;****** Ah ir Al Pvz.: Reiksme 35h konvertuojama i 33 ir 35  ********
;********************************************************************
simbol proc	
	push bx
	push cx

	mov bx, offset hexskait
	mov ah, al
	and al, 11110000b
	mov cx, 4h
cikl:
	shr al, 01h
	loop cikl
	xlat
	Xchg ah, al
	and al, 00001111b
	xlat
	pop cx
	pop bx
	ret
endp
;********************************************************************
;******** Adreso formuojamo Cx:Dx didinimas arba mazinamas ********** ;******** priklausomai nuo Df pozymio ******************************* 
;******** Parametrai atmintyje kintamuoju adr + 4 baitai jam ********
;********************************************************************
skaicius proc
	push cx
	push dx
	push Bx
	pushf
	pop Bx	
	mov ch, [adr]
	mov cl, [adr + 1]	
	mov dh, [adr + 2]	
	mov dl, [adr + 3]
	test Bx, 0400h              
	jnz short @@mazink
	add dx, 10h
	jnc @@grisk
	inc cx	
	xor dx, dx
	jmp short @@grisk
@@mazink:
	cmp dx, 0000h
	jne short @@skip
	sub dx, 10h
	dec cx
	jmp short @@grisk
@@skip:
	sub dx, 10h	
@@grisk:
	mov [adr], ch
	mov [adr + 1], cl
	mov [adr + 2], dh
	mov [adr + 3], dl
	pop bx
	pop dx
	pop cx
	ret
endp
;********************************************************************
;*** Procedura uzrasanti adresa esanti atmintyje i vieta zymima Di **
;********************************************************************
Adresas proc
	push dx
	push bx
	push ax
	mov ah, fonas
	mov dh, ah
	xor bx, bx
	cld
@@Kartok:	
	mov al, [adr + bx]
	call simbol
	push ax
	xchg ah, al
	mov ah, dh
	stosw
	pop ax
	mov ah, dh
	stosw
	inc bl
	cmp bl, 02h
	jne short @@next
	mov al, ':'
	stosw
@@next:
	cmp bl, 04h
	jne short @@kartok
	pop ax
	pop bx
	pop dx
	ret
endp
;********************************************************************
;***** Procedura rasanti tarpa, cx kartu; modifimuoja di ir cx ******
;******** dar vienas parametras ah - fono ir srifto spalva **********
;********************************************************************
tarpas proc
	push ax
	cld	
	xor al, al
	rep stosw
	pop ax
	ret
endp
;********************************************************************
;****** Procedura nuskaitanti paspausto klaviso reiksme (AH) ********
;********************************************************************
Readkey proc			;Rezultatas Ah reg
	push bx
	push ax	
	mov ah, 10h
	int 16h	
	mov bh, ah
	pop ax
	mov ah, bh
	pop bx 
	ret
endp		 	
;********************************************************************
;***************** Procedura paslepianti kursoriu *******************
;********************************************************************
Slepk proc
	push ax
	push cx
	mov ah, 01h
	mov cx, 2000h
	int 10h
	pop cx
	pop ax
	ret
endp
;********************************************************************
;***************** Procedura vel parodanti kursoriu *****************
;********************************************************************
rodyk proc
	push ax
	push cx
	mov ah, 01h
	mov cx, 0D0Eh
	int 10h
	pop cx
	pop ax
	ret
endp
Pozicija proc			;grazina DX:AX; parametras CX:DX
	push bx
	push cx	
	mov ah, 42h
	mov al, 01h
	mov bx, fshandle		
	int 21h	
	jnc liuks
	mov al, 5h
	pop cx
	pop bx
	call valyk
	jmp klaidaf
liuks:
	pop cx
	pop bx
	ret
endp
didink proc
	push bx
	push cx
	push dx
	mov bx, fpointer
	mov cx, [fpointer + 2]
	or plius, plius
	jz atimk
	add cx, ax
	jnc nplius
	inc dx
	jmp nplius    
atimk:
	sub cx, ax
	jnc nplius
	dec bx	
nplius: 
	mov fpointer, bx
	mov fpointer + 2, cx
	pop dx
	pop cx
	pop bx
	ret
endp
valyk proc
	mov es, video_memory
	mov di, 00h
	mov cx, 2000
	mov ah, 00001111b
	mov al, 00h
	rep stosw
	ret
endp
end start