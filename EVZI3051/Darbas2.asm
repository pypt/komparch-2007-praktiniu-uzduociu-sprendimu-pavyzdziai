Title 2 uzduotis

.model small    
.stack 1000     
.data           

  MAX_WIDTH  dw 320
  MAX_HEIGHT dw 200
  ten dw 10
  ilg dw 50
  pl  dw 50
  x   dw 10
  y   dw 10
  c  db 10
  maxi dw 320
  maxp dw 200

  vi  db 0
  vp  db 0
  vs  db 0

  varcol  db 0

  pra  db 13, 10, 'Programa, kuri grafiniame rezime (320x200) nubraizo staciakampi.', 13, 10, 13, 10
       db 'Parametru pavyzdys: /k 100,10 /i 50 /p 100 /s v ', 13, 10
       db '    /? - sis pagalbos tekstas ', 13, 10
       db '    /k - sio parametro pagalba galima nurodyti virsutinio tasko koordinates x,y', 13, 10
       db '         (pagal nutilejima koordinates yra 10, 10). Pvz: /k 50,50 ', 13, 10
       db '    /i - sio parametro pagalba galima nurodyti breziamo staciakampio ilgi ', 13, 10
       db '         (pagal nutilejima ilgis yra 50). Pvz: /i 100  ', 13, 10
       db '    /p - sio parametro pagalba galima nurodyti breziamo staciakampio ploti ', 13, 10
       db '         (pagal nutilejima plotis yra 50). Pvz: /p 70', 13, 10
       db '    /s - sio parametro pagalba galima nurodyti breziamo staciakampio spalva. ', 13, 10
       db '         Spalvos kodas nuo 0 iki 255. Ivedus raide v, staciakampis bus', 13, 10
       db '         spalvinamas ivairiomis spalvomis. (pagal nutilejima spalva yra 10).', 13, 10
       db '         Pvz: /p 50', 13, 10, 13, 10
       db 'Darbas2 (c) 2002 Evaldas Zilinskas', 13, 10, '$'

  kl5 db 'Blogai ivestas ilgis. Su tokiomis koordinatemis maksimalus ilgis yra $'
  kl6 db 'Blogai ivestas plotis. Su tokiomis koordinatemis maksimalus plotis yra $'
  kl  db 'Blogai ivesti parametrai.$'
  klkoord db 'Blogai ivestos koordinates.$'
  klilg db 'Blogai ivestas ilgis.$'
  klplo db 'Blogai ivestas plotis.$'
  klsp db 'Blogai ivesta spalva.$'

  buf db 4 dup (0)
  bufe db '$'

  ineil  db 40, 41 dup(0)            ;  klav. skait. buferis

.code

  main proc
    mov ax,@data 
    mov ds, ax   

    mov ah, 62h  
    int 21h

    mov es, bx   
    mov si, 80h

    mov al, es:[si]                 
    cbw
    mov cx, ax
    add cx, 80h

ieskok:
    cmp si, cx
    jae toliaut
    inc si
    cmp si, cx
    je klaida
    mov ah, es:[si]
    cmp ah, '/'
    je tikrink
    jmp ieskok

klaida:
   mov dx, offset kl
   mov ah, 09h
   int 21h
   jmp galas

tikrink:
    inc si
    mov ah, es:[si]
    cmp ah, '?'
    je klaustukas
    cmp ah, 'k'
    je koordinates
    cmp ah, 'i'
    je ilgist
    cmp ah, 'p'
    je plotist
    cmp ah, 's'
    je spalvat
    jmp klaida

klaustukas:
    mov dx, offset pra
    mov ah, 09h
    int 21h
    jmp galas

;-----------------koordinates----------------------

koordinates:
    mov x, 0
    mov y, 0
    inc si
    mov ah, es:[si]
    cmp ah, ' '
    jne klaida1t

pirma:
    inc si
    mov ah, es:[si]
    cmp ah, ','
    je antra
    cmp ah, '0'
    jae daug
    jmp klaida1

toliaut:
   jmp toliau

daug:
    cmp ah, '9'
    jbe pirmag
    jmp klaida1

pirmag:
    mov ax, x
    mul ten
    mov bx, ax
    mov al, es:[si]
    sub al, 30h
    cbw
    add bx, ax
    mov x, bx
    cmp x, 319
    ja klaida1
    jmp pirma

ilgist:
   jmp ilgis
plotist:
   jmp plotis
spalvat:
   jmp spalva
klaida1t:
   jmp klaida1

antra:
    inc si
    mov ah, es:[si]
    cmp ah, ' '
    je ieskokt
    cmp si, cx
    ja toliaut
    cmp ah, '0'
    jae daug1
    jmp klaida1

daug1:
    cmp ah, '9'
    jbe antrag
    jmp klaida1

antrag:
    mov ax, y
    mul ten
    mov bx, ax
    mov al, es:[si]
    sub al, 30h
    cbw
    add bx, ax
    mov y, bx
    cmp y, 199
    ja klaida1
    jmp antra

klaida1:
    mov dx, offset klkoord
    mov ah, 09h
    int 21h
    jmp galas


;-----------------ilgis----------------------
ilgis:
    mov ilg, 0
    mov vi, 1
    inc si
    mov ah, es:[si]
    cmp ah, ' '
    jne klaida2
    inc si
    mov ah, es:[si]
    jmp ilgp

ieskokt:
   jmp ieskok


