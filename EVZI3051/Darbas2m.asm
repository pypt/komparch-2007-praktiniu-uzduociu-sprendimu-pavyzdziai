Title Pirmos uzduoties pavyzdys

.model small
.stack 1000
.data
  eil    db 'Iveskite eilute, kurioje zodziai atskirti tarpais: $'        ;  pranesimas
  eil1   db 'Ivestos eilutes ilgis: $'  ;  pranesimas
  eililgis   db 'Zodzio ilgis: $'       ;  pranesimas
  eilzodis   db 'Zodis: $'              ;  pranesimas
  pra db 'Darbas1 (c) 2002 Evaldas Zilinskas',13,10, 13, 10
      db 'Programa vartotojo papraso ivesti eilute, sudaryta is zodziu, atskirtu tarpais,', 13, 10
      db 'tada ivesta eilute suskaido i zodzius ir ispausdina ekrane zodzius kurie,', 13, 10
      db 'prasideda skaiciumi, bei salia kiekvieno zodzio isveda jo ilgi$', 13, 10

  ineil  db 40, 41 dup(0)            ;  klavet. skait. buferis

  outeil  db 50 dup (0)              ;  ats. formavimo buf.
  outeile db '$'                     ;

  buf     db 10 dup(0)
  bufe    db '$'

  ten 	  dw 10

.code

  main proc
    mov ax,@data                    ; ds registro iniciavimas
    mov ds, ax                      ;

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
    mov dx, offset eil              ; uzrasome ant ekrano eil turini
    mov ah, 09h                     ; 09h  spec. int 21h funkcija
    int 21h                         ; kuri leidzia tai padaryti

    call ivedimas                   ; duomenu ivedimas
    call writeln

    ;mov dx, offset eil1             ; uzrasome ant ekrano eil turini
    ;mov ah, 09h                     ; 09h  spec. int 21h funkcija
    ;int 21h                         ; kuri leidzia tai padaryti

    ;mov si, offset ineil            ; suzinom eilutes ilgi 
    ;mov al, [si+1]
    ;mov ah, 0

    ;push ax  ; issaugom

    ;call writeskaicius              ; isvedame ax ant ekrano
    ;call writeln

    ;pop ax ; atstatom

    cmp ax, 0   ; ar eilute nenuline
    jle galas

    ; apdorojam eilute

    mov si, offset ineil
    add si, 2

    mov cx, ax            ; cx - pozicija

    ; praleidziam tarpus

   tarpai:
    cmp cx, 0 ; ar nepasiekem galo
    je galas

    mov ah, ' '

    cmp [si], ah
    jne netarpai
    inc si
    dec cx

    cmp cx, 0 ; ar nepasiekem galo
    je galas

    jmp tarpai
   netarpai:
    mov dx, 0             ; einamo zodzio ilgis
    mov di, offset outeil ; formuojam zodi

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
    cmp ah, 3ah
    jne tikrinti1
    jmp tarpai

zodzio_galas:

    ; zodis baigesi
    mov ah, '$'
    mov [di], ah

    push di
    push si
    push cx
    push dx
    push ax

    mov dx, offset eilzodis         ; uzrasome ant ekrano eil turini
    mov ah, 09h                     ; 09h  spec. int 21h funkcija
    int 21h                         ; kuri leidzia tai padaryti

    mov dx, offset outeil           ; uzrasome ant ekrano eil turini
    mov ah, 09h                     ; 09h  spec. int 21h funkcija
    int 21h                         ; kuri leidzia tai padaryti

    call writeln


    mov dx, offset eililgis         ; uzrasome ant ekrano eil turini
    mov ah, 09h                     ; 09h  spec. int 21h funkcija
    int 21h                         ; kuri leidzia tai padaryti

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


galas:
    mov ah, 4ch                     ; baigiam programa ir griztam i os
    int 21h                         ;
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

    lea si, buf			    ; is pradziu isvalom buferi
    mov bl, ' '
    mov bh, 0

   val:
    mov [si], bl
    inc si
    inc bh
    cmp bh, 10
    jl  val

    lea si, bufe                    ; ds:si rodys i bufe
   dar:				    ; repeat ... (ax > 0)	
    xor dx, dx                      ; nuvalomas dx (dx=0)
    div ten                         ; ax := ax div 10
    add dl, 30h                     ; dl := dl + 30h
    dec si                          ; si := si - 1  (si--)
    mov [si], dl                    ; ds:si := dl
    cmp ax, 0                       ; if ax > 0
    jg dar                          ; then goto dar

    lea dx, buf                     ; ds:dx rodys i buf
    mov ah, 9h                      ; spec. funkcija isvedimui
    int 21h                         ; i ekrana
    ret
  endp


END
