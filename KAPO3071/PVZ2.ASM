Title 2 uþduoties pavyzdys (c) 2002 Irmantas Naujikas

.model small	; programos modëlis; "small" - nedidelëm programom
.stack 1000	; stekas
.data		; èia apraðomas duomenø segmentas

  MAX_WIDTH  dw 320
  MAX_HEIGHT dw 200

  ineil  db 40, 41 dup(0)            ;  klav. skait. buferis

.code

  main proc
    mov ax,@data                    ; ds registro iniciavimas
    mov ds, ax                      ;

    mov ah, 0			    ; ájungiam 320x200 grafiná reþimà
    mov al, 13h
    int 10h

    mov ax, 0a000h		    ; grafinës atminties segmentas
    mov es, ax

    ; paiðysim trikampá

    mov cx, 100                     ; statinio ilgis pikseliais
    mov bx, 10			    ; x - pradinë koordinatë
    mov ax, 10			    ; y - pradinë koordinatë
    mov dh, 0			    ; pradinë spalva

ciklas:
    push cx ax bx dx		    ; iðsaugom registrus
    call Hlinija		    ; paiðom linijà
    pop dx bx ax cx
    inc dh			    ; keièiam spalvà
    inc ax			    ; keièiam y koordinatæ
    loop ciklas

    ; analogiðkai paiðom kvadratà

    mov cx, 100
    mov bx, 120
    mov ax, 10
    mov dh, 0

ciklas2:
    push cx ax bx dx	
    mov cx, 100
    call Vlinija
    pop dx bx ax cx
    inc dh
    inc bx
    loop ciklas2


    ; laukiam kol bus paspaustas "enter"
    call ivedimas                   ; duomenu ivedimas

    mov ah, 0			    ; ájungiam tekstiná reþimà
    mov al, 3h
    int 10h

galas:
    mov ah, 4ch                     ; baigiam programa ir griztam i os
    int 21h                         ;
  endp

  ivedimas proc                     ; nuskaito eilute is klaviaturos
    mov dx, offset ineil            ;
    mov ah, 0ah                     ; skaitome is klaviaturos
    int 21h                         ;
    ret
  endp


  Hlinija proc                      ; bx, ax - x, y koordinates; cx - kiekis; dh - spalva
     push dx

     mul MAX_WIDTH
     add bx, ax
     mov di, bx

     pop dx
     mov al, dh

     rep stosb

     ret
  endp

  Vlinija proc                      ; bx, ax - x, y koordinates; cx - kiekis; dh - spalva
     push dx

     mul MAX_WIDTH
     add bx, ax
     mov di, bx

     pop dx

    vciklas:
     mov es:[di], dh
     add di, MAX_WIDTH
     loop vciklas

     ret
  endp


END