ilgi:
    inc si
    mov ah, es:[si]
    cmp ah, ' '
    je ieskokt
    cmp si, cx
    ja toliautt
ilgp:
    cmp ah, '0'
    jae daug2
    jmp klaida2
daug2:
    cmp ah, '9'
    jbe ilgisg
    jmp klaida2
ilgisg:
    mov ax, ilg
    mul ten
    mov bx, ax
    mov al, es:[si]
    sub al, 30h
    cbw
    add bx, ax
    mov ilg, bx
    cmp bx, maxi
    ja klaida2
    jmp ilgi
klaida2:
    mov dx, offset klilg
    mov ah, 09h
    int 21h
    jmp galas

;-----------------plotis----------------------
plotis:
    mov pl, 0
    mov vp, 1
    inc si
    mov ah, es:[si]
    cmp ah, ' '
    jne klaida3
    inc si
    mov ah, es:[si]
    jmp plop

toliautt:
   jmp toliau
ieskoktt:
   jmp ieskokt

plo:
    inc si
    mov ah, es:[si]
    cmp ah, ' '
    je ieskokt
    cmp si, cx
    ja toliautt

plop:
    cmp ah, '0'
    jae daug3
    jmp klaida3
daug3:
    cmp ah, '9'
    jbe plotisg
    jmp klaida3
plotisg:
    mov ax, pl
    mul ten
    mov bx, ax
    mov al, es:[si]
    sub al, 30h
    cbw
    add bx, ax
    mov pl, bx
    cmp bx, maxp
    ja klaida3
    jmp plo

klaida3:
    mov dx, offset klplo
    mov ax, 09h
    int 21h
    jmp galas

;-----------------spalva----------------------

spalva:
    mov c, 0
    mov vs, 1
    inc si
    mov ah, es:[si]
    cmp ah, ' '
    jne klaida4
    inc si
    mov ah, es:[si]
    cmp ah, 'v'
    je various
    jmp spal

various:
    mov varcol, 1
    mov c, 0
    jmp ieskokt


spa:
    inc si
    mov ah, es:[si]
    cmp ah, ' '
    je ieskoktt
    cmp si, cx
    ja toliau
spal:
    cmp ah, '0'
    jae daug4
    jmp klaida4
daug4:
    cmp ah, '9'
    jbe spalvag
    jmp klaida4
spalvag:
    mov al, c
    cbw
    mul ten
    mov bx, ax
    xor ax, ax
    mov al, es:[si]
    sub al, 30h
    cbw
    add bx, ax
    cmp bx, 255
    ja klaida4
    mov c, bl
    jmp spa

klaida4:
    mov dx, offset klsp
    mov ah, 09h
    int 21h
    jmp galas


;------------------reziu tikrinimas-------------------------------
toliau:
    mov ax, maxi
    sub ax, x
    mov maxi, ax
    cmp ax, ilg
    jb klaida5
    mov ax, maxp
    sub ax, y
    mov maxp, ax
    cmp ax, pl
    jb klaida6
    jmp dartoliau

klaida5:
    cmp vi, 1
    je klaida51
    mov ilg, ax
    mov ax, maxp
    sub ax, y
    mov maxp, ax
    cmp ax, pl
    jb klaida6
    jmp dartoliau

klaida51:
    mov dx, offset kl5
    mov ah, 09h
    int 21h
    mov ax, maxi
    call writeskaicius
    jmp galas

klaida6:
    cmp vp, 1
    je klaida61
    mov pl, ax
    jmp dartoliau

klaida61:
    mov dx, offset kl6
    mov ah, 09h
    int 21h
    mov ax, maxp
    call writeskaicius
    jmp galas

;-----------------braizomas staciakasmpis---------------------

dartoliau:
    mov ah, 0     
    mov al, 13h
    int 10h

    mov ax, 0a000h
    mov es, ax

    mov cx ,ilg
    add cx, 2
    mov bx, x
    dec bx
    mov ax, y
    inc y 
    mov dh, 100
    call vlinija
    
     
    mov cx, ilg
    add cx, 2
    mov bx, x
    add bx, pl
    mov ax, y
    dec ax
    call vlinija
    
    mov cx, pl
    mov bx, x
    mov ax, y
    dec ax
    call Hlinija
 
    mov cx, pl
    mov bx, x
    mov ax, y
    add ax, pl
    call Hlinija

    mov cx, ilg
    mov bx, x
    mov ax, y
    mov dh, c

ciklas2:
    push cx ax bx dx	
    mov cx, pl
    call Vlinija
    pop dx bx ax cx
    cmp varcol,1
    je didinti
    jmp kitas_z
didinti:
    inc dh
kitas_z:

    inc bx
    loop ciklas2

    mov ah, 01h
    int 21h

    mov ah, 0                    
    mov al, 3h
    int 10h

galas:
    mov ah, 4ch                  
    int 21h                      
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


 writeskaicius proc           ; procedura kuri isveda skaiciu is ax registro

    mov si, offset buf        
    mov bl, ' '
    mov bh, 0

   val:
    mov [si], bl
    inc si
    inc bh
    cmp bh, 2
    jl  val

    mov si, offset bufe       
   dar:                       
    xor dx, dx                
    div ten                   
    add dl, 30h               
    dec si                    
    mov [si], dl              
    cmp ax, 0                 
    jg dar                    

    mov dx, offset buf        
    mov ah, 9h                
    int 21h                   
    ret
  endp


END
