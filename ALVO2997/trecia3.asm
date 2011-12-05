SSEG    SEGMENT         STACK
        DB 256 DUP(?)
SSEG    ENDS

DSEG    SEGMENT 
        usage     db  'Usage: trecia /i in_file /o out_file$'
        file_err  db  'Input file not found$'
        creat_err db  'Error creating output file$'
        write_err db  'Error writing to file$'
        bad_input db  'Bad data format in file$'
        read_err  db  'Error reading from file$'
        num1      db  255,256 dup (0)
        num2      db  255,256 dup (0)
        fhandle   dw  0
        ffound    db  0
        out_file  db  128 dup (0)
        in_file   db  128 dup (0)
;	adresas   dw  ? 	
DSEG    ENDS

CSEG    SEGMENT
        ASSUME  CS:CSEG,DS:DSEG,SS:SSEG
        locals  @@

printf  macro buf
        lea dx,buf      ; idedame buf offseta i dx
        mov ah,9        ; funkcija, spausdinanti stringa, kuris yra ds:dx
        int 21h         ;
endm

fclose macro hndl
        mov ah,3eh      ; failo uzdarymo f-ja
        mov bx,hndl     ; ideda file handle i bx
        int 21h         ;
endm

check_n proc near
        inc di          ; di rodo bitu kieki stringe
        xor ch,ch       ; ch=0
        mov cl,[di]     ; gauname ta skaiciu
@@lp:   inc di          ; sekantis
        mov bh,[di]     ; nuskaitome simboli is skaitomo stringo
        sub bh,30h      ; atimam 30h paziuret ar tai skaitmuo
        cmp bh,10       ; ziurim ar daugau uz 10
        jb @@next       ; jei ne sokam prie sekancio skaiciaus
        sub bh,7        ; A-F atvejis
        cmp bh,16       ;
        ja @@err_n      ;
@@next:
        mov [di],bh     ;
        loop @@lp       ;
        jmp @@done      ;
@@err_n:printf bad_input ; spausdinam error message'a
        mov ah,4ch      ; uzdarom programa
        int 21h         ;
@@done:
        ret
check_n endp

START   PROC            FAR
        push ds         ;
        xor ax,ax       ; ax=0
        push ax         ;
        mov bx,dseg     ;
        mov ds,bx       ; ds=dseg

        mov al,es:[80h]         ; gaunam parametru eilutes ilgi
        cmp al,0                 ; tikrinam ar 0
        jnz parse                ; jei ne parsinam
        printf usage             ; jei taip printinam usage
        jmp done                 ; iseinam

parse:
        xor ah,ah       ;
        mov cx,ax       ; cx=ax
        mov si,81h      ; es:81h - parametru adresas

chk:
        mov ax,es:[si]  ; pasiimam 2 baitus
        cmp al,0Dh      ; jei CR - stabdom
        jz end_par      ;
        cmp ax,692Fh    ; jei '/i' 
        jz in_f         ; gaunam inputo failo pavadinima
        cmp ax,6F2Fh    ; jei '/o' 
        jz out_f        ; gaunam oututo failo pavadinima
        inc si          ; kitas baitas
        loop chk        ; loopinam...
end_par:
        cmp ffound,2    ; check if both filenames were successfully retrieved
        jz fopen        ; jei taip sokam i kita zingsni
        printf usage    ; jei ne spausdinam usage 
        jmp done        ; iseinam
in_f:
        inc si          ; kad isvengtumem nesklandumu su tarpais
        xor bx,bx       ; bx=0 skaiciuos perskaitytus baitus
        lea di,in_file  ; in_file'o offsetas 
        jmp rd
out_f:
        inc si          ; tas pac kas su in_f
        xor bx,bx       ; bx=0
        lea di,out_file ; out_file'o offsetas 
