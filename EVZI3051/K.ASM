Title Pirmos uzduoties pavyzdys

.model small
.stack 1000
.data
  eil    db 'Iveskite eilute, kurioje zodziai atskirti tarpais: $'
  eil1   db 'Ivestos eilutes ilgis: $'  
  eililgis   db ', jo ilgis - $'
  eilzodis   db 'Zodis prasidedantis skaiciumi: $'

  pra  db 'Programa vartotojo papraso ivesti eilute, sudaryta is zodziu, atskirtu tarpais,', 13, 10
       db 'tada ivesta eilute suskaido i zodzius ir ispausdina ekrane zodzius kurie,', 13, 10
       db 'prasideda skaiciumi, bei salia kiekvieno zodzio isveda jo ilgi', 13, 10, 13, 10
       db 'Darbas1 (c) 2002 Evaldas Zilinskas$', 13, 10
  n    db 'nulis$'
  v    db 'vienas$'
  d    db 'du$'
  t    db 'trys$'
  k    db 'keturi$'
  p    db 'penki$'
  s    db 'sesi$'
  se   db 'septyni$'
  a    db 'astuoni$'
  de   db 'devyni$'


  pra1 db 'Zodziu prasidedanciu skaiciais nera.$'

  ineil  db 40, 41 dup(0)            ; klavet. skait. buferis

  outeil  db 50 dup (0)              ; ats. formavimo buf.
  outeile db '$'                     

  buf     db 10 dup(0)               ; buf. kur laikomas isvedamas skaicius
  bufe    db '$'                     

  yra     db 1 dup (0)               ; Ar yra zodziu prasidedanciu skaiciumi?

  ten 	  dw 10

.code

  main proc
    mov ax,@data                    ; ds registro iniciavimas
    mov ds, ax                      

    mov yra[0], '0'                 ; pradine yra reiksme

    mov ah, 62h                     ; irasoma i bx parametrai 
    int 21h

    mov es, bx                      ; bx perkelia i es
    mov si, 80h

    mov ah, es:[si]                 
    cmp ah, 3                       ; tikrina parametro ilgi
    jne toliau

    inc si
    mov ah, es:[si]                 
    cmp ah, ' '                     ; tikrina ar pirmas parametro simbolis tarpas
    jne toliau

    inc si
    mov ah, es:[si]                 
    cmp ah, '/'                     ; tirina ar antras simbolis '/'
    jne toliau

    inc si
    mov ah, es:[si]
    cmp ah, '?'                     ; tikrinas ar trecias simbolis '?'
    jne toliau


    mov dx, offset pra              ; jei parametrai ' /?' isveda pra
    mov ah, 09h
    int 21h
    jmp galas

  toliau:
    mov dx, offset eil              ; uzrasome ant ekrano eil turini
    mov ah, 09h                      
    int 21h                         

    call ivedimas                   ; duomenu ivedimas
    call writeln

    mov si, offset ineil            ; suzinom eilutes ilgi 
    mov al, [si+1]
    mov ah, 0

    cmp ax, 0                       ; ar eilute nenuline
    jle galas

    mov si, offset ineil            ; eilutes ilgis
    add si, 2                           

    mov cx, ax                      ; cx - pozicija

    mov di, 02h
  tikrinti:
    mov yra[0], '0'
    cmp ineil[di], 30h
    je rasykn
    jmp rasykv
   rasykn:
     mov dx, offset n
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasykv:
    cmp ineil[di], 31h
    je rv
    jmp rasykd
   rv:
     mov dx, offset v
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasykd:
    cmp ineil[di], 32h
    je rd
    jmp rasykt
    rd:
     mov dx, offset d
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasykt:
    cmp ineil[di], 33h
    je rt
    jmp rasykk
   rt:
     mov dx, offset t
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasykk:
    cmp ineil[di], 34h
    je rk
    jmp rasykp
   rk:
     mov dx, offset k
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasykp:
    cmp ineil[di], 35h
    je rp
    jmp rasyks
     rp:
      mov dx, offset p
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasyks:
    cmp ineil[di], 36h
    je rs
    jmp rasykse
    rs:
     mov dx, offset s
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasykse:
    cmp ineil[di], 37h
    je rse
    jmp rasyka
    rse:
     mov dx, offset se
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasyka:
    cmp ineil[di], 38h
    je ra
    jmp rasykde
    ra:
     mov dx, offset a
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasykde:
    cmp ineil[di], 39h
    je rde
    jmp rasyk
    rde:
     mov dx, offset de
     mov ah, 09h
     int 21h
     jmp pabaiga
   rasyk:
    mov dl, ineil[0]                  ;
    mov ah, 06h                     ; uzrasome ant ekrano #13 #10
    int 21h
   pabaiga:
    inc di
    cmp di, si
    jne tikrinti
    jmp galas
     
galas:
    mov ah, 4ch                     ; baigiam programa ir griztam i dos
    int 21h
   endp


  writeln proc
    mov dl, 0dh                     ;
    mov ah, 06h                     ; uzrasome ant ekrano #13 #10
    int 21h                         ;
    mov dl, 0ah                     ;
    int 21h                         ;
    ret
  endp

  ivedimas proc                     ; nuskaito eilute is klaviaturos
    mov dx, offset ineil            ;
    mov ah, 0ah                     ; skaitome is klaviaturos
    int 21h                         ;
    ret
  endp


END
