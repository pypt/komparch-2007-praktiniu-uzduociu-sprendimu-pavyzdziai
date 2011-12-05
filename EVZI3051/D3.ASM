Title 3 uzduotis
.model small
.stack 1000
.data
   pirmsk db 100, 101 dup(?)
   antrsk db 100, 101 dup(?)
   san    db 200 dup(?)
   sane   db '$'
   minti  db 0
   sk     db 0
   ten    db 10
   max    dw 0
   pra1   db 'Iveskite pirma skaiciu: $'
   pra2   db 'Iveskite antra skaiciu: $'
.code
  main proc
    mov ax, @data
    mov ds, ax

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

    mov cl, pirmsk[1]
    mov max, cx

    mov si, max
    sub si, cx
    add si, 2

    mov di, max
    add di, 2

pradzia:
    dec di
    inc si
    mov al, antrsk[2]
    mov sk, al
    sub sk, 30h

    mov al, pirmsk[di]
    sub al, 30h

    mul sk

    cmp al, 10
    ja daugiau

    mov al, san[si]
    cmp al, 0
    je per
    sub al, 30h
per:
    add al, sk
    cmp al, 10
    ja mintyje
    add ah, 30h
    mov san[si], al
    loop pradzia
    jmp pgalas
pradzia1:
   jmp pradzia

daugiau:
    xor ah, ah
    div ten
    mov bl, san[si]
    cmp bl, 0
    je persok
    sub bl, 30h
persok:
    add bl, ah
    cmp bl, 10
    jbe persok1
    call mintyje1
    jmp toliau1
persok1:
    add bl, 30h
    mov san[si], bl
toliau1:
    inc si
    mov bl, san[si]
    dec si
    cmp bl, 0
    je persok2
    sub bl, 30h
persok2:
    add bl, al
    cmp bl, 10
    jbe persok3
    call mintyje2
    jmp toliau2

persok3:
    add bl, 30h
    inc si
    mov san[si], bl
    dec si
toliau2:
    loop pradzia1
    jmp pgalas
mintyje:
    xor ah, ah
    div ten
    add ah, 30h
    mov san[si], ah
    inc si
    mov bl, san[si]
    dec si
    sub bl, 30h
    add al, bl
    cmp al, 10
    jae mintyje
    loop pradzia1

pgalas:
    mov dx, offset san
    mov ah, 09h
    int 21h


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

  mintyje1 proc
    xor ah, ah
    mov ah, bl
    div ten
    add ah, 30h
    mov san[si], ah
    inc si
    mov bl, san[si]
    dec si
    sub bl, 30h
    add al, bl
    cmp al, 10
    call mintyje1
    ret
  endp

  mintyje2 proc
    xor ah, ah
    mov ah, bl
    div ten
    add ah, 30h
    mov san[si], ah
    inc si
    mov bl, san[si]
    dec si
    sub bl, 30h
    add al, bl
    cmp al, 10
    call mintyje2
    ret
  endp


END
