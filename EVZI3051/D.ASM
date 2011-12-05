.model small
.stack 1000
.data
  eil    db 'Iveskite eilute: $'
  eilpra   db 'Ivestoje eiluteje yra $'  
  eilpab   db ' mazosios raides$'

  pra db 'Mazuju raidziu nera.$'

  ineil  db 60, 61 dup(' ')         ; klavet. skait. buferis
					
  buf     db 2 dup(0)               ; buf. kur laikomas isvedamas skaicius
  bufe    db '$'                     

  yra     db 0			    ; ar yra mazuju raidziu, 0 -nera, 1 - yra/

  ten 	  dw 10			    ; apibreziam skaiciu 10 (naudosime dalybai)	

.code

  main proc
    mov ax,@data                    ; ds registro iniciavimas
    mov ds, ax                      

    mov dx, offset eil              ; uzrasome ant ekrano 'eil' turini
    mov ah, 09h                      
    int 21h                         

    call ivedimas                   ; duomenu ivedimas
    call writeln

    mov si, offset ineil            ; suzinom eilutes ilgi 
    mov al, [si+1]		    ; 2oj poz eiluites ilgis	
    mov ah, 0			    ;isvalomas ah


    cmp ax, 0                       ; ar eilute nenuline
    jle rasyk			    ; jei = 0, t.y tuscia eilute persoka	

    mov cx, ax                      ; cx - pozicija
    add cx, 1                           
    xor ax, ax                      ; nunuliname ax (ax bus mazuju raidziu skaicius)
    push ax                         ; isisisaugom ax registra i steka (kiek mazuju raidziu)

   skaiciuok:
    cmp cx, 1h                       ; ar nepasiekem galo (kai 1 baigsis perziurejimas)
    je rasyk			     ; jei = 1, t.y. visos raides jau patikrintos soka 	
    mov si, cx			     ;skaitymo buf	
    mov al, ineil[si]                ; negalima cx rasyt..

    cmp al, 61h                      ; ziurime ar simbolis >= 'a'
    jae kitas
    jmp pabaiga
kitas:
    cmp al, 7Ah                      ; ziurime ar simbolis <= 'z'
    jbe didinti
    jmp pabaiga
didinti:
  mov yra, 1                   ; yra mazuju raidziu
  pop ax                             ; paima
  inc ax                             ; ++
  push ax                            ; raso

pabaiga:
  dec cx                             ; maziname cx, t.y eilutes ilgi
    jmp skaiciuok


rasyk:                            ; jei nera mazuju raidziu isveda pra
    cmp yra, 1
    je pgalas			  ;ar yra mazuju raidziu =  
    mov dx, offset pra
    mov ah, 09h			  ; eilutes isvedimas
    int 21h
    jmp galas

pgalas:                            ; isveda kiek mazuju raidziu
  mov dx, offset eilpra
  mov ah, 09h
  int 21h
  pop ax
  call writeskaicius		   ; is ax i ekrana	
  mov dx, offset eilpab            ;dx isvedinejimas duom
  int 21h

galas:
    mov ah, 4ch                     ; baigiam programa ir griztam i dos
    int 21h
   endp

  writeln proc
    mov dl, 0dh                     ;i eilutes pradzia
    mov ah, 06h                     ;po 1 simboli isveda
    int 21h                         ;
    mov dl, 0ah                     ;permeta i kita eilute
    int 21h                         ;
    ret
  endp

  ivedimas proc                     ; nuskaito eilute is klaviaturos
    mov dx, offset ineil            ;
    mov ah, 0ah                     ; nuskaitymo proc
    int 21h                         ;
    ret
  endp

 writeskaicius proc                 ; isveda ax i ekrana

    mov si, offset bufe             ; ds:si rodys i bufe (pabaigos zenkl.)
   dar:				    ; repeat ... (ax > 0)	
    xor dx, dx                      ; nuvalomas dx (dx=0) (ax sveikoji dalis, dx- liekana)
    div ten                         ; ax := ax div 10
    add dl, 30h                     ; dl := dl + 30h (nes 0 = 30)
    dec si                          ; si := si - 1  (si--)
    mov [si], dl                    ; ds:si := dl
    cmp ax, 0                       ; if ax > 0
    jg dar                          ; then goto dar

    mov dx, offset buf              ; ds:dx rodys i buf
    mov ah, 9h                      ; spec. funkcija isvedimui
    int 21h                         ; i ekrana
    ret
  endp

END
