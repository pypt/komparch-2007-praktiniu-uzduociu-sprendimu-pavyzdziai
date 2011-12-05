.model small
.stack 1000
.data 
        cln     dw 20 
	col	db 69	;spalva
	pran db 'Rase Karolis Pociunas $'
	ived	db 'Iveskite i kuria puse turetu eiti vaivorykste (kaire-"k",desne-"d",virsus-"v",apacia-"a")$'
	ineil  db 40, 41 dup(0)            ;  klavet. skait. buferis
	klaid  db 'ivestas blogas pasirinkimas$'
	dar    db 'dar karta (y/n)?$'
.code

  ivedimas proc                     ; nuskaito eilute is klaviaturos
    mov dx, offset ineil            ;
    mov ah, 0ah                     ; skaitome is klaviaturos
    int 21h                         ;
    ret
  endp

main proc

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

mov dx, offset pran                 ; 
mov ah, 09h
int 21h
jmp galas

toliau:



mov ax,@data                    ; ds registro iniciavimas
mov ds, ax                      ;


mov dx, offset ived                 ; ismeta pranesima apie eilutes ivedima
mov ah, 09h
int 21h
start1:
call ivedimas

mov dl, 0dh                     ;
    mov ah, 06h                     ; uzrasome ant ekrano #13 #10
    int 21h                         ;
    mov dl, 0ah                     ;
    int 21h                         ;

mov si, offset ineil
add si, 2

	mov ah,0		
	mov al,13h		;graphics
	int 10h

mov ah, 'a'	
cmp [si], ah		;virsun
je paisoma

mov ah, 'z'
cmp [si],ah		;zemyn
je paisomz
		
mov ah, 'd'
cmp [si], ah		;desnen
je paisomd

mov ah, 'k'
cmp [si],ah
je paisomk

mov dx, offset klaid                 ; ismeta pranesima apie neteisinga krypties ivedima
mov ah, 09h
int 21h

jmp galas
paisoma:

        mov cx,50
loop1:  mov dx, cln
	mov ah,0ch	;naudojama funkcija 0CH
        mov al,col       ;spalva
	int 10h		;paiso taska
loop loop1              ;ciklinam ir paisom linija
        dec cln         ;bandom pereiti prie kitos linijos aukstyn
        dec col
        cmp cln,0
        je galas
        jmp paisoma

paisomz: mov cx,50

loop2:  mov dx, cln
	mov ah,0ch	;naudojama funkcija 0CH
        mov al,col       ;spalva
	int 10h		;paiso taska
loop loop2              ;ciklinam ir paisom linija
        inc cln         ;bandom pereiti prie kitos linijos zemyn
        dec col
        cmp cln,0
        je galas
        jmp paisomz


paisomd: mov cx,cln
loop3:
	mov dx, 219
	mov ah,0ch	;naudojama funkcija 0CH
        mov al,col       ;spalva
	int 10h		;paiso taska
loop loop3              ;ciklinam ir paisom linija
        inc cln         ;bandom pereiti prie kito stulpelio desnen
        dec col
        cmp cln,0
        je galas
        jmp paisomd


paisomk: mov cx,cln
loop4:  mov dx, 219
	mov ah,0ch	;naudojama funkcija 0CH
        mov al,col       ;spalva
	int 10h		;paiso taska
loop loop4              ;ciklinam ir paisom linija
        dec cln         ;bandom pereiti prie kito stulpelio kairen
        dec col
        cmp cln,0
        je galas
        jmp paisomk



galas: 
	mov ah,08h	;laukia kol paspausim koki nors klavisa
	int 21h
	mov ah,0
	mov al,3
	int 10h

	mov dx, offset dar                 ; klausia ar kartoti dar karta
	mov ah, 09h
	int 21h
	call ivedimas

	mov si, offset ineil
	add si, 2
	mov ah, 'y'
	cmp [si],ah
	jne pab
        jmp start1


pab:	mov ah,4Ch	;baigti darba
	int 21h
endp


END main

	
