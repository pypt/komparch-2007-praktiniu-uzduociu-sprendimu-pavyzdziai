.model small
.stack
.code
   Mov ah,00h              ; á registrà AH áraðoma komanda, kuri nustato grafiná reþimà
   Mov al,13               ; á registrà AL nustatomas pats grafinis reþimas (ðiuo atveju 320x200)
   Int 10h                 ; ávykdomas grafinis pertraukimas

   Mov ah,0ch              ; á registrà AH áraðomas komandos kodas, kuris nurodo, jog bus “dedamas” taðkas 
   Mov al,01               ; á registrà AL nurodomas taðko spalvos kodà (ðiuo atveju raudonà)
   Mov cx,110              ; á CX registrà nustatoma taðko X koordinatë ekrane
   Mov dx,50               ; á DX registrà nustatoma taðko Y koordinatë ekrane
   Vert:                   ; pradedu ciklà, pieðiantá vertikalius keturkampio kraðtus
      Mov cx,110           ; nustatomos X koordinatës
      Int 10h              ; iððaukiamas petraukimas – padedamas taðkas
      Mov cx,210
      Int 10h
      Inc dx               ; didinama DX reikðmë – didinama y koordinatë
      Cmp dx,150           ; tikrinama ar baigti ciklà (DX didëja iki 150)
      Jng Vert             ; perðokama á eilutæ “Vert:” jei DX yra ne didesnis uþ 150
;---------------------
   Mov dx,50               ; atstatomos pradinës DX ir CX reikðmës
   Mov cx,110
;---------------------
   Horiz:                  ; analogiðkai pieðiamos horizontalios keturkampio linijos
      Mov dx,50            ; tik ðá kartà nustomos Y koordinatës i DX registrà
      Int 10h
      Mov dx,150
      Int 10h
      Inc cx               ; ir didinama CX reiðmë – X koordinatë
      Cmp cx,210
      Jng Horiz
;---------------------
   Mov dx,50               ; vëlgi atstatomos pradinës reikðmës
   Mov cx,110
;---------------------
   Tusuot:                 ; ciklas skirtas uþtuðuoti puse kvadrato
      Push cx              ; CX registro reikðmë pasidedama i steko virðûnæ
      Linija:              ; ciklas skirtas nubrëþti linijà 
         Inc cx            ; didinama CX reikðmë, kuri nurodo taðko X koordinatæ (formuojama linija)
         Int 10h
         Cmp cx,209        ; patikrinama ar taðko X koordinatë nedidesnë uþ 209
         Jng Linija        ; jei maþesnë – gryþtama i pociklio “Linija:” pradþià
      Inc dx               ; didinama DX reikðmë – Y koordinatë
      Pop cx               ; nuskaitoma CX reikðmë ið steko virðûnës
      Inc cx               ; padidinama CX reikðmë (tai reikalinga sukurti “ástriþainë”)
      Cmp dx,149           ; tikrinama ar dar nereikia baigti darbo – Y nedidesnis uþ 149
      Jng Tusuot           ; jei ne didesnis – tai gryþtama á ciklo “Tusuot:” pradþià
;---------------------
 
   Mov ah,00h              ; á AH registà nustatoma komanda skirta laukti klaviðo nuspaudimo
   Int 16h                 ; vykdomas klaviatûros pertraukimas
 
   Mov ah,00h              ; á AH registrà áraðoma komanda, kuri nustato grafiná reþimà
   Mov al,03               ; atstatomas normalaus texto reþimas
   Int 10h                 ; iððaukiamas pertraukimas
 
   Mov ah,4ch              ; nustatomas programos baigimo kodas
   Int 21h                 ; iððaukiamas DOS pertraukimas
End
