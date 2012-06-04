.MODEL SMALL	
.STACK 100h
.DATA
MAX EQU 256
 promt db 'Iveskite skaiciu ',0ah,0dh,'$'
 promt1 db 'Jus ivedete ne skaiciu ',0ah,0dh,'$'
 help db 'Autorius - Andrej Ruckij',0ah,0dh
      db 'Programa papraso ivesti skaiciu ir',0ah,0dh 
      db 'paskaiciuoja skaiciaus faktoriala',0ah,0dh,'$'
 sk db MAX DUP(?),'$'
 buffer db 256 DUP(0)
 temp db 0
 tempp db 0
 ilgis db 0
 t_ilgis db 0
 II_ilgis db 0
 tempp1 db 0
 result db MAX DUP(?),'$'
.CODE
mov ax,@data
mov ds,ax
mov si,offset sk
push si		     ;laikoma pradzia skaiciaus 		

mov bl,es:[80h]
cmp bl,0             ;tikrinama is kur ivestas skaicius
 jz arciau
 jnz toliau
;---------------------------------------------------
arciau:
mov ah,09h
mov dx,offset promt
int 21h
mov ah,3Fh
mov cx,256
mov dx,offset sk
int 21h
mov cx,ax            ;ilgis skaiciaus
mov si,dx            ;skaiciaus pradzia
jmp no_tarpu         ;tikrinimas ar skaicius
;---------------------------------------------------
toliau:		     ;jei buwo ivestas kaip parametras
mov cl,es:[80h]      ;ilgis
mov di,81h           ;pirmas parametro simbolis
ivedimas:
  mov al,byte ptr es:[di]
  mov [si],al
  inc si
  inc di
  cmp al,0dh
   jne ivedimas
;--------------eilute yra jau ivesta---------------
;---------------------tarpu trinimas---------------
no_tarpu:
pop bx
push bx
mov si,bx            ;si ir bx rodo i ta pacia pradzia
floop1:
 mov al,[bx]
 cmp al,' '
  jz praleisti
  jnz nepraleisti
nepraleisti:
  mov [si],al
  inc si
praleisti:
  inc bx
  cmp al,0dh
   jz myout
   jnz floop1
myout:
pop bx               ;skaiciaus pradzia be tarpu
push bx
sub si,bx
sub si,1h
mov cx,si            ;skaitmenu skaicius
pop si
push si
;--------------------------------------------------
;------------helpas--------------------------------
mov al,[si]
 cmp al,2Fh
   jz kitaslyg
   jnz ar_sk
kitaslyg:
   call increment
   cmp al,3Fh
     jz kitaslyg1
     jnz ar_sk
kitaslyg1:
    call increment
    cmp al,0dh
      jz helping
      jnz ar_sk
helping:
    mov ah,09h
    mov dx,offset help
    int 21h
    jmp proend
ar_sk:
pop si
push si
;--------------------------------------------------
;------tikrinama ar ivestas skaicius---------------
floop2:
  mov al,[si]
 cmp al,0dh
  jz irasymas1
  cmp al,48
  jae kitastikr
  jb ispejimas
kitastikr:
  cmp al,57
   ja ispejimas
   jbe sekantis
sekantis:
   sub al,48
   mov[si],al
   inc si
   jmp floop2
ispejimas:
 mov ah,09h
 mov dx,offset promt1
 int 21h
 jmp proend
;--------------------------------------------------
;------------si turinys irasomas i di--------------
irasymas1:
pop si
push si
push cx        ;prisimenamas ilgis
irasymas:
cmp cl,0
 jz skaitliukas1
 mov al,[si]
 mov [di],al
 inc di
 inc si
 dec cx
 jmp irasymas

;--------organizuojamas skaitliukas daugybai-------
skaitliukas1:
pop cx               ;ilgis pirmo sk
mov [tempp1],cl

skaitliukas:         ;di pradzia yra 0
mov [tempp],0
mov bx,offset buffer
add bx,256            ;buferio galas
mov bp,bx
mov [t_ilgis],cl     ;rezervuojamas pradinis ilgis
pop si               ;pradzia pirmo sk
add si,cx            ;pradine pradzia
mov [II_ilgis],cl
dec si               ;pirmo sk pabaiga
dec di

fakt:
mov dl,[di]          ;imamas paskutinis skaitmuo
cmp dl,0
 jz sek11              ;atimamas 1 is kito, cia 9
 jnz sitas           ;atimamas 1 is sito
sek11:
lea dx,sek
jmp dx
nop
sitas:
 mov al,1
 sub [di],al	     ;mazinamas paskutinis skaitmuo
;========patikrinti ar nedauginam is nulio jei jis paskutinis

 mov al,[di]
 cmp al,0
  jz tikrinti
  jnz netikrinti
