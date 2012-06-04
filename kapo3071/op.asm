.model small
.stack 1000
.data
	pran db 'Rase Karolis Pociunas $'
	ineil  db 255, 255 dup(0)            ;  klavet. skait. buferis
	ineil2  db 255, 255 dup(0)            ;  klavet. skait. buferis
	ived   db 'iveskite nelabai ilga skaiciu kuri dauginsim is kito skaiciaus $'
	ived   db 'iveskite kita skaiciu is kurio dauginsim $'
	sand   db 0		;sandauga
	e1 db 0			;pirmo stringo ilgis
	e2 db 0 		;antro stringo ilgis
	
.code

  ivedimas proc                     ; nuskaito eilute is klaviaturos
    mov dx, offset ineil            ;
    mov ah, 0ah                     ; skaitome is klaviaturos
    int 21h                         ;
    ret
  endp

  writeskaicius proc                 ; isveda ax i ekrana

    lea si, buf			    ; is pradziu isvalom buferi
    mov bl, ' '
    mov bh, 0
  endp

main proc
;===============================================================
mov ah, 62h		;tikrina ar nera atributu ' /?'
    int 21h

mov es,bx
mov si,80h
mov ah,es:[si]
cmp ah,3
jne toliau

inc si
mov ah,es:[si]
cmp ah,' '
jne toliau

inc si
mov ah,es:[si]
cmp ah,'/'
jne toliau

inc si
mov ah,es:[si]
cmp ah,'?'
jne toliau

mov ax,@data                    ; ds registro iniciavimas
mov ds, ax                      ;

mov dx, offset pran             ; pranesimas apie autoriu
mov ah, 09h
int 21h
jmp pab
;=========================================================pradzia

mov ax,@data                    ; ds registro iniciavimas
mov ds, ax                      ;

start1:				

mov ah, 06h                     ; uzrasome ant ekrano #13 #10
int 21h                         ;
mov dl, 0ah                     ;
int 21h                         ;
;================================pirmas skaicius
mov dx, offset ived1             ; ismeta pranesima apie eilutes ivedima
mov ah, 09h
int 21h
call ivedimas
mov ah, 06h                     ; uzrasome ant ekrano #13 #10
int 21h                         ;
mov dl, 0ah                     ;
int 21h                         ;
mov si, offset ineil
add si, 2
mov si, offset ineil	 	; suzinom eilutes ilgi	
mov al, [si+1]
mov ah, 0

mov e1,al			;1 eilutes ilgis i e1
;=================================antras skaicius

mov dx, offset ived2             ; ismeta pranesima apie eilutes ivedima
mov ah, 09h
int 21h
call ivedimas
mov ah, 06h                     ; uzrasome ant ekrano #13 #10
int 21h                         ;
mov dl, 0ah                     ;
int 21h                         ;
mov si, offset ineil	 	; suzinom eilutes ilgi	
mov al, [si+1]
mov ah, 0

mov e2,al			;1 eilutes ilgis i e2
;===================================dauginam
daug:
mov si,offset ived1
mov si,[e1]			;nurodom vienetu skaiciaus pozicija
mov dl, [si]			;vienetu skaicius i dl
sub dl,30h
mov al,dl			;skaicius vienetu pozicijoje i al

;=========================================================pabAiga

pab:	mov ah,4Ch	;baigti darba
	int 21h



END main