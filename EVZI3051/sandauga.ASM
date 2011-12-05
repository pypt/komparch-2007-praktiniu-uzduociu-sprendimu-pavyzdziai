Title 3 uzduotis
.model small
.stack 1000
.data
   pirmsk db 100, 101 dup(?)
   antrsk db 100, 101 dup(?)
   san    db 210 dup(?)
   sane   db '$'
   apsan  db 200 dup(?)
   apsane db '$'
   minti  db 0
   sk     db 0
   ten    db 10
   ats    db 0
   max    dw 0
   c1     dw 0      
   tsi    dw 0
   pra    db 13, 10, 'Darbas3 (c) 2002 Evaldas Zilinskas', 13, 10
          db 'Programa, kuri sudaugina du ivestus skaicius.', 13, 10, '$'
   pra1   db 'Iveskite pirma skaiciu: $'
   pra2   db 'Iveskite antra skaiciu: $'
   pra3   db 'Ivestu skaiciu sandauga: $'
.code
  main proc
    mov ax, @data
    mov ds, ax

    mov ah, 62h  
    int 21h

    mov es, bx   
    mov si, 80h

    mov ah, es:[si]                 
    cmp ah, 3     
    jne toliau

    inc si
    mov ah, es:[si]                 
    cmp ah, ' '   
    jne toliau

    inc si
    mov ah, es:[si]                 
    cmp ah, '/'   
    jne toliau

    inc si
    mov ah, es:[si]
    cmp ah, '?'   
    jne toliau


    mov dx, offset pra   
    mov ah, 09h
    int 21h
    jmp galas

toliau:
    mov dx, offset pra1
    mov ah, 09h
    int 21h

    mov dx, offset pirmsk
    mov ah, 0ah
    int 21h

    call writeln

    mov dx, offset pra2
    mov ah, 09h
    int 21h


    mov dx, offset antrsk
    mov ah, 0ah
    int 21h

    call writeln
    
    xor bl, bl

    mov cl, pirmsk[1]
    mov max, cx

    mov si, max
    sub si, cx
    add si, 1

    mov cl, pirmsk[1]
    mov c1, cx

    mov cl, antrsk[1]
    

daugyba:
    inc si
    mov tsi, si

    mov di, max
    add di, 2

    mov si, cx
    add si, 1
    mov al, antrsk[si]
    mov sk, al
    sub sk, 30h

    mov si, tsi
    push si
    push cx

    mov cx, c1
pradzia:
    dec di
    inc si
    mov al, pirmsk[di]
    sub al, 30h
    mov minti, 0
    mul sk
    push si
    dec si
    mov ats, 0

daugiau:
    inc si
    xor ah, ah
    cmp ats, 0
    je tolyn
    dec si
    add al, bl
    div ten
    add ah, 30h
    mov san[si], ah
    inc si
    sub ah, 30h
    mov ats, 0
    jmp tolyn
pradzia1:
   loop pradzia
   pop cx
   pop si
   jmp daug
daugyba1:
   loop daugyba
   jmp pgalas

tolyn:
    add al, minti
    xor ah, ah
    div ten
    mov minti, al
    mov bl, san[si]
    cmp bl, 0
    je persok
    sub bl, 30h
persok:
    add bl, ah
    xor al, al
    cmp bl, 10
    jae atsinesa
    add bl, 30h
    mov san[si], bl
    xor bl, bl
    cmp minti, 0
    ja daugiau
    pop si
    jmp gal
atsinesa:
  mov ats, 1
  jmp daugiau
gal:
jmp pradzia1

daug:
  jmp daugyba1


pgalas:

    mov si, 3

kartok:
    inc si
    mov ah, san[si]
    cmp ah, ''
    jne kartok

    inc si
    mov di, 2

kartok1:
    dec si
    inc di
    mov ah, san [si]
    mov apsan[di], ah
    cmp si, 3
    jne kartok1 

    mov dx, offset pra3
    mov ah, 09h
    int 21h

    cmp pirmsk[2], '0'
    je nulis         

    cmp antrsk[2], '0'
    je nulis

    mov dx, offset apsan
    mov ah, 09h
    int 21h
    jmp galas

nulis:
    mov dl, '0'
    mov ah, 06h
    int 21h

galas:
    mov ah, 4ch
    int 21h
  endp

  writeln proc
    mov dl, 0ah
    mov ah, 06h
    int 21h
    mov dl, 0dh 
    int 21h
    ret
  endp

END