tikrinti:
push di
mov dx,di
mov di,00
cia:
add al,[di]
cmp di,dx
 jb toliau_tikr
 jae palyginti
toliau_tikr:
 inc di
 jmp cia
palyginti:
 cmp al,0
  jz proend1
  jnz netikr
proend1:
xor dx,dx
mov bp,si
mov si,90h
print1:
mov dl,[si]
xor ax,ax
add dl,48
 ;mov ah,02h
 ;int 21h
 mov [si],dl
 inc si
 mov ax,si
 cmp ax,bp
  jbe print1
mov si,bp
inc si
mov al,'$'
mov [si],al

 mov ah,09h
 mov dx,90h
 int 21h
 mov ax,4c00h
 int 21h
netikr:
pop di
netikrinti:
;==================================================
; iskveciama daugybos funkcija imdama si ir di
;==================================================
_mul_o_:
xor dl,dl            ;perkelimas
push bx              ;buferio pabaiga
push si              ;sk pabaiga

;daugybos funkcija
_mul_i_:
  mov al,[si]        
;  sub al,48          ;imamas paskutinis I skaitmuo
  mov ch,byte ptr [di]
;  sub ch,48
  mul ch             ;dauginamas is II paskutinio
  aam
  mov ch,00h
  add al,dl          ;perkelimas
  aaa
  add al,[bx]        ;prideti prie buferio
  aaa
  mov dl,ah          ; desimtys kitam perkelimui 
  xor ah,ah
  mov [bx],al        ; rezultatas su perkelimu i buferi
  dec bx             ; sumazinamas buferis
  dec si             ;sekantis skaitmuo I
  dec cl             ;skaitliukas pirmo ciklo
  cmp si,08fh           ; nurodo pirmo skaiciaus ilgi
   ja _mul_i_ 
  mov [bx],dl        ;jei didesnis negu duota
  cmp bx,bp
    ja nepakeisti
    jbe pakeisti
pakeisti:
  mov bp,bx	     ;kai pasibaigs abu ciklai bp laikys pradzia pirmo skaiciaus	
nepakeisti:
  pop si
  pop bx             
  dec bx             ;sumazinamas buferis
  dec di             ;kitas skaitmuo II
  mov cl,[t_ilgis]   ;ilgis I operando (ilgesnio skaiciaus)
; cl keiciasi ilgesnio operando reiksme 
; reikes padeti pirmo(ilgesnio) operando reiksme po ciklu
  dec [II_ilgis]        ;ilgis II operando (trumpesnio skaiciaus)
  mov al,[II_ilgis]
  cmp [II_ilgis],0
   ja _mul_o_
;==================================================
call atstatyti
testi1:
;==================================================
;reikia atstatyti pradzia, ilgiui rasti
;==================================================
mov si,offset sk
mov al,[bx]
call irasymas_i_sk
;==================================================
;===========buferio nuliniams======================
mov bx,191h
call apnulinimas
jmp fakt

sek:
push di
xor ax,ax
mov al,[II_ilgis]
push ax
xor ax,ax
sek1:
 mov al,10	
 mov [di],al         ;irasoma 9
 dec[II_ilgis]
 dec di
 mov al,[II_ilgis]
 cmp al,0
  jz ats
  jnz testi
testi:
  mov al,[di]
  cmp al,0
   jz sek1
   jnz maz
maz:
  sub al,1
  mov [di],al
  cmp al,0
   jz keisti_sk
   jnz nekeisti_sk
nekeisti_sk:
  pop ax
  mov [II_ilgis],al
  pop di
  jmp  fakt
keisti_sk:
  mov al,[II_ilgis]
  mov [tempp1],al
  pop ax
  pop di
  jmp fakt
ats:
;--------------------------------------------------
proend:
mov ax,4c00h
int 21h



;===========atstatyti di i gala====================
atstatyti:
xor dx,dx
a:
 inc dl
 inc di
 inc[II_ilgis]
 cmp dl,[tempp1] 
  jnz a
 mov dl,[di]
 ret
;==================================================
;==================================================
irasymas_i_sk:
xor cx,cx                      ;apnulintas cx
mov bx,bp
mov dx,291h
s:
 mov al,[bx]
 mov [si],al
 inc si
 inc bx
 inc cx
 cmp bx,dx
  jbe s
 dec si
 dec bx
 xor ax,ax
ret
;==================================================
;==================================================
apnulinimas:
mov dl,00
mov ax,bx
add ax,256
nulll:
 mov [bx],dl
 inc bx
 cmp bx,ax
   jbe nulll
dec bx
xor ax,ax
ret
;=================================================
increment:
  inc si
  mov al,[si]
ret
;==================================================
END