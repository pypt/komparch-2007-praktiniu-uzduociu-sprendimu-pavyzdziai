;Uzduotis:  desimtainiu skaiciu sandauga.
;Komandines eilutes formatas (parametru tvarka svarbi, tarpu skaicius nesvarbus):
;prog /i [inputfile] /o [outputfile]
;Abu parametrai turi buti nurodyti. Neradusi ivedimo failo programa isveda klaidos 
;pranesima. Rezultatu failas sukuriamas. Jei failas tokiu vardu jau egzistuoja, 
;rezultatai turi buti prirasomi prie failo pabaigos.



;==============================
printt macro str
   mov ah, 09h
   mov dx, offset str
   int 21h
endm
;==============================
inpoff macro offs
       mov ah,9
       mov dx,offset offs
       int 21h
endm
;==============================
.model small
.stack 256h

.data
sk1 DB 200,200 dup(0)
sk2 DB 200,200 dup(0)
ats DB 240,241 dup(0)                                              
pereit DB ' ',13,10,'$'
endln DB 13,10,'$'
rez DB 'sandauga = $'
klaida   DB 'Klaida skaitant komandine eilute',13,10,'$'
klaida1 DB 'Nerastas ivedimo failas',13,10,'$'
klaida2 DB 'Nenurodytas isvedimo failas',13,10,'$'
klaida3 DB 'Klaida nuskaitant ivedimo faila',13,10,'$'
failas1 DB 15,15 dup(0h)
failas2  DB 15,15 dup(0h)
f1handle	dw	0
f2handle	dw	0
skaiciai	db	0ffh dup(0)   ;input failo duomenys


.code
mov ax,@data
mov ds,ax

main:
         mov bx,0080h                  ;skaitoma komandine eilute
         mov cl,[es:bx]                   ;prisimenamas kom.eilutes ilgis
         cmp cl,0                            ;patikrinama ar ji netuscia
         jne patikr
         inpoff klaida                     ;jei kom. eil. tuscia
         jmp proend           

patikr:
      inc bx
      cmp byte ptr [es:bx],0dh        ;ar ne '$'
      jnz OKKk                                 ;jei ne patikr. ar toliau nera tarpu
      inpoff klaida
      jmp proend
OKKk:
      cmp byte ptr [es:bx],' '
      jz patikr                                    ;jei tarpas, patikrina sekanti
      
rask:
      cmp byte ptr [es:bx],'/'            ;surandam input ar output failo zyme
      jz toliau
      jnz patikr


toliau:
      inc bx
      mov cx,offset klaida1             ;jei nera input failo
      cmp byte ptr [es:bx],'i'            ;jei tai input failas
      jz prr1
      xor cx,cx
      mov cx,offset klaida2            ;jei nenurodytas output failas
      cmp byte ptr [es:bx],'o'          ;jei tai output failas
      jz prr2
      inpoff klaida

prr1:
        mov di,offset failas1
prep1:                                            
      inc bx
      cmp byte ptr [es:bx],' '          
      jz prep1
input:                                             ;prisimena input failo pavadinima
      cmp byte ptr [es:bx],' '          
      jz  patikr     
      mov al,byte ptr [es:bx]       
      mov [ds:di],al
      inc bx
      inc di
      jmp input

prr2:
      xor ax,ax
      mov [ds:si],al
      mov di,offset failas2
prep2:                                            
      inc bx
      cmp byte ptr [es:bx],' '          
      jz prep2
output:                                           ;prisimena output failo pavadinima
     cmp byte ptr [es:bx],' '
     jz kon2faila
     cmp byte ptr [es:bx],0dh
     jz kon2faila
     mov al, byte ptr [es:bx]
     mov [ds:di],al
     inc bx
     inc di
     jmp output

kon2faila:
     xor ax,ax
     mov [ds:di],al

