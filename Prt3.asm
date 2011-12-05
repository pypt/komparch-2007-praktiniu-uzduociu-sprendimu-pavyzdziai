masm
model small
;---------------------------------------------------------------------------------------------------------------------------
writeln macro tekstas				; isvedimo i ekrana makrokomanda
	push	dx 				; steke ishsaugomas registro dx reiksme
	mov 	ah,09h
	lea 	dx,tekstas
	int 	21h
	pop	dx 				; regisro dx reiksme isimama is steko
endm
;---------------------------------------------------------------------------------------------------------------------------
patikrinimas1 macro skaicius,galas 		; makrokomada patikrina ar
local tikrinti,pusklaida,next,klaida,pabaiga 	; ivestas skaicius teisingas
	push	cx 				; registru reiksmes issaugomos steke		   
	push	si
	push	ax
	mov	cl,skaicius[1] 			; cl priskiriama ivesto skaiciaus ilgio reiksme
	mov	si,2	  			; si=2
tikrinti: 					; skaiciaus tikrinimas
	mov	ah,skaicius[si] 		; ah priskiriamas skaiciaus skaitmuo
	cmp	ah,39h 				; skaitmens kodas palyginamas su 39h
	jg	klaida 				; jei kodas didesnis uz 39h tai klaida
	cmp	ah,30h 				; skaitmens kodas palyginamas su 30h
	jl	klaida 				; jei kodas mazesnis uz 3oh tai klaida
	mov	ah,skaicius[2] 			; ah priskiriamas skaiciaus skaitmuo
	cmp	ah,30h 				; pirmas sk.skaitmuo palyginamas su 30h
	je	pusklaida 			; jei ah = 30h tai pereinama prie klaida 
	jmp	next 				; perejimas prie next
pusklaida:
	mov	ah,skaicius[1] 			; ah priskiriama sk. ilgio reiksme
	cmp	ah,1 				; palyginimas ah su 1 
	jg	klaida				; jei ah>1 ,tai pereijimas prie klaida
next:	
	inc	si 				; padidinamas si ,t.y. poslinkis
loop	tikrinti 				; ciklas vyksta tiek kartu kiek skaitmenu yra skaiciuje
	jmp	pabaiga 			; perejimas prie pabaiga zymes
klaida: 
	writeln ErrMes				; klaidos pranesimo isvedimas	
	jmp	galas 				; perejimas prie programos pabaigos
pabaiga: 					; makrokomandos pabaiga
	pop	ax 				; is steko isimami registru reiksmes
	pop	si
	pop	cx
endm
;---------------------------------------------------------------------------------------------------------------------------
patikrinimas2 macro skaicius1,skaicius2,galas	; mikrokomanda patikrina
local begintikrinti,tikrinti,klaida,pabaiga 	; ar pirmas skaicius > uz antraji
	push	cx 				; steke issaugomi registru reiksmes
	push	ax
	push	si
	mov	ah,skaicius1[1] 		; ah priskiriamas 1-jo skaiciaus ilgis
	mov	al,skaicius2[1] 		; al priskiriamas 1-jo skaiciaus ilgis
	cmp	ah,al 				; ilgiai palyginami tarpusavyje
	jl	klaida 				; jei 1 sk. ilgis < uz 2-jo sk.ilgio, ai pereina
                       				; prie klaida zymes
	cmp	ah,al 				; ilgiai palyginami tarpusavyje
	je	begintikrinti 			; jei ah=al pereinama prie begintikrinti
                              			; zymes
	jmp	pabaiga 			; perejimas prie mikrokomandos pabaigos
begintikrinti:
	mov	cl,skaicius1[1] 		; cl lygus 1-jo sk. ilgiui
	mov	si,2 				; si=2
tikrinti:
	mov	ah,skaicius1[si] 		; ah lygus 1-jo sk. skaitmeniui
	mov	al,skaicius2[si] 		; al lygus 2-jo sk. skaitmeniui
	cmp	ah,al 				; palyginami ah ir al
	jl	klaida 				; jei ah<al pereinama prie klaida zymes
	cmp	ah,al 				; palyginami ah ir al
	jg	pabaiga 			; jei ah>al pereinama prie makrokomados pabaigos
	inc	si 				; padidinamas poslinkis, si=si+1	
loop	tikrinti 
jmp	pabaiga 				; perejimas prie makrokomandos pabaigos
klaida: 
writeln ErrMes2					; klaidos pranesimo isvedimas	
jmp	galas					; perejimas prie programos pabaigos
pabaiga:
	pop	si 				; registru reiksmiu grazinimas is steko
	pop	ax
	pop	cx
endm
;---------------------------------------------------------------------------------------------------------------------------
sk_apdorojimas macro skaicius,chskaicius 	; skaiciaus perrasymas taip, kad jis pasislinktu prie paskutinio baito 
local	apdorojimas 
	push	cx 				; registru issaugojimas steke
	push	ax  
	push	si
	push	di
	mov	cl,skaicius[1] 			; cl lygus skaiciaus ilgiui
	mov	di,cx 				; di=cx
	inc	di 				; di=di+1
	mov	si,254 				; si=254
apdorojimas:
	mov	ah,skaicius[di] 		; ah priskiriamas skaitmuo
	mov	chskaicius[si],ah 		; i chskaicius[si] uzrasomas skaitmuo
	dec	di 				; di=di-1
	dec	si 				; si=si+1
loop	apdorojimas 				; ciklas vyksta cx kartu
	pop	di 				; registru reiksmiu grazinimas
	pop	si
	pop	ax
	pop	cx
endm
;---------------------------------------------------------------------------------------------------------------------------
.stack
;===========================================================================================================================
.data
Message1	db 'Iveskite du desimtainius skaicius (skaiciai ne ilgiau kaip 255 skaitmenys,',13,10,'pirmas skaicius didesnis uz antraji):',13,10,'$'
Enteris		db 13,10,'$' 				; perejimo i kita eilute kintamasis
sk1		db 255,255 dup (30h),'$' 		; 1-jo sk. nuskaitymo buferis
sk2		db 255,255 dup (30h),'$' 		; 2-jo sk. nuskaitymo buferis
chsk1		db 255 dup (30h),'$' 			; 1-jo sk. buferis po poslinkio
chsk2		db 255 dup (30h),'$' 			;  2-jo sk. buferis po poslinkio
nulis		db '0$'
ErrMes		db 13,10,'Klaida, neteisingas skaicius.$'     
ErrMes2		db 13,10,'Klaida, pirmas skaicius mazesnis uz antraji.$'                                                    
MesRezult	db 13,10,'Rezultatas lygus:',13,10,'$'
MesExit		db 13,10,'Isejimui paspauskite bet kuria klavysa.$'
about		db 'Dmitrij Rybakov 4gr. (3 uzd.)',13,10,'$' ; Pranesimas apie autoriu
;===========================================================================================================================
.code
pradzia:
	mov	ax,@data 			; ds segmento inicializavimas
	mov	ds,ax    
	mov 	ah, 62h  
	int 	21h
	mov 	es, bx
	mov 	si, 81h
	mov 	ah, es:[si] 			; reg ah priskiriama ivesto simbolio reiksme
	cmp 	ah, ' '				; reg ah palyginamas su ' '
	jne 	ivedimas 			; jeigu nelygu pradeti programa
	inc 	si 				; padidinamas poslinkio indeksas
	mov 	ah, es:[si] 			; ah priskiriamas kitas ivestas simbolius
	cmp 	ah, '/'				; ah palyginamas su'/'
	jne 	ivedimas 			; jei nelygu pradeti programa
	inc 	si
	mov 	ah, es:[si]
	cmp 	ah, '?' 			; ah palyginamas su'?'
	jne 	ivedimas
	mov 	dx, offset about 		; pranesimo isvedimas
	mov 	ah, 09h
	int 	21h
	jmp	exitabout 			; iseina is programos
ivedimas:
	writeln Message1	
	mov 	dx,offset sk1 			; dx priskiriamas eilutes buferio poslinkis            
    	mov 	ah, 0ah 			; i buferi nuskaitoma eilute                     
    	int 	21h
	patikrinimas1 sk1,exit 			; sk. patikrinimo makrokomandos iskvietimas 
	writeln	Enteris 			; perejimas i kita eilute
	mov 	dx,offset sk2 			; dx priskiriamas eilutes buferio poslinkis            
    	mov 	ah, 0ah 			; i buferi nuskaitoma eilute                   
    	int 	21h
	patikrinimas1 	sk2,exit 		; sk. patikrinimo makrokomandos iskvietimas 
	patikrinimas2	sk1,sk2,exit 		; makrokomados iskvietimas, ji patikrina ar 1 sk. > uz 2-aji sk.
	sk_apdorojimas	sk1,chsk1 		; makrokomandos iskvietimas pastumia skaiciu prie paskutinio baito
	sk_apdorojimas	sk2,chsk2
skaiciavimas:
	mov	cl,sk1[1] 			; cx priskiriama 1-jo sk. ilgio reiksme	
	mov	si,254 				; si=254
atimti:
	mov	ah,chsk2[si] 			; ah lygus 2-jo sk. skaitmeniui
	cmp	chsk1[si],ah 			; 1-jo sk. skaitmuo palyginamas su 2-jo sk. skaitmenimi
	jl	pliusdesimt 			; jei chsk1[si]<ah pereinama prie pliusdesimt zymes
	sub	chsk1[si],ah 			; chsk1[si]=chsk1[si]-ah
	add	chsk1[si],30h 			; chsk1[si]=chsk1[si]+30h
	dec	si 				; si=si-1	
loop atimti
jmp	paruosimas 				; pereinama prie paruosimas zymes
pliusdesimt:
	add	chsk1[si],10 			; chsk1[si]=chsk1[si]+10
	dec	si 				; si=si-1
	sub	chsk1[si],1 			; chsk1[si]=chsk1[si]-1
	inc	si 				; si=si+1 
	jmp	atimti 				; pereinama prie atimti zymes
paruosimas:
	mov	si,0 				; si=0
	mov	cx,255	 			; cx=255
	writeln	MesRezult 			; pranesimo isvedimo makrokomandos iskvietimas
pradzios_paieska:
	mov	ah,chsk1[si] 			; ah=chsk1[si]
	cmp	ah,30h 				; ah palyginamas su 30h ,t.y. 0
	jg	isvedimas 			; jei ah>30h, ai pereinama prie isvedimas 
	inc	si 				; si=si+1
loop	pradzios_paieska 			; ciklas vykdomas 255 kartu
	writeln	nulis 				; pranesimo ,kad rezultatas lygus nuliui isvedimas
	jmp	exit 				; perejimas prie programos pabaigos
isvedimas:
	writeln chsk1[si] 			; rezultato isvedimas
exit:
	writeln	MesExit 			; pranesimo isvedimas
	mov	ah,10h 
	int	16h 				; programa sustoja ir laukia kol bus paspaustas koks nors klavysas
exitabout:
	mov	ax,4c00h 			; programos pabaiga
	int	21h  
end	pradzia
