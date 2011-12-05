Title Trecia uzduotis

.model small  ;bus tik vienas duomenu segm. ir vienas kodo segmentas (ne daugiau 64kb)

.stack 1000   ;aprasomas stekas, dydis  1000 baitu

.data         ; duomenu segmento pradzia
pagalbos_txt        db  'antra.exe - programa piesianti ka nors kieto', 10, 13
                    db  ' Programos vartojimas:', 10, 13
                    db  '   trecia.exe /?', 10, 13
                    db  '       - isveda si pagalbos pranesima', 10, 13
                    db  'sia programa rase Ieva Gudmonaite' , 10, 13
                    db  'programu sistemu 1 grupe:)', 10, 13
                    db '$'
kom_eilutes_klaida  db 'Nesuprasta komandine eilute!', 10, 13, '$'                    
buferis             db 0FFh ;max reiksme 255
buf_ilgis           db ? ;nzn pradines reiksmes
ivesta_eilute       db 255 DUP(?) ;255 simboliai,kuriems pradine reiksme nepriskirta
skaicius1           db 255 DUP(0) ;pradine reiksme 255 nuliai
skaicius2           db 255 DUP(0)
suma                db 255 DUP(0)
ivesk_skaiciu_msg   db 'Ivesk sesioliktaini skaiciu: ', '$'
ne_skaicius_msg     db 'Galima ivesti tik sesioliktaini skaiciu!', 10, 13, '$'
newline             db 10, 13, '$'
pernasa             db 0
perpild_msg         db 'Perpildymas!', 10, 13, '$'
.code   

main proc  ;proceduros pradzia
     mov    ax,@data                    ; ds registro iniciavimas
     mov    ds, ax                      ; duomenu segmento registrui priskiria ax
     call   komandine_eilute            ; iskviecia proc pavadinimu komandine eilute
     mov    di, OFFSET skaicius1        ; iveda skaicius1
     call   ivesti
     mov    di, OFFSET skaicius2        ; iveda skaicius2
     call   ivesti
     mov    si, OFFSET skaicius1        ; adresa pirmo sk i si
     mov    bx, OFFSET skaicius2        ; antro - i bx
     mov    di, OFFSET suma             ; suma - i di
     call   sudeti
     mov    si, OFFSET suma             ; skaicius, kuri spausdina turi buti si
     call   spausd  
     mov    ax, 4c00h                   ; Uzbaigiam programa
     int    21h
endp

komandine_eilute proc       ;procedura skirta pagalbos isvedimui, jeigu to reikia
     ; ES segmentinis registras dabar rodo i programos PSP, kuriame tarp kitko yra ir
     ; komandines eilutes parametrai
     mov    al, es:[80h]   ; i AL padeda baita adresu ES:80h
     cmp    al, 0          ; patikriname ar yra kas nors komandineje eiluteje
     je     nera_eilutes
     ; Kazkas komandineje eiluteje yra, patikriname, ar tai raktas
     cmp    byte ptr es:[82h], '/' ;nurodo, kad paimam viena vieninteli baita
     jne    bloga_eilute
     cmp    byte ptr es:[83h], '?'
     jne    bloga_eilute
     call   pagalba
nera_eilutes:     
     ret
bloga_eilute:     
     mov    ah, 09h
     mov    dx, OFFSET kom_eilutes_klaida
     int    21h
     call   pagalba
     ret
endp

pagalba proc ;iskviecia, jeigu ivedi nesamone arba klaustuka
     mov    ah, 09h
     mov    dx, OFFSET pagalbos_txt ;i dx patalpina kintamojo adresa ofseta
     int    21h
     mov    ax, 4c00h ;Uzbaigiam programa
     int    21h
     ret
endp

; Iveda sesioliktaini skaiciu, max leistinas ilgis - 255 simboliai
; DI - skaiciaus pradzios adresas
ivesti proc
    mov     ah, 09h
    mov     dx, OFFSET ivesk_skaiciu_msg ;ismeta pranesima, kad ivestu skaiciu; 
    int     21h
    ; Ivedame eilute
    mov     ah, 0Ah ;0Ah - iveda simboliu eilute
    mov     dx, OFFSET buferis
    int     21h
    ; Pereiname i nauja eilute ; kursorius nusoka i nauja eilute
    mov     ah, 09h
    mov     dx, OFFSET newline
    int     21h
    mov     ch, 0
    mov     cl, [buf_ilgis] ;i cl prisiskiriame reiksme, kiek simboliu ka tik ivedeme
    cmp     cl, 0 ;jei nieko neivedeme
    je      blogas_skaicius
    ; Patikriname duomenis ir kopijuojame ivesta info ;simbolius paverciame i sk ir apverciame eilute
    mov     si, OFFSET ivesta_eilute ;si rodo i ivestos eilutes pirma simboli
    add     di, cx ;prie pradzios adreso pridedame sk ilgi 
    dec     di ;atimame 1 vieneta ir gauname vyriausios skilties adresa
