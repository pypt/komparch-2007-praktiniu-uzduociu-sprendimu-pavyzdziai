masm
model	small
 ; isvedimo i ekrna makrokomanda
writeln macro tekstas
mov ah,09h
lea dx,tekstas
int 21h
endm
 ; si makrokomanda perveda i desimtaine sistema
decimal macro desimbuf,numbzero
local something,laikzyme,ciklas,nextdec,more
        cmp     cx,0h
        je      something
        jmp     laikzyme
something:
        jmp     numbzero
laikzyme:
	inc	desimbuf[9] ; padidinamas 1 paskutinis buf baitas
	xor	ax,ax
        mov     ah,desimbuf[9] ; ah priskiriama buf 
			       ; reiksme
	mov	si,9h ; si=9h
	cmp	ah,3Ah ; ah palyginamas su 40h
	je	nextdec ; jei lygu pereina i nextdec
        jmp     ciklas ; pereina prie zymes ciklas
nextdec:
	mov	desimbuf[si],30h
        ;  buferio si-tajam baitui priskiriama 30h reiksme
	dec	si ; 1 sumazinamas si
more:
	inc	desimbuf[si] ; 1 padidinamas si-tasis baitas,t.y
                ; baitas,kuris yra pries ta kuris buvo
	xor	ah,ah
        mov     ah,desimbuf[si] ; ah priskiriama buf. 
				;reiksme
	cmp	ah,3Ah ; ah palyginamas su 40h
	je	nextdec ; jei lygu pereiti i nextdec
ciklas: loop    laikzyme
endm
 ; rezultato isvedimo makrokomanda:
isvesti macro dydis,rezultatas,temp,message1,message2,nowords,nul       
local isvedimas,writeilgis,nulis
isvedimas: ; eil. ilgio isvedimas desimtaine sistema
if temp EQ 0 ; jei temp = 0 tai transluojamas si dalys:
        mov     bh,dydis ; i bh idedamas ivestos eilutes ilgis
        cmp     bh,0h ; bh palyginamas su 0h
else ; kitu atveju si:
        mov     bx,dydis ; i bx idedamas ivestos eilutes ilgis
        cmp     bx,0h ; bx palyginamas su 0h
endif
        je      nulis ; jei bh=0,tai pereinama prie zymes nulis
        mov     bh,rezultatas[si] ; bh = rezultatas[si] 
	cmp	bh,30h ; bh palyginamas su 30h
	ja	writeilgis ; jei bh>30h tai pereina prie writeilgis, 			   ;t.y. jei rastas pirmas 			                   ; skaicius desimtaineje sist. > 0 ,pirmas                            ; skaiciaus skaitmuo	
	inc	si ; poslinkis padidinamas 1
	loop	isvedimas ; ciklas ivykdomas 10 kartu
nulis: ; jei eil. ilgis = 0, arba maksimumas = 0  tai isvedami pranesimai
if temp EQ 0 ; jei temp = 0 ,tai pranesimas nul isvedamas,t.y si eil. transliuojama
        writeln nul
endif
        writeln message1
        writeln nowords
	jmp	pabaiga ; pereina prie pabaiga zymes
writeilgis: ; skaiciaus rasymas i ekrana (desimtaine sistema)
        writeln message1
        writeln message2
        writeln rezultatas[si]
endm
.stack 
.data
eilute  	db 255, 255 dup(0),'$' ; klaviaturos skaitymo buferis
ilg             db (?)
transformation	db 10 dup (30h),'$' ; eil. ilgio desimtaine sistema skaiciavimo buferis
enteris		db 13, 10,'$' ; padeda pereiti i kita eilute
zodzioilgis	dw (?)	; zodzio ilgio skaiciavimo buferis
max		dw (?) ; didziausio ilgio buferis
transfzodis	db 10 dup (30h),'$' ; zodzio ilgio desimtaine sistema skaiciavimo buferis
zero            db 'Eilutes ilgis: 0 $' ; Pranesimas,kuris isvedamas jei eil. ilgis = 0
pradzia		db 'Iveskite eilute,sudaryta is zodziu,atskirtu kableliais.',13,10,'Enteris- eilutes pabaiga.',13,10,'$' ; Pradinis pranesimas
pranesimas1	db 'Eilutes ilgis(simboliu kiekis): $';Eil. ilgio pranesimas
pranesimas2	db 'Ilgiausio zodzio ilgis: $' ; Ilgiausio zodzio pranesimas
zodis		db 'Zodis:',13,10,'$'
		; Pranesimas,atskiriantis zodzius,isvestus atskiruose eilutese
nerazodziu	db 'Sioje eiluteje zodziu nerasta.$' ; Pranesimas,isvedamas jei eiluteje nerasta zodziu
isejimas	db 'Iseimui paspauskite bet kuri klavysa. $' ; Isejimo pranesimas
about		db 'Dmitrij Rybakov 4gr. (10 uzd.)',13,10,'$' ; Pranesimas apie autoriu
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
	writeln pradzia
	mov 	dx,offset eilute ; dx priskiriamas eilutes buferio poslinkis            
    	mov 	ah, 0ah                      
    	int 	21h ; i buferi nuskaitoma eilute
        mov     cl,eilute[1]
ilgis:
        decimal transformation,priskirimas
	mov	si,2h
	push	si
        mov     cl,eilute[1]
        inc     cl
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
	writeln enteris
	writeln zodis
	pop	si ; si isimamas is steko, si tai zodzio pradzios 		; poslinkis
	writeln eilute[si]
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
	mov	eilute[si],'$' ; vietoj ',' i eilutes buferi irasomas 		               ; '$'
	mov	bx,zodzioilgis ; bx priskiriama zodzio ilgio reiksme
	cmp	bx,0h ; bx palyginamas su 0
	je	bezodzio ; jei bx=0, tada pereina prie bezodzio zymes
	mov	di,si ; laikinai, di priskiriama si	
	writeln enteris
	writeln zodis
	pop	si ; is steko gaunamas zodzio pradzios poslinkis
		; buferyje
	writeln eilute[si]
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
maxtransf:
        decimal transfzodis,priskirimas
priskirimas:
	mov	cx,0Ah ; cx=0Ah, t.y kiek kartu kartosis ciklas
	mov	si,0h ; si=0h
        isvesti eilute[1],transformation,0,enteris,pranesimas1,nerazodziu,zero
maxisvedimas:
	mov	cx,0Ah ; cx=0Ah, t.y kiek kartu kartosis ciklas
	mov	si,0h ; si=0h
        isvesti max,transfzodis,1,enteris,pranesimas2,nerazodziu,zero
pabaiga: ; programos baigimas
	writeln enteris
	writeln isejimas
	mov	ah,10h 
	int	16h ;prog sustabdymas, kol nepaspaudziama kuria nors klavysa
exitabout:
	mov	ax,4c00h
	int	21h ; isejimo pertraukimas
end	main
