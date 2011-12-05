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
sk1 DB 227,228 dup(0Ah)
sk2 DB 227,228 dup(0Ah)
ats DB 240,241 dup(0Ah)
pereit DB ' ',13,10,'$'
Mess1 DB 'Iveskite pirma skaiciu (nuo 0 iki 225 simboliu):',13,10,'$'
Mess2 DB 'Iveskite antra skaiciu (nuo 0  iki  3 simboliu):',13,10,'$'
endln DB 13,10,'$'
rez DB 'sandauga = ',13,10,'$'

.code
mov ax,@data
mov ds,ax

   inpoff Mess1
          
          mov ah,0Ah             ;ivedamas I skaicius
          mov dx,offset sk1
          mov si,dx
          int 21h

   inpoff endln

   inpoff Mess2

 mov es,ax
          mov ah,0Ah             ;ivedamas II skaicius
          mov dx,offset sk2
          mov di,dx
          int 21h

   inpoff endln

   
add si,2
add di,2
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
dec di                     ;II skiaciaus sekantis skaitmuo
pop ax                     ;*****(2)
dec ax 
cmp ax,0
jz pr_print
push ax                    ;+++++(2)
jmp mul_0

;==============================print===========================================

pr_print:
pop bx                   ;*****(1)atkuriama pradine bx padetis
print:
 mov ah,02h
 mov dl,byte ptr [bx]
 add dl,30h
 inc bx
 cmp byte ptr [bx],'$'
 jz  proend
 int 21h
jmp print

proend:   
  mov  ah,4ch                        
  int  21h                           
end