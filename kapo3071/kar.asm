.model small
.stack 1000
.data
        old db 0
	col	db 1	;spalva
	pran db 'Rase Karolis Pociunas $'
	ived	db 'Iveskite i kuria puse turetu eiti vaivorykste (kaire-"k",desne-"d",aukstyn-"a",zemyn-"z")$'
	ineil  db 255, 256 dup(0)            ;  klavet. skait. buferis
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
;=================================================================
toliau:

mov ah,0Fh			;get old video mode
int 10h

mov old,al			;dabar old saugos buvusio video rezimo numeri ..

mov ax,@data                    ; ds registro iniciavimas
mov ds, ax                      ;

start1:				

mov ah, 06h                     ; uzrasome ant ekrano #13 #10
int 21h                         ;
mov dl, 0ah                     ;
int 21h                         ;

mov dx, offset ived             ; ismeta pranesima apie eilutes ivedima
mov ah, 09h
int 21h

call ivedimas

mov ah, 06h                     ; uzrasome ant ekrano #13 #10
int 21h                         ;
mov dl, 0ah                     ;
int 21h                         ;

mov si, offset ineil
add si, 2
;==============================================================
mov ah,00h
mov al,13h		;graphics
int 10h
;==============================================================


mov ah, 'a'
mov dx,100
mov al,0
cmp [si], ah		;aukstyn
je paisoma

mov ah, 'z'
mov dx,0
mov al,0
cmp [si],ah		;zemyn
je paisomz

mov ah, 'd'
mov dx, 100
cmp [si], ah		;desnen
je paisomd

mov ah, 'k'
mov dx,0		;kairen
cmp [si],ah
je paisomk

mov dx, offset klaid                 ; ismeta pranesima apie neteisinga krypties ivedima
mov ah, 09h
int 21h
;==============================================================
;=================paisom aukstyn===============================
paisomz:
	mov ah,0Ch	;paruosiam registrus piesti taska
	mov bh,00h
	mov cx,200	;spalvotos eilutes ilgis
	
loop1: 	int 10h
loop loop1
	inc al
	inc dx		;kita eilute
	cmp dx, 100	;tikrinam ar nepasiekem galo
	je galas
	jmp paisomz

;=================paisom zemyn=================================
paisoma:
	mov ah,0Ch	;paruosiam registrus piesti taska
	mov bh,00h
	mov cx,200	;spalvotos eilutes ilgis
	
loop2:	int 10h
loop loop2
	inc al
	dec dx		;kita eilute
	cmp dx, 0	;tikrinam ar nepasiekem galo
	je galas
	jmp paisoma
	
;=========================kairen=====================
paisomk:
	mov ah,0Ch	;paruosiam registrus piesti taska
	mov al,00h	;spalva
	mov bh,00h
	mov cx,100
	
cikl1: 	int 10h
	dec dx
	cmp dx,0
	je gan1		;ciklinam paisyma iki dx=0
	jmp cikl1
gan1:	inc al
	mov dx,100
	dec cx
	cmp cx,0
	je galas	;jei cx=0 baigiam paisyti
	jmp cikl1	;jei cx<>0paisom toliau

;==========================desinen===================

paisomd:
	mov ah,0Ch	;paruosiam registrus piesti taska
	mov al,00h	;spalva
	mov bh,00h
	mov cx,0
	
cikl2: 	int 10h
	inc dx
	cmp dx,100
	je gan2		;ciklinam paisyma iki dx=0
	jmp cikl2
gan2:	inc al
	mov dx,0
	inc cx
	cmp cx,100
	je galas	;jei cx=0 baigiam paisyti
	jmp cikl2	;jei cx<>0paisom toliau


;=========================================PABAIGA=================================
galas:
	mov ah,08h	;laukia kol paspausim koki nors klavisa
	int 21h
	mov ah,00h
	mov al,old
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