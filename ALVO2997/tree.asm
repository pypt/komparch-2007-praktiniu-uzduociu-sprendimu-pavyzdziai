SSEG    SEGMENT         STACK
        DB 256 DUP(?)
SSEG    ENDS

DSEG    SEGMENT
        erorr     db  'duomenys klaidingi pataisykite duomenu faila ir paleiskite programa is naujo$'
        erorr1    db  'pirma eilute mazesne uz antra pataisykite duomenu faila$'
        usage     db  'naudojima -i duomenu fsilsd -o rezultatu failas$'
        file_err  db  'duomenu failas nerastas$'
        creat_err db  'klaida sukuriant duomenu faila$'
        write_err db  'Klaida rasant ifaila$'
        bad_input db  'blogi duomenis faile$'
        read_err  db  'kaliada nuskaitant faila$'
        dem1      db  255,256 dup (0)
        dem2      db  255,256 dup (0)
        fhandle   dw  0
        ffound    db  0
        out_file  db  128 dup (0)
        in_file   db  128 dup (0)
DSEG    ENDS

CSEG    SEGMENT
        ASSUME  CS:CSEG,DS:DSEG,SS:SSEG

printf  macro buf
        lea dx,buf      ; nustatai ds poslimki
        mov ah,9        ; tai spauisdina eilute  kuri yra  ds:dx
        int 21h         ;
endm

fclose macro hndl
        mov ah,3eh      ; failo uzdarymo funkcija
        mov bx,hndl     ; padedam antraste i bx
        int 21h         ;
endm


nextl   proc      far       ;issipausdina du simbolius Odh and Oah
        push   dx           ;
        push   ax           ;
        xor    ax,ax        ;
        xor    dx,dx        ;
        mov    ah, 6        ;
        mov    dl, 0dh      ;
        int    21h          ; spausdina CR
        mov    dl, 0ah      ;
        int    21h          ; spausdina LF
        pop
        pop    dx
        ret
nextl   endp
START   PROC            FAR
        push ds             ;
        xor ax,ax           ; ax=0
        push ax             ;
        mov bx,dseg         ;
        mov ds,bx           ; ds=dseg

        mov al,byte ptr es:[80h] ; paimam parametru ilgi
        cmp al,0                 ; ar tai ne nulis
        jnz parse                ;jei ne dirbam toliau
        printf usage             ; kitaip ispausdinam daudotojo informacija
        jmp done                 ;ir uzbaigiam

parse:
        cbw                     ; ax=al
        mov cx,ax               ; cx=ax
        mov si,81h              ; es:81h - parametru adresas

chk:
        mov ax,es:[si]          ; paimam du baitus
        cmp al,0Dh              ; jei CR baigiam
        jz end_par              ;
        cmp ax,692Dh            ; jei '-i' rastas
        jz in_f                 ; paimam duomenu failo varda
        cmp ax,6F2Dh            ; jei '-o' rastas
        jz out_f                ; paima rezultatu failo varda
        inc si                  ; padidinam si
        loop chk                ; atliekam cikla kol ne 0Dh
end_par:
        cmp ffound,2            ; ar abu failai rasti
        jz fopen                ;jei taip tada tesiam toliau
        printf usage            ; kitaip isspausdinam vartotojo informacija
        jmp done                ; baigiam
in_f:
        inc si                  ; kad isvenkt nesusipratimu su tarpais
        xor bx,bx               ; bx=0 skaiciuos kiek baitu perskaiciau
        lea di,in_file          ; nustato ds poslinki
        jmp rd
out_f:
        inc si
        xor bx,bx               ; tas pats
        lea di,out_file
rd:
        inc si                  ; si++
        dec cx                  ; cx-- tam kad sugrist i  pagrindini cikla
        mov al,es:[si]          ; paimam baita
        cmp al,20h              ; ar ne tarpas
        jz form_par             ;
        cmp al,0dh              ; patikrinti CR kaip  EOL simbolio
        jz form_par             ;
        mov [di],al             ; padedam simboli is parametru eilutes
        inc bx          ; bx++
        inc di          ; di++
        jmp rd          ;
