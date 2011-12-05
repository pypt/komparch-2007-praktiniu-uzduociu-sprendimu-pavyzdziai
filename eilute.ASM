masm
model	small
.stack 
.data
eilute  	db 255, 255 dup(0),'$' 				; klaviaturos skaitymo buferis            
transformation	db 10 dup (30h),'$' 				; eil. ilgio desimtaine sistema skaiciavimo buferis
enteris		db 13, 10,'$' 					; padeda pereiti i kita eilute
zodzioilgis	dw (?)						; zodzio ilgio skaiciavimo buferis
max		dw (?) 						; didziausio ilgio buferis
transfzodis	db 10 dup (30h),'$' 				; zodzio ilgio desimtaine sistema skaiciavimo buferis
zero		db 'Eilutes ilgis: 0',13,10,'$' 		; Pranesimas,kuris isvedamas jei eil. ilgis = 0
pradzia		db 'Iveskite eilute,sudaryta is zodziu,atskirtu kableliais.',13,10,'Enteris- eilutes pabaiga.',13,10,'$' ; Pradinis pranesimas
pranesimas1	db 'Eilutes ilgis(simboliu kiekis): $'		;Eil. ilgio pranesimas
pranesimas2	db 'Ilgiausio zodzio ilgis: $' 			; Ilgiausio zodzio pranesimas
zodis		db 'Zodis:',13,10,'$'

nerazodziu	db 'Sioje eiluteje zodziu nerasta.$' 		; Pranesimas,isvedamas jei eiluteje nerasta zodziu
isejimas	db 'Iseimui paspauskite bet kuria klavysa. $' 	; Isejimo pranesimas
about		db 'Dmitrij Rybakov 4gr. (10 uzd.)',13,10,'$' 	; Pranesimas apie autoriu
.code
main:	
	mov	ax,@data
	mov	ds,ax ; segmentinio reg inicializavimas

	mov 	ah, 62h
	int 	21h
	mov 	es, bx
	mov 	si, 81h
	mov 	ah, es:[si] ; reg ah priskiriama ivesto simbolio reiksme
	cmp 	ah, ' '; reg ah palyginamas su ' '
	jne 	ivedimas ; jeigu nelygu pradeti programa
	inc 	si ; padidinamas poslinkio indeksas
	mov 	ah, es:[si] ; ah priskiriamas kitas ivestas simbolius
	cmp 	ah, '/'; ah palyginamas su'/'
	jne 	ivedimas ; jei nelygu pradeti programa
	inc 	si
	mov 	ah, es:[si]
	cmp 	ah, '?' ; ah palyginamas su'?'
	jne 	ivedimas
	mov 	dx, offset about ; pranesimo isvedimas
	mov 	ah, 09h
	int 	21h
	jmp	exitabout ; iseina is programos
ivedimas:
	mov	ah,09h ; pradinis pranesimas
	mov	dx,offset pradzia ; dx priskiriamas pranesimo poslinkis
	int	21h;
	xor	dx,dx ; isvalomas ax,ax=0
	mov 	dx,offset eilute ; dx priskiriamas eilutes buferio poslinkis            
    	mov 	ah, 0ah ; i buferi nuskaitoma eilute                     
    	int 	21h
	mov	si,2h ; si=2h
	push	si ; si idedamas i steka
skaiciavimas:
	pop	si ; grazinama si reiksme is steko
	mov	bh,eilute[si] ; bh priskiriama eilutes buf. reiksme                         
	inc	si ; si=si+1
	push	si ; si idedamas i steka
	cmp	bh,0Dh ; bh palyginamas su Dh,t.y su enterio reksme
	jne	ilgis ; jei nelygu pereiti i eil ilgio skaiciavima
	mov	cl,eilute[1] 
; cl priskiriamas ivestos eilutes ilgis, kuris yra 2-ame buferio baite
	inc	cl ; cl padidinamas 1
	mov	si,2h
	push	si
	jmp	writewords
ilgis:
	inc	transformation[9] ; padidinamas 1 paskutinis buf baitas
	xor	ax,ax
	mov	ah,transformation[9] ; ah priskiriama eil. ilgio buf reiksme
	mov	si,9h ; si=9h
	cmp	ah,3Ah ; ah palyginamas su 40h
	je	nextdec ; jei lygu pereina i nextdec
	jmp	skaiciavimas ; grizta i skaiciavimas
nextdec:
	mov	transformation[si],30h
;eil. ilgio buferio si-tajam baitui priskiriama 30h reiksme
	dec	si ; 1 sumazinamas si