open1:
     mov	ax,3D00h		;paruosiam input faila skaitymui
     mov	dx,offset failas1
     int	21h
     jnc	next1
     mov	cx,offset klaida1        ;gal toks failas neegzistuoja
     jmp	pabaiga
   
next1:
      mov     f1handle,ax
      mov     bx,ax
      lea	dx,skaiciai
      mov	ah,3fh		;saugome failo dumenis
      mov	cx,0ff00h
      int	21h


      lea       si,skaiciai                 ;i buferi 'skaiciai' irasomas input failo turinys

skaicius1:                                   ;************poka ostanovilsia zdes


skaicius2:





mov cx,0
mov ax,0

;=====================ivedami du skaiciai======================================
pirm_sk:                   ;paskutinis pirmo skaiciaus skaitmuo
cmp byte ptr [si],0dh
jz ant_sk
inc si
inc ax                     ;pirmo skaiciaus ilgis
jmp pirm_sk

ant_sk:                    ;paskutinis antro skaiciaus skaitmuo
cmp byte ptr [di],0dh
jz OK
inc di
inc cx                     ;antro skaiciaus ilgis
jmp ant_sk

OK:
;=====================atsakymo eilute uzpildoma '0'============================
mov bx,offset ats          ;aktyvuojama atsakymo eilute
     push bx               ;+++++(1)prisimenama pradine bx padetis
     push cx               ;+++++(2)prisim. II sk ilgis
     push ax               ;+++++(3)
add cl,al
mov al,0
_null:
  mov byte ptr [bx],al
  inc bx
  loop _null
inc bx
mov byte ptr [bx],'$'
dec bx

;====================== pati sandauga =========================================
    pop cx                 ;*****(3)atkuriamas I sk.ilgis
dec bx
dec si
dec di
mul_0:
  mov dl,0                 ;apnulinamas pernesimas
  push bx                  ;+++++(3)
  push cx                  ;+++++(4)
  push si                  ;+++++(5)

mul_i:
  mov al,byte ptr [si]     ;i al -> skaitmuo
  sub al,30h               ;atimam 30h -> gaunam tikra skaiciu
  dec si
  push cx                  ;+++++(6)
  mov cl,byte ptr [di]     ;reikia atimti 30h, tam kad gauti tikra skaiciu
  sub cl,30h
  mul cl                   ;i ax siunciama daugyba is II sk. sk.
  pop cx                   ;*****(6)
  aam                      ;istaisomas gautos sand. rez. 
  add al,dl                ;pridedamas su pries tai einanciu pernesimu
  aaa                      ;istaisomas sumos  rez.
  add al,[bx]              ;suma su pries tai ejusia sandauga 
  aaa
  mov dl,ah                ;prisimenamas pernesimo rezultatas
  xor ah,ah 
  mov [bx],al              ;irasomas rezultatas
  dec bx
 loop mul_i

mov [bx],dl                ;irasomas I sandaugos skaitmuo
pop si                     ;*****(5)
pop cx                     ;*****(4)
pop bx                     ;*****(3)
dec bx                     
dec di                     ;II skaiciaus sekantis skaitmuo
pop ax                     ;*****(2)
dec ax 
cmp ax,0
jz pr_print
push ax                    ;+++++(2)
jmp mul_0

;==============================print===========================================

pr_print:
pop bx                   ;*****(1)atkuriama pradine bx padetis

prover:
cmp byte ptr [bx],0
jne print
inc bx

print:
 mov ah,02h
 mov dl,byte ptr [bx]
 add dl,30h
 inc bx
 cmp byte ptr [bx],'$'
 jz  proend
 int 21h
jmp print

pabaiga:			;uzdarom failus ir griztam i os
     mov	ah,3eh
     mov	bx,f1handle
     int	21h
     mov	bx,f2handle
     int	21h
     mov	ah,4ch	;baigiam programa
     int	21h

proend:   
  mov  ah,4ch                        
  int  21h                           
end