rd:
        inc si          ; si++
        dec cx          ; cx-- velesniam gryztamajam suoliui i 'loop'
        mov al,es:[si]  ; gaunam baita
        cmp al,20h      ; ziurim ar ne tarpas
        jz form_par     ;
        cmp al,0dh      ; ziurim ar CR (EOL)
        jz form_par     ;
        mov [di],al     ; uzseivinam simboli is parametru eilutes
        inc bx          ; bx++
        inc di          ; di++
        jmp rd          ;
form_par:
        cmp bx,0        ; ziurom ar bx=0
        jz rd           ; jei taip taip vadinasi inputo dar neturim
        add ffound,1    ; pazymim kad inputas jau gautas
        jmp chk         ; tesiam checkinima

fopen:
        mov ah,3dh      ; open file funkcija
        xor al,al       ; al=0 == open for reading
        lea dx,in_file  ; failo vardo offsetas 
        int 21h         ;
        jnc opened      ; jei nera erroru sokam i opened
        printf file_err ; jei yra printinam error msg
        jmp done        ; ir iseinam
opened:
        mov ffound,0    ; dabar tai bus skaiciu skaitliukas
        mov fhandle,ax  ; seivinam atidaryto failo handle'a
        push 0h         ;
        lea dx,num1     ; dx - ivedimo buderio offsetas 
        add dx,2        ;
        jmp read        ;
sec_num:
        push 0h         ;
        lea dx,num2     ; dx - ivedimo buderio offsetas 
        add dx,2        ;
read:
        mov ah,3fh      ; read from file funkcija
        mov bx,fhandle  ; dedam file handle'a i bx
        mov cx,1        ; cx - kiek baitu reikes perskaityti
        int 21h         ;
        cmp ax,cx       ; ax - perskaitytu baitu skaicius
        jne eof         ;
        pop ax          ; gaunam kiek perskaityta baitu
        inc ax          ; padidinam
        push ax         ; seivinam
        mov si,dx       ;
        inc dx          ;
        mov al,[si]     ;
        cmp al,0ah      ;
        jnz read        ;
eof:
        cmp ffound,0    ;
        jz f_num        ;
        lea di,num2     ;
        inc di          ;
        pop ax          ;
        mov [di],al     ; saugom visa stringo ilgi
        inc ffound      ; ffound++
        jmp close
f_num:
        lea di,num1     ;
        inc di          ;
        pop ax          ; pasiimam perskaitytus baitus
        sub ax,2        ; atimam du nes CR ir LF buvo priskaiciuoti
        mov [di],al     ; issaugom stringo ilgi
        inc ffound      ; ffound++
        jmp sec_num     ;
close:
        fclose fhandle  ; uzdarom faila po skaitymo
        cmp ffound,2    ;
        jz nxt          ;
        printf bad_input;
        jmp done        ;
nxt:
        lea di,num1     ;
        call check_n    ; tikrinam ar skaicius tinka
        lea di,num2     ;
        call check_n    ; tikrinam ar skaicius tinka

; skaiciavimas

        lea di,num1     ;
        inc di          ;
        mov ah,[di]     ; gaunam pirma skaiciaus ilgi
        lea di,num2     ;
        inc di          ;
        mov al,[di]     ; gaunam antro skaiciaus ilgi
        cmp ah,al       ; palyginam
        ja second       ; jei antras trumpesnis...
        jb first        ; jei pirmas trumpesnis...

; kitu atveju skaiciai lygus ir bet kuris gali buti rezultatu

first:
        xor ch,ch       ; ch=0
        mov cl,ah       ; cx=tikrinam primo skaiciausi lgi
        lea si,num1     ;
        inc si          ;
        add si,cx       ; si -> pirmo skaiciaus pabaiga
        lea di,num2     ;
;	mov adresas,di
        inc di          ;
        mov [di],byte ptr 0h ; irasom ten 0
        inc di          ;
        push di         ; isaugom offseta to ka spausdinsim
        dec di          ;
        xor ah,ah       ; ax=antro skaiciaus ilgis
        add di,ax       ; nustatom di i antro skaiciaus pabaiga
        push ax         ; issaugom ilgesnio skaiciaus ilgi
        xor ax,ax       ; ax=0
        push ax         ; push 0
        jmp long_add