kartojam:    
    mov     al, [si]  ; Pasiimam simboli
    cmp     byte ptr al, '0'     ; patikriname, ar tai desimtainis skaitmuo
    jb      gal_16
    cmp     byte ptr al, '9'
    ja      gal_16
    ; al - desimtainis skaitmuo
    ; paverciam ji is skaitmens kodo i pati skaitmeni
    sub     al, '0'
    jmp     SHORT kitas_simbolis
gal_16:
    cmp     byte ptr al, 'a'   ; patikriname ar tai a-f sesioliktainis skaitmuo
    jb      gal_did_16
    cmp     byte ptr al, 'f'
    ja      gal_did_16
    ; al -  a..f skaitmuo
    sub     al, 'a' ;al atima a ir gauna tarp 0 ir 5
    add     al, 0Ah ;dar prideda 10, kad gautusi teisingas skaitmuo
    jmp     SHORT kitas_simbolis
gal_did_16:
    cmp     byte ptr al, 'A'   ; Patikriname ar tai A-F sesioliktainis skaitmuo
    jb      blogas_skaicius
    cmp     byte ptr al, 'F'
    ja      blogas_skaicius
    ; al - A..F skaitmuo
    sub     al, 'A'
    add     al, 0Ah
kitas_simbolis:    
    mov     [di], al ;baitui, esanciam adresu di, priskiria reg al
    dec     cl ;simboliu sk sumaziname 1
    cmp     cl, 0
    je      baigiam
    inc     si ;persokam prie kito skaitmens
    dec     di ;di sumazinam vienetu, pereinam viena vieta auksciau
    jmp     kartojam ;skaitom antra skaitmeni
baigiam:
    ret ;iseina is proceduros
blogas_skaicius:
    mov     ah, 09h
    mov     dx, OFFSET ne_skaicius_msg
    int     21h
    mov     ax, 4c00h
    int     21h
endp

; Spausdina sesioliktaini skaiciu
; pradzia - [SI]
spausd proc
    mov     bx, si  ; Issaugom skaiciaus pradzios adresa
    add     si, 253 ; Persokam i skaiciaus gala
    ; Praleidziam visus nulius skaiciaus priekyje
    ; Arba kol liks tik vienas skaitmuo
praleidziam_nulius:
    cmp     byte ptr [si], 0
    jne     nuliai_baigesi
    cmp     bx, si ;patikrina, ar nepasibaige skaitmenys
    je      nuliai_baigesi
    dec     si
    jmp     praleidziam_nulius
nuliai_baigesi:
    mov     ah, 02h
    ; Spausdinam visus likusius skaitmenis
kitas_skaitmuo:    
    mov     dl, [si]
    cmp     dl, 0Ah ; ar skaitmuo 0..9 ar A..F ?
    jae     spausd_AF
    add     dl, '0' ;parengiam spausdinimui skaitmenis
    jmp     spausdinam
spausd_AF:
    add     dl, 'A' ;is skaitmens kodo "padaro" raide
    sub     dl, 0Ah 
spausdinam:
    int     21h ;isveda simboli esanti dl
    dec     si
    cmp     bx, si ;patikrina ar nepasibaige skaitmenys
    jbe     kitas_skaitmuo
    mov     ah, 09h
    mov     dx, OFFSET newline
    int     21h    
    ret
endp
    
; Sudeda [SI] ir [BX] i [DI]
sudeti proc
    mov     cx, 254 
    mov     dx, 16 ;pagalbine reiksme, daliklis
sudedam_kita:    
    mov     ah, 0
    mov     al, [si]
    add     al, [bx]
    add     al, pernasa
    div     dl    ; Gauname AH - skaitmeni, AL - pernasa
    mov     [di], ah
    mov     pernasa, al
    inc     si
    inc     bx
    inc     di
    dec     cx
    cmp     cx, 0
    jne     sudedam_kita
    ; Sudejom visas skiltis, ir jei pernasa <> 0, turim perpildyma
    cmp     pernasa, 0
    jne     perpildymas
    ret
perpildymas:
    mov     ah, 09h
    mov     dx, OFFSET perpild_msg
    int     21h
    mov     ax, 4c00h
    int     21h
endp    

    end main
             