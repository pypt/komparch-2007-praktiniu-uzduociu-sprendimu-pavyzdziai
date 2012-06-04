; Laurynas Litvinas, Informatika IIk, 5gr.
; lauris0144@hotmail.com

; pirma uzduotis, 7 salyga
;salyga: Ivesti skaiciu ir suskaiciuoti skaitmenu suma
;sprendimas:

.MODEL small
.STACK 100h
.DATA
 msgLinija DB '================================================================================$'
 msgHelpas DB 'Pirma uzduotis. (c) Laurynas Litvinas',13,10,13,10,'Naudojimas:',13,10,'pirmas[.exe] skaicius',13,10,13,10,'Programa ishveda skaitmenu suma sheshioliktainiu bei deshimtainiu rezimu',13,10,13,10,'$'
.CODE
 mov ax,@data
 mov ds,ax  

;====================== sumavimas
 mov si, 82h	;pirmas simbolis visada tarpas
 mov al, 30h	;baveik siap sau - kad ciklas butu paprastesnis
 xor ah, ah	;ah=0, kad veliau nesimaishytu

ciklas:
 sub al, 30h	;30h - konvertuojam raides i skaicius
 cmp al, 09h	;ar tikrai rurime deshimtaini skaitmeni?
 ja klaida	;jei nedeshimtainis - skundziames apie klaida
 add bx, ax	;sumuojame
 mov al, byte ptr es:[si]	;skaitome baita
 inc si		;shokame prie sekancio baito
 cmp al, 0Dh	;gal jau galas?
jne ciklas	;jei ne tai tesiame

 mov ah, 02h	;daug naudosime 2-a dos funkcija, todel ikeliam viena syk ir visiems laikams

;====================== ishvedimas

;====================== pirmi du skaitmenys hex sistemoje

 mov cl, bh	;cl ir ch lygus vienam dideliam(?) skaiciui
 mov ch, bh
 and cl, 00001111b	;skeliam skaiciu pusiau
 and ch, 11110000b
 shr ch, 04h
 
 cmp ch, 09h	;ar pirmas skaitmuo ish skaiciu?
 ja hexas1
 add ch, 30h	;jei taip paverciam i skaiciaus simboji(char)
 jmp endhexas1
hexas1:
 add ch, 37h	;jei ne taip i raide
endhexas1:
 mov dl, ch
 int 21h

 cmp cl, 09h	;analogishkai pirmam skaitmeniui
 ja hexas2
 add cl, 30h
 jmp endhexas2
hexas2:
 add cl, 37h
endhexas2:
 mov dl, cl
 int 21h

;====================== antri du skaitmenys hex sistemoje

 mov cl, bl	;viskas analogishka pirmiems skaiciams
 mov ch, bl
 and cl, 00001111b
 and ch, 11110000b
 shr ch, 04h
 
 cmp ch, 09h
 ja hexas3
 add ch, 30h
 jmp endhexas3
hexas3:
 add ch, 37h
endhexas3:
 mov dl, ch
 int 21h

 cmp cl, 09h
 ja hexas4
 add cl, 30h
 jmp endhexas4
hexas4:
 add cl, 37h
endhexas4:
 mov dl, cl
 int 21h

;================================= 	nors ir kvaila vieta klaidos kodui
;					taciau kadangi norime ja pasiekti ir nuo pradzios ir nuo galo
;					tenka daryti nuolaidas kompiliatoriui :(
;					p.s. tai turetu ishsispresti naudojant funkcijas
 jmp endklaida	;klaidos siaip sau nerodysime
klaida:		;paaishkiname vartotojui programos vartojimo specifika
 mov ah, 9
 mov dx, OFFSET msgLinija
 int 21h
 mov dx, OFFSET msgHelpas
 int 21h
 mov dx, OFFSET msgLinija
 int 21h
 jmp galas
endklaida:
;=================================

 mov dl, ' '	;pagraziname ishvedima nurodydami skaiciavimo sistema
 int 21h
 mov dl, 'h'
 int 21h
 mov dl, 'e'
 int 21h
 mov dl, 'x'
 int 21h
 mov dl, 0Dh
 int 21h
 mov dl, 0Ah
 int 21h

;====================== desimtainis ishvedimas

 mov cx, bx	;'uzkuriam' ciklo kintamaji
 xor ax, ax	;naudosime ax ir bx deshimtainiams skaiciams atvaizduoti
 xor bx, bx	;todel juos prilyginam 0
ciklas2:	;na cia gal ir ne pats gudriausias budas paversti hex i dec, bet visai nesunkus ir greitas
 inc bl		;prie musu deshimtainio skaiciaus pridedam vieneta
 cmp bl, 9	;ar nesigavo virsh 9?
 ja des1	;jei taip, tai kankinsimes toliau
 jmp enddes1	;jei ne - suksim cikla toliau
 des1:
  inc bh	;jei buvo 10, tai vieneta keliam vyresniajam skaitmeniui
  xor bl, bl	;o pati skaitmeni prilyginam nuliui
  cmp bh, 9	;kadangi nusiuntem 'dovanele' vyriasniam skaitmeniui, teks ir ji analogishkai patikrint
  ja des2
  jmp enddes2
  des2:
   inc al	;ir taip toliau, kol...
   xor bh, bh
   cmp al, 9
   ja des3
   jmp enddes3
   des3:
    inc ah	;... pasiekiame paskutini skaitmeni.
    xor al, al
    cmp ah, 9	;jei kartais ir jis persipildytu (nors tai neimanoma del parametro eilutes limito)
    ja klaida	;darkarta paaishkinsim vartotojui kaip reikia elgtis su programa
   enddes3:
  enddes2:
 enddes1:
loop ciklas2

; po viso shito suma turetu buti deshimtaineje sistemoje, formate [ahalbhbl]

 mov cx, ax	;kadangi ax mums bus reikalingas, o cx ne - permetame duomenis
 mov ah, 02h	;surenkam savo megstamiausios funkcijos numeri

 add cx, 3030h	;paverciam skaicius i skaitmenis
 add bx, 3030h

 mov dl, ch	;ir viska ishvedame vartotojui suprantamu deshimtainiu formatu
 int 21h
 mov dl, cl
 int 21h
 mov dl, bh
 int 21h
 mov dl, bl
 int 21h
 mov dl, ' '
 int 21h
 mov dl, 'd'
 int 21h
 mov dl, 'e'
 int 21h
 mov dl, 'c'
 int 21h
 mov dl, 0Dh
 int 21h
 mov dl, 0Ah
 int 21h

;====================== galu gale programos pabaiga :)   aciu uz demesi

galas:
 mov ah, 4ch     
 int 21h        
END