more:
	inc	transformation[si] ; 1 padidinamas si-tasis baitas,t.y
                ; baitas,kuris yra pries ta kuris buvo
	xor	ah,ah
	mov	ah,transformation[si] ; ah priskiriama eil. ilgio buf. reiksme
	cmp	ah,3Ah ; ah palyginamas su 40h
	je	nextdec ; jei lygu pereiti i nextdec
	jmp	skaiciavimas ; grizta i skaiciavimas
writewords:     ;eil. ilgio isvedimas
	mov	bh,eilute[si] ; bh priskiriama eilutes buf reiksme
	inc	zodzioilgis ; 1 padidinamas zodzio ilgio buferis
	cmp	bh,',' ; bh palyginamas su ','
	je	writeenter ; jei lygu pereina prie writeenter zymes
	cmp	bh,0Dh ; bh palyginamas su 13h
	je	dollar ; jei lygu preina prie dollar zymes
	jmp	toliau ; pereina prie zymes toliau
dollar:
	mov	eilute[si],'$' ; vietoj ',' i eil buf rasomas '$'
	jmp	toliau ; pereina prie zymes toliau
toliau:
	inc	si ; si=si+1
atgal:	loop	writewords ; ciklas atleikamas cx kartu
	xor	bx,bx ; bx=0
	mov	bx,zodzioilgis ; bx priskiriama zodzio ilgio reiksme
	cmp	bx,1h ; bx palyginamas su 1h
	je	irdartoliau ; jei lygu pereina prie irdartoliau zymes
	mov	ah,09h
	mov	dx,offset enteris ; pereina i kita eilute
	int	21h
	mov	dx,offset zodis ; isvedamas pranesimas
	int	21h
	pop	si ; si isimamas is steko, si tai zodzio pradzios poslinkis
	lea	dx,eilute[si] ; dx prirskiriamas zodzio poslinkis
	int	21h ; zodzio isvedimas
	dec	zodzioilgis ; zodzio ilgio buf mazinamas 1
	mov	bx,zodzioilgis ; bx priskiriamas zodzioilgis
	cmp	bx,max ; bx palyginamas su didziausio zodzio buferiu
	ja	chmaxlast ; jei bx>max, tai pereiti prie zymes chmaxlast	
	jmp	irdartoliau ; perejimas prie zymes irdartoliau
chmaxlast: ; maksimumo pakeitimas nauju
	mov	max,bx ; max=bx
irdartoliau:	
	mov	cx,max ; cx priskiriamas didziausio zodzio ilgis
	jmp	maxtransf ; pereina prie zymes maxtransf
writeenter: ; isvedamas atskiras zodis
	dec	zodzioilgis ; zodzioilgis = zodzioilgis-1, kad neskaiciuoti skirtuko
	mov	bx,zodzioilgis ; bx priskiriama zodzioilgis
	cmp	bx,max ; bx palyginamas su maksimumu
	ja	chmax ; jei bx>max ,tai pereina prie chmax zymes
	jmp	dartoliau ; pereina prie dartoliau zymes
chmax: ; maksimumo pakeitimas i bx
	mov	max,bx ;buf. max priskiriama bx
dartoliau:
	mov	eilute[si],'$' ; vietoj ',' i eilutes buferi irasomas '$'
	mov	bx,zodzioilgis ; bx priskiriama zodzio ilgio reiksme
	cmp	bx,0h ; bx palyginamas su 0
	je	bezodzio ; jei bx=0, tada pereina prie bezodzio zymes
	mov	di,si ; laikinai, di priskiriama si	
	mov	ah,09h
	mov	dx,offset enteris ; pereinama i kita eilute
	int	21h
	mov	dx,offset zodis ; isvedamas pranesimas, atskiriantis zodzius 
	int	21h
	pop	si ; is steko gaunamas zodzio pradzios poslinkis buferyje
	lea	dx,eilute[si] ; dx perduodamas zodzio poslinkis
	int	21h ; zodis isvedamas	
	mov	si,di ; grazinama si reiksme
	inc	si ; si padidinama 1
	push	si ; si idedamas i steka
	mov	zodzioilgis,0h ; zodzio ilgio buf. lygus 0
	jmp	atgal ; grizta prie zymes atgal
bezodzio: ; Jei tarp skirtuku zodzio nera, tai: 
	mov	di,si ; laikinai, di priskiriama si
	pop	si ; gaunama is steko si 
	mov	si,di ; si=di
	inc	si ; si padidinamas vienetu
	push	si ; si idedamas i steka
	jmp	atgal ; pereina prie zymes atgal
maxtransf: ; maksimumo transformavimas i desimtaine sistema
	cmp	cx,0h ; cx lyginamas su 0 
	je	priskirimas ; jei cx=0 tai pereina prie zymes priskyrimas
	inc	transfzodis[9] ; paskutinis didziausio zodzio ilgio buferio baitas padidinamas 1
	xor	ax,ax ; ax=0
	mov	ah,transfzodis[9] ; ah priskiriama paskutinio baito reiksme
	mov	si,9h ; si=9
	cmp	ah,3Ah ; ah palyginamas su 3Ah
	je	nextdec2 ; jei ah=3Ah tai pereina prie zymes nextdec
atgal2:
	loop	maxtransf ; ciklas
	jmp	priskirimas ; pereina prie zymes priskirimas
nextdec2: 
	mov	transfzodis[si],30h ; transfzodis[si]=30h
	dec	si ; si=si-1
more2:
	inc	transfzodis[si] ; padidinamas baitas esantis pries buvusiji
	xor	ah,ah ; ah=0
	mov	ah,transfzodis[si] ; ah priskiriamas transfzodis[si]
	cmp	ah,3Ah ; ah palyginamas su 3Ah
	je	nextdec2 ; jei ah=3Ah, tai pereina prie nextdec2
	jmp	atgal2 ; grizta prie atgal2
priskirimas:
	mov	cx,0Ah ; cx=0Ah, t.y kiek kartu kartosis ciklas
	mov	si,0h ; si=0h
isvedimas: ; eil. ilgio isvedimas desimtaine sistema
	mov	bh,eilute[1] ; i bh idedamas ivestos eilutes ilgis
	cmp	bh,0h ; bh palyginamas su 0h
	je	nulis ; jei bh=0, t.y. eilutes ilgis =0 ,tai pereinama prie zymes nulis
	mov	bh,transformation[si] ; bh = transformation[si] 
	cmp	bh,30h ; bh palyginamas su 30h
	ja	writeilgis ; jei bh>30h tai pereina prie writeilgis, t.y. jei rastas pirmas 			   ; skaicius desimtaineje sist. > 0 ,pirmas skaiciaus skaitmuo	
	inc	si ; poslinkis padidinamas 1
	loop	isvedimas ; ciklas ivykdomas 10 kartu
writeilgis: ; skaiciaus rasymas i ekrana (desimtaine sistema)
	mov	ah,09h
	mov	dx,offset enteris ; pereinama i kita eilute
	int	21h
	mov	dx,offset pranesimas1 ; isvedamas pranesimas
	int	21h
	lea	dx,transformation[si] ; i dx perduodamas skaiciaus poslinkis
	int	21h ; i ekrana isvedamas eil. ilgis desimtaine sistema
	mov	cx,0Ah ; cx=0Ah
	mov	si,0h ; si=0h
	jmp	maxisvedimas ; pereinama prie maxisvedimas zymes
nulis: ; jei eil. ilgis = 0, tai isvedami pranesimai
	mov	ah,09h
	mov	dx,offset zero
	int	21h
	mov	dx,offset nerazodziu
	int	21h
	jmp	pabaiga ; pereina prie pabaiga zymes
maxisvedimas: ; maksimalaus ilgio isvedimas
	mov	bx,max ; bx=max
	cmp	bx,0h ; bx palyginamas su 0h
	je	nerzodz ; jei bx=0h, tai pereinama prie nerzodz zymes
	mov	bh,transfzodis[si] ; bh	 = transfzodis[si]
	cmp	bh,30h ; bh palyginamas su 30h
	ja	writemax ; jei bh>30h, tai pereinama prie writemax zymes
	inc	si ; poslinkis padidinamas 1
	loop	maxisvedimas ; ciklas ivykdomas 10 kartu
nerzodz: ; jei zodziu nera, isvedami pranesimai:
	mov	ah,09h
	mov	dx,offset enteris
	int	21h
	mov	dx,offset nerazodziu
	int	21h
	jmp	pabaiga
writemax: ; maksimumo rasymas i ekrana desimtaine sistema
	mov	ah,09h
	mov	dx,offset enteris ; pereinama i kita eilute
	int	21h 
	mov	dx,offset pranesimas2 ; isvedamas pranesimas
	int	21h
	lea	dx,transfzodis[si] ; dx perduodamas maksimumo poslinkis
	int	21h ; maksimumas isvedamas i ekrana
	jmp	pabaiga ; pereina prie pabaiga zymes
pabaiga: ; programo baigimas
	mov	ah,09h
	mov	dx,offset enteris ; pereina i kita eilute
	int	21h
	mov	dx,offset isejimas ; pranesimo isvedimas
	int	21h
	mov	ah,10h 
	int	16h ;prog sustabdymas, kol nepaspaudziama kuria nors klavysa
exitabout:
	mov	ax,4c00h
	int	21h ; isejimo pertraukimas
end	main
