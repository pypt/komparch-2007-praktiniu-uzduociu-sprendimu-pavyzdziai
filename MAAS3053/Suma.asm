;****************************************************************************************
;*************************** Marius Asmonas, Programu Sistemu 4 gr.**********************
;****************************************************************************************

;Pasirinkto uzdavinio sprendimo ideja yra tokia. Paleides programa, vartotojas ivedineja
;skaitmeninius simbolius, kurie yra saugomi rezervuotoje atminties vietoje. Kiekvienam
;skaiciui yra skirta 255 baitu atminties sritis. Kadangi mane domina desimtainiai skait-
;menys, tai kitu simboliu ivesti neleidziu, o pirma ir antra demenis atskiriu vienu tar-
;pu, nepriklausomai nuo to, kiek vartotojas ju noretu prideti. Kai suvedami abu demenys ir
;paspaudziamas klavisas ENTER, pradedamas sumavimo procesas. Pirma, nustatau mazesniojo
;skaiciaus ilgi (tiek kartu bus atliekamas pradinis sumavimo ciklas). Po to, skatau nuo
;galo po viena skaitmenini simboli, verciu ji i skaitmeni ir sudedu su desimtaine bitu
;korekcijos komanda. Jei sudejus gaunamas dvizenklis skaicius, pirmas to skaiciaus skait-
;muo isimenamas ir sudedant kitus skaitmenis pridedamas prie ju sumos, o antras irasomas
;i rezultatui skirta atminties vieta. Kai ciklas ivykdomas, tikrinama, ar liko kazkas
;"mintyje". Jei taip, tai tas skaiciukas pridedamas prie likusiu didesniojo skaiciaus
;skaitmenu, kurie taip pat surasomi i rezultatui skirta atminties vieta. Jei pasiekiama
;leistina riba (t.y. 255 skaiciaus simbolis), o "mintyje" yra ne nulis, tai atspausdina-
;mas pranesimas apie perpildyma. Priesingu atveju, atspausdinama gauta suma.


.186

CR  EQU  00001101b
LF  EQU  00001010b
BS  EQU  00001000b

ClrScr  Macro  Col
          ;Set Possition at (0,0)
          Mov  Ah, 02h
          Mov  Al, 3
          Mov  Dh, 0h
          Mov  Dl, 0h
          Int  10h
          ;Clear All Screan
          Mov  Ah, 09h
          Mov  Al, ' '
          Mov  Bh, 0h
          Mov  Bl, &Col
          Mov  Cx, 2000
          Int  10h
       EndM
;-----------------------------------*
BackSpace  Macro
             Push Ax
             Push Dx
             Mov  Ah, 02h
	     Mov  Dl, BS
	     Int  21h
	     Mov  Ah, 02h
	     Mov  Dl, 20h
	     Int  21h
             Mov  Ah, 02h
             Mov  Dl, BS
             Int  21h
	     Pop  Dx
	     Pop  Ax
           EndM
;-----------------------------------*

CSeg Segment
     Assume Cs: CSeg, Ds: CSeg
     Org 100h

Start:
     Pusha                   ;issaugomi registrai
     ClrScr  07h             ;isvalomas ekranas
     Push Cs                 ;i registra Ds irasoma Cs reiksme 
     Pop  Ds
     Mov  Ah, 09h
     Lea  Dx, InPutMsg
     Int  21h                ;atspausdinama ekrane uzklausa
     Mov  Ah, 09h
     Lea  Dx, NewLine
     Int  21h                ;pereinama i kita eilute
     Lea  Si, Num1	     ;nustatoma pirmo demens atminties vietos poslinkio reiksme
     Lea  Di, Num2	     ;nustatoma antro demens atminties vietos poslinkio reiksme
     Lea  Bx, Rez	     ;nustatoma sumos atminties vietos poslinkio reiksme
     A1:
          Mov  Ah, 00h
          Int  16h           ;skaitomas simbolis is klaviaturos
	  Cmp  Al, 08h	     ;praleidziami tarpai ir kiti ne skaitmeniniai simboliai
          Jne  Temp1
	       Jmp DelChr2   ;jei paspaustas klavisas BACKSPACE eiti prie trynimo
          Temp1:
          Cmp  Al, 20h
          Je   A1
          Cmp  Al, '0'
          Jb   A1
          Cmp  Al, '9'
          Ja   A1
     Lea  Dx, Num1
     Cmp  Si, Dx
     Je   A2
	  Jmp  A3	     ;jei pirmas skaicius ivestas eiti prie antro sk. ivedimo
     A2:
          Mov  Ah, 02h
          Mov  Dl, Al
	  Int  21h			;atspausdinamas ivestas simbolis ekrane
	  Mov  Byte Ptr Ds:[Si], Al	;ir issaugomas jam skirtoje atminties vietoje
          Inc  Si                       ;pakoreguojamas indeksas
          Bad1:
               Mov  Ah, 00h
               Int  16h                 ;skaitomas kitas simbolis
	       Cmp  Al, 08h		;jei paspaustas klavisas BACKSPACE eiti prie trynimo
	       Je   DelChr1
               Cmp  Al, 20h
               Je   Next1
               Cmp  Al, '0'
               Jb   Bad1
               Cmp  Al, '9'
               Ja   Bad1
               Jmp  A2
     DelChr1:
         Lea  Dx, Num1
         Cmp  Si, Dx
         Jbe  Bad1
	      Dec  Si	      ;jei nepasiekta rezervuotos atminties vietos pradzia, trinti
	      BackSpace       ;ir atitinkamai pavaizduoti trinima ekrane
	      Jmp  Bad1
     Next1:
         Lea  Dx, Num1
         Cmp  Si, Dx
         Jbe   A1
              Mov  Ah, 02h   
              Mov  Dl, 20h
	      Int  21h	      ;jei ivestas pirmas skaicius, atspausdinti ekrane tarpa
              Jmp  A1
     A3:
         Mov  Ah, 02h
         Mov  Dl, Al
	 Int  21h		       ;atspausdinamas ivestas tinkamas simbolis
	 Mov  Byte Ptr Ds:[Di], Al     ;ir issaugojamas jam skirtoje atminties vietoje
         Inc  Di                       ;pakoreguojamas indeksas
         Bad2:
              Mov  Ah, 00h
              Int  16h                 ;skaitomas kitas simbolis
	      Cmp  Al, 08h	       ;jie paspaustas klavisas BACKSPACE, eiti prie trynimo
	      Je   DelChr2
              Cmp  Al, 0Dh
              Je   Next2
              Cmp  Al, '0'
              Jb   Bad2
              Cmp  Al, '9'
              Ja   Bad2
              Jmp  A3
     DelChr2:
         Lea  Dx, Num2
	 Cmp  Di, Dx
	 Ja   GoOn1
              Lea  Dx, Num1
              Cmp  Si, Dx
              Jbe  Bad1
                   BackSpace
                   Jmp  Bad1
	 GoOn1:
	 Dec  Di	      ;jei nepasiekta rezervuotos atminties vietos pradzia, trinti
	 BackSpace            ;ir atitinkamai pavaizduoti trynima ekrane
	 Jmp  Bad2
     Next2:
         Mov  Ah, 09h
         Lea  Dx, NewLine
         Int  21h
         Mov  Ah, 09h
         Lea  Dx, OutPutMsg
         Int  21h
         Mov  Ah, 09h
         Lea  Dx, NewLine
         Int  21h             ;Isvedamas i ekrana pranesimas
         Dec  Si
         Dec  Di              ;Pakoreguojami indeksai
         Push Bx              ;Issaugoma registro reiksme
         Mov  Ax, Si
         Lea  Bx, Num1
         Sub  Ax, Bx
	 Inc  Ax	      ;Apskaiciuojamas pirmos simboliu eilutes ilgis
         Mov  Dx, Di
         Lea  Bx, Num2
         Sub  Dx, Bx
	 Inc  Dx	      ;Apskaiciuojamas antros simboliu eilutes ilgis
         Pop  Bx              ;Atstatoma sena registro reiksme
         Cmp  Ax, Dx
         Jbe  B1
              Mov  Cx, Dx
              Jmp  B2
     B1:  
         Mov  Cx, Ax          ;Ciklo kintamasis igyja mazesni ilgi
     B2:  
         Xor  Dx, Dx
         Xor  Ax, Ax
     B3:  
         Cmp  Cx, 0
         Je   C1
              Push Cx                     ;Issaugomas ciklo kintamasis
	      Mov  Cl, Byte Ptr Ds:[Si]   ;Nuskaitomas is atminties pirmas simbolis
	      Sub  Cl, '0'		  ;Verciamas i desimtaini skaitmeni
              Mov  Al, Cl                 ;Issaugomas sudeciai
	      Mov  Cl, Byte Ptr Ds:[Di]   ;Nuskaitomas is atminties antras simbolis
	      Sub  Cl, '0'		  ;Verciamas i desimtaini skaitmeni
	      Add  Al, Cl		  ;Sudedamas su pirmu skaitmeniu
              Daa                         ;Pakoreguojama sudetis
	      Add  Ax, Dx		  ;Pridedamas ir skaicius "mintyje"
              Daa
	      Xor  Dx, Dx		  ;Paruosiamos registru reiksmes dalybai
              Mov  Cx, 10h
              Div  Cx                     ;Atliekama dalybos operacija
              Mov  Cx, Dx                 ;Issaugoma liekana
              Add  Cl, '0'                ;Liekana verciama i simboli
	      Mov  Byte Ptr Ds:[Bx], Cl   ;Issaugoma atitinkamoje atminties vietoje
	      Mov  Dx, Ax		  ;Issaugoma sveikoji dalis (t.y. "mintyje")
	      Pop  Cx			  ;Atstatoma ciklo kintamojo reiksme
              Dec  Si                     ;Pakoreguojami indeksai
              Dec  Di
              Dec  Cx
              Inc  Bx
              Jmp  B3
     C1:  
          Lea  Cx, Num1
          Cmp  Si, Cx
          Jae  C21
          Lea  Cx, Num2
          Cmp  Di, Cx
          Jae  C2
               Jmp  EndC
     C2:
          Mov  Si, Di
          Lea  Di, Num2
          Jmp  C3
     C21:
          Lea  Di, Num1 
     C3:
          Cmp  Dx, 0
	  Je   D1	      ;Baigti, jei skaicius "mintyje" nelygus nuliui
          Push Cx
          Mov  Cx, Di
          Cmp  Si, Cx
          Jae  Temp2
               Pop  Cx
               Jmp  D1
          Temp2:
          Pop  Cx
          Push Ax
          Push Cx
          Xor  Ax, Ax
          Mov  Al, Byte Ptr Ds:[Si]
          Sub  Al, '0'
          Add  Ax, Dx
          Daa
          Xor  Dx, Dx
          Mov  Cx, 10h
          Div  Cx
          Mov  Cx, Dx
          Add  Cl, '0'
          Mov  Byte Ptr Ds:[Bx], Cl
          Mov  Dx, Ax
          Pop  Cx
          Pop  Ax
          Dec  Si
          Inc  Bx
          Jmp  C3
     D1:
          Cmp  Si, Cx
          Jb   EndC
               Push Cx
               Mov  Cl, Byte Ptr Ds:[Si]
               Mov  Byte Ptr Ds:[Bx], Cl
               Pop  Cx
               Dec  Si
               Inc  Bx
               Jmp  D1
     EndC:
          Push Dx
          Dec  Bx
          Lea  Dx, Rez
          Mov  Cx, Bx
          Sub  Cx, Dx
          Inc  Cx
          Pop  Dx
          Cmp  Dx, 0
          Je   E2
              Cmp  Cx, 255
              Jb   DoIt
		   Mov	Ah, 09h    ;Klaida,jei simboliu eilute didesne nei 255 simboliai...
		   Lea	Dx, Error  ;...ir skaicius "mintyje" nelygus nuliui
                   Int  21h
                   Jmp  EndAll
              DoIt:
                   Inc  Bx
                   Add  Dl, '0'
		   Mov	Byte Ptr Ds:[Bx], Dl   ;Susitvarkyti supaskutiniu simboliu
                   Inc  Cx
     E2:  
          Cmp  Cx, 0
          Je   EndAll
               Mov  Ah, 02h
               Mov  Dl, Byte Ptr Ds:[Bx]
	       Int  21h 		       ;Atspausdinti rezultata ekrane
               Dec  Bx
               Dec  Cx
               Jmp  E2
     EndAll:
     Popa                         ;Atstatomos pradines registru reiksmes
     Ret

Num1  DB  255 Dup (?)
Num2  DB  255 Dup (?)
Rez   DB  255 Dup (?)
InPutMsg  DB  'Iveskite du skaicius:$'
OutPutMsg  DB  'Ivestu skaiciu suma lygi:$'
Error  DB  'Perpildymas$'
NewLine  DB  CR, LF, '$'


CSeg EndS
End  Start