form_par:
        cmp bx,0        ; ar bx=0
        jz rd           ; jei taip tada dar neperskaiciau
        add ffound,1    ; pazymeti kad duomenu failas jau perziuretas 1 karta
        jmp chk         ; pratesti tikrinima

fopen:
        mov ah,3dh      ; atidaryti faila
        xor al,al       ; al=0 reiskia rasynui
        lea dx,in_file  ;
        int 21h         ;
        jnc opened      ; sokti jei cne klaida
        printf file_err ; ispausdinti klaidos pranesima
        jmp done        ; ir baigti
opened:
        mov ffound,0    ; dabar tai bus skaiciu skaitliukas
        mov fhandle,ax  ; issaugojam failo antraste
        push 0h         ;
        lea dx,dem1     ; susiejam dem1 su dx
        add dx,2        ;
        jmp read        ;
sec_num:
        push 0h         ;
        lea dx,dem2     ; dx susiejam su dem2
        add dx,2        ;
read:
        mov ah,3fh      ; skaitymo is failo funkcija
        mov bx,fhandle  ; padedam failo antraste i bx
        mov cx,1        ; cx - kiek reikia perskaityti
        int 21h         ;
        cmp ax,cx       ; ar yra kiek perskaite is tikro
        jnz eof         ;
        pop ax          ; paimti kiek baitu perskaitei
        inc ax          ; padidinti 1
        push ax         ; issaugoti
        mov si,dx       ;
        inc dx          ;
        mov al,[si]     ;
        cmp al,0ah      ;
        jnz read        ;
eof:
        cmp ffound,0    ;
        jz f_num        ;
        lea di,dem2     ;
        inc di          ;
        pop ax          ;
        mov [di],al     ; visos eilutes ilgi padeda
        inc ffound      ; ffound++
        jmp close
f_num:
        lea di,dem1     ;
        inc di          ;
        pop ax          ;
        sub ax,2        ; atimti du,nes  CR ir LF buvo iskaiciuoti
        mov [di],al     ; padeti faktini eilutes ilgi
        inc ffound      ; ffound++
        jmp sec_num     ;
close:
        fclose fhandle  ; usdarom faila jei sekmingai nuskaitem
        cmp ffound,2    ;
        jz nxt          ;
        printf bad_input;
        jmp done        ;
nxt:
        @@atimkit:         lea     di,dem1          ;
                  inc     di               ;
                  mov     cl,[di]
                  inc     di               ;
                  ;-------------------
                  mov     ch, 0            ;tikrinam ar ivesta skaciu eilute
@@simbol:         mov     al,[di]
                  cmp     al,30h
                  jb      @@err1
                  cmp     al,39h
                  ja      @@err1             ;jei ne tai prasome duomenis ivesti is naujo
                  inc     di
                  loop    @@simbol
                  ;----------------
                  lea     si,dem2          ;
                  inc     si               ;
                  mov     cl,[si]
                  inc     si               ;
                  mov     ch,0             ;ta pati padarome ir suantra eilute
@@simboll:        mov     al,[si]
                  cmp     al,30h
                  jb      @@err1
                  cmp     al,39h
                  ja      @@err1
                  inc     si
                  loop    @@simboll
                  jmp     @@go_on
                  ;--------
@@err1   :
                  printf erorr          ;spausdinam klaidos pranesima
                  call    nextl
                  jmp     done    ;;kadangi failas blogas baigiam programa
klaida   :
                  printf erorr
                  call    nextl
                  jmp     done  ;kadangi failas blogas baigiam programa
@@go_on:          ;lea     dx,veikia
                 ; call    printl
                  call    nextl
                  ;------
                  lea     di,dem1  ;tikrinsiu ar pirmas didesnis uz antra
                  lea     si,dem2
                  inc     si       ;sicia tikriname
                  inc     di       ;ar eiluciu ilgiai skirtingi
                  mov     ah,[si]
                  mov     al,[di]
                  cmp     al,ah
                  jb      klaida ;dem1<dem2
                  ja      skip_chek;dem1>dem2
                  ;---------------
                  xor     bx,bx
                  mov     cl,[si]    ;jei dem1=dem2 tikrinam po simboli
                  mov     ch,0     ;i cx nusiunciu dem2 eilutes ilgi
@@biskuti:        inc     si       ;tikriname po simboli
                  inc     di
                  mov     ah,[si]
                  mov     al,[di]
                  cmp     al,ah
                  jb      klaida    ;dem1<dem2
                  je      @@ciklas
                  inc     bx
                  cmp     bx,0
                  jne     skip_chek
@@ciklas:         loop    @@biskuti
                  ;-----------------
skip_chek:        lea     si,dem2
                  inc     si
                  xor     cx,cx    ;isnulinam cx
                  mov     cl,[si]  ;nusiunciu antro skaiciaus ilgi i cx
                  mov     bx,cx
                  add     bx,si
                  mov     si,bx    ;gauname kad si rodo i paskutini eilutes skaitmeni
                  ;-----------
                  lea     di,dem1
                  inc     di
                  xor     bx,bx
                  mov     bl,[di]  ;pasiekiame,kad di rodytu i paskutini
                 ; inc     di       ;eilutes simboli
                  add     bx,di
                  mov     di,bx
                  ;------------------
@@baigta:         mov     ah,[si]
                  mov     al,[di]
                  sub     al,30h ;dem1
                  sub     ah,30h ;dem2
                  cmp     al,ah
                  jb      @@skolintis ;jei al>ah tada ok,o jei ne tai reikia skolintis
pasiskolinau:     sub     al,ah
                  add     al,30h
                  mov     byte ptr ds:[di],al
                  dec     si
                  dec     di
                  loop    @@baigta ;baigta skirtumo operacija
                  jmp     i_gala
                  ;------------------
@@skolintis:      push    di
                  ;push    ax          ;visur kur sutinku 0 irasau 9
@@virsun :        dec     di
                  mov     al,[di]
                  sub     al,30h
                  cmp     al,0
                  jne     @@zemiau
                  mov     byte ptr ds:[di],39h
                  jmp     @@virsun
@@zemiau :        sub     al,1
                  add     al,30h    ;pasiskolinu ir sumazunes 1 irasau
                  mov     byte ptr ds:[di],al
                  pop     di        ;pasiimam ta simboli kuriam reikejo
                  mov     al,[di]   ;skolintis
                  sub     al,30h
                 ; pop     ax
                  add     al,10     ;pridedu 10
                  jmp     pasiskolinau  ;

i_gala:

    mov ah,3ch      ; sukuriam faila
        xor cx,cx       ; cx=0
        lea dx,out_file ; nustatom poslinki ds
        int 21h         ;
        jnc no_err      ; tikrinam klaidas
        printf creat_err; spausdinam klaidos pranesima
        fclose fhandle  ; uzdarom faila
        jmp done        ; ir iseinam
no_err:
        mov fhandle,ax  ; isissaugom antraste velesniam naud
        mov ah,40h      ; rasymo i faila funkcija
        mov bx,fhandle  ; bx - failo antraste
        lea di,dem1
        inc di
        xor cx,cx
        mov cl,byte ptr[di]   ;paimam kiek simboliu irasysim

        xor dx,dx
        inc di
        push    di
        pop dx          ;paimam iskairo pirma simboli
        int 21h         ;
        cmp ax,cx       ; kalidos tikrinimas
        jz wr_ok        ; sokti jei nelygu
        printf write_err;
        fclose fhandle  ;
        jmp done        ;
wr_ok:
        fclose fhandle  ;
        jmp done        ;
err_read:
        printf read_err ;



done:
        ret
START   ENDP
CSEG    ENDS
        END     START
