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
    jle rasyk

    mov si, offset ineil            ; eilutes ilgis
    add si, 2                           

    mov cx, ax                      ; cx - pozicija

   tarpai:
    cmp cx, 0                       ; ar nepasiekem galo
    je rasyk

    mov ah, ' '                     ; ar ne tarpas
    cmp [si], ah
    jne netarpai

    inc si
    dec cx

    cmp cx, 0                       ; ar nepasiekem galo
    je rasyk

    jmp tarpai

   netarpai:
    mov dx, 0                       ; einamo zodzio ilgis
    mov di, offset outeil           ; formuojam zodi

   zodis:
    mov ah, [si]
    mov [di], ah
    inc dx
    dec cx
    inc di
    inc si

    cmp cx, 0
    je tikrinti

    mov ah, ' '
    cmp [si], ah
    jne zodis

tikrinti:                       ;tikrina ar zodis prasideda skaiciumi
  mov ah, 30h
  tikrinti1:
    cmp outeil[0], ah
    je zodzio_galas
    inc ah
    cmp ah, 39h
    jne tikrinti1
    jmp tarpai

zodzio_galas:

    ; zodis baigesi
    mov yra[0], '1'                         ; yra zodziu prasidedanciu skaiciumi
    mov ah, '$'
    mov [di], ah

    push di
    push si
    push cx
    push dx
    push ax

    mov dx, offset eilzodis         ; uzrasome ant ekrano eilzodis turini
    mov ah, 09h                     
    int 21h                         

    mov dx, offset outeil           ; uzrasome ant ekrano outeil turini
    mov ah, 09h                     
    int 21h                         

    mov dx, offset eililgis         ; uzrasome ant ekrano eililgis turini
    mov ah, 09h                     
    int 21h                         

    pop ax
    pop dx
    push dx
    push ax

    mov ax, dx

    call writeskaicius
    call writeln


    pop ax
    pop dx
    pop cx
    pop si
    pop di

    jmp tarpai

rasyk:                            ; jei nera zodziu prasidedanciu skaicias isveda pra1
    cmp yra[0], '0'
    jne galas
    mov dx, offset pra1
    mov ah, 09h
    int 21h
   
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

 writeskaicius proc                 ; isveda ax i ekrana

    mov si, offset buf                     ; is pradziu isvalom buferi
    mov bl, ' '
    mov bh, 0

   val:
    mov [si], bl
    inc si
    inc bh
    cmp bh, 10
    jl  val

    mov si, offset bufe                    ; ds:si rodys i bufe
   dar:				    ; repeat ... (ax > 0)	
    xor dx, dx                      ; nuvalomas dx (dx=0)
    div ten                         ; ax := ax div 10
    add dl, 30h                     ; dl := dl + 30h
    dec si                          ; si := si - 1  (si--)
    mov [si], dl                    ; ds:si := dl
    cmp ax, 0                       ; if ax > 0
    jg dar                          ; then goto dar

    mov dx, offset buf                     ; ds:dx rodys i buf
    mov ah, 9h                      ; spec. funkcija isvedimui
    int 21h                         ; i ekrana
    ret
  endp


END