second:
        xor ch,ch       ; ch=0
        mov cl,al       ; cl=antro skaiciaus ilgis
        lea di,num1
;	mov adresas,di     ;
        inc di          ;
        mov [di],byte ptr 0h ; irasom ten 0
        inc di          ;
        push di         ; isaugom offseta to ka spausdinsim
        dec di          ;
        xor bh,bh       ; bh=0
        mov bl,ah       ; bl=pirmo skaiciaus ilgis
        add di,bx       ; di -> pirmo skaiciaus pabaiga
        push bx         ; issaugom ilgesnio skaiciaus ilgi
        lea si,num2     ;
        inc si          ;
        xor ah,ah       ; ax=al
        add si,ax       ; si -> antro skaiciaus pabaiga
        xor ax,ax       ; ax=0
        mov cx, bx	;
	push ax         ;

long_add:
        mov ah,[di]     ; gaunam skaitmeni is ilgesnio skaiciaus
        mov al,[si]     ; gaunam skaitmeni is trumpesnio skaiciaus
        add al,ah       ; sudedam
        pop bx          ; paimam skaiciu is atminties
        add al,bl       ; pridedam prie sumos
        xor ah,ah       ; ax=al
        mov bh,10h      ; bh=16
        div bh          ; ax div 16
        cmp ah,10       ;
        jb dig          ; jei ah<10 tai sokam i skaitmens sukurima
        add ah,7h       ; jei ne pridedam 7h kad butu raide
dig:    add ah,30h      ; pridedam 30h kad gautumem ascii
        mov [di],ah     ; perrasom skaitmeni
        xor ah,ah       ; ax=al
        push ax         ; isimenam tai kas mintyje
        dec si          ; gryztam per baita
        dec di          ; gryztam per baita
        loop long_add   ;
rest:
        mov al,[di]     ; imam skaitmeni is ilgesnio skaiciaus
        pop bx          ; imam tai kas mintyje
        add al,bl       ; pridedam prie to ka turim
        mov bh,10h      ; bh=10h
        div bh          ; ax div 16
        cmp ah,10       ;
        jb dig2         ;
        add ah,7h       ;
dig2:   add ah,30h      ; pridedam 30h kad gauti ascii 
        mov [di],ah     ; perrasom
        ;cmp al,0        ; ziurim ar al 0
        ;jz next         ; jei taip sudetis baigta
        xor ah,ah       ; jei ne ax=al 
        push ax         ; isimenam rezultata
        dec di          ; gryztam per baita
;       	 cmp adresas,di
	je next;   
        loop rest       ;
next:
        pop cx          ; gaunam kiek skaitmenu spausdinsim
        pop si          ; gaunam skaiciaus offseta
        cmp si,di       ;
        jae sw          ;
        inc cx          ; kitu atveju padidinam isvedamu skaitmenu kieki
        jmp pr          ;
sw:
        mov di,si       ;
pr:
        push di         ; issaugom rezultato offseta
        push cx         ; ir skaitmenu kieki

        mov ah,3ch      ; sukuriame nauja faila
        xor cx,cx       ; cx=0
        lea dx,out_file ; output filename'o offset'as
        int 21h         ;
        jnc no_err      ; ziurim ar yra zaporu
        printf creat_err; spausdinam error msga
        fclose fhandle  ; uzdarom faila
        jmp done        ; ir iseinam
no_err:
        mov fhandle,ax  ; issaugom handle'a velesniam naudojimui
        mov ah,40h      ; write to file funkcija
        mov bx,fhandle  ; bx - file handle
        pop cx          ; gaunam bitu kieki, tiek reikes irasyti i faila
        pop dx          ; gaunam offseta
        int 21h         ;
        cmp ax,cx       ; ziurim ar yra klaidu
        jz wr_ok        ; jei ne sokam toliau
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