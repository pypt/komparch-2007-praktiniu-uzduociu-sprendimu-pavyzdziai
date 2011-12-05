;Justas Arasimavicius; Turetu gautis, jei gausis HEXView'eris
.Model small
.Stack 200h

	Cr = 0Dh
	Lf = 0Ah
        Buf_dydis = 200 
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
        
	jmp exit
Ciklas_baigtas:
;********************************************************************
;************* Jei Dx > 1, klaida - perdaug parametru ***************
;********************************************************************
	cmp dx, 01h
	je Su_parametrais_viskas_gerai
	mov al, 01h
        
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
	mov bx, 2
	push bx
Skaitymo_ciklas:
	mov [buferio_pabaiga], 0				
	mov ah, 3Fh
	mov bx, [fshandle]
	mov cx, buf_dydis
	mov dx, offset skaitbuf
	int 21h
	mov si, offset skaitbuf
	add si, ax
	mov byte ptr [si], '$'
	mov si, offset skaitbuf
	mov ah, 09h
	mov dx, si
	int 21h
	call pozicija
	pop bx
  	dec bx
        call readkey
	or bx, bx
	jnz Skaitymo_ciklas
exit:
	mov ah, 4ch
	int 21h

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
klaida proc
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
	xor cx, cx
	mov dx, buf_dydis
	neg dx
	mov bx, fshandle		
	int 21h	
	
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
