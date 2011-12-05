;*******************************************************************************************
;*********************** Marius Asmonas, Programu Sitemu 4 gr. *****************************
;*******************************************************************************************
;Pasirinkto uzdavinio sprendimo ideja yra tokia. Nuskaitau is komandines eilutes parametru
;skaiciu. Jei jis lygus nuliui, darbas baigiamas. Kitaip, nuskaitomi parametru simboliai i
;jiems skirta atminties vieta. tie simboliai turi sudaryti kokios nors egzistuojancios
;bylos varda. Ar byla ivesta teisingai ar ne patikrinu bylos atidarymo metu. Jei bylos
;atidarymo metu klaidos pozymio nebuvo, nuskaitau is jos 16 baitu. Jei nuskaityta 0 baitu,
;vadinasi, pasiekta bylos pabaiga. Priesingu atveju, atspausdinu ekrane poslinkio reiksme,
;nuskaitytu simboliu kodus (sesioliktaineje sistemoje) ir pacius simbolius. Tam tikslui
;pasirasiau atitinkamas proceduras.
;*******************************************************************************************


CR  EQU  00001101b
LF  EQU  00001010b
ParLen  EQU  80h
CmdLine  EQU  81h
ByteNum  EQU  10h

OpenF  Macro  FName
         Local EndCkl
         Mov  Ah, 3Dh
         Mov  Al, 02h
         Push Cs
         Pop  Ds
         Lea  Dx, &FName
         Int  21h
       EndM
;---------------------------------------*
CloseF  Macro FH
          Mov  Ah, 3Eh
          Mov  Bx, &FH
          Int  21h
        EndM
;---------------------------------------*
ReadFromF  Macro  FH, ByteNum, Buffer
             Mov  Ah, 3Fh
             Mov  Bx, &FH
             Mov  Cx, &ByteNum
             Push Cs
             Pop  Ds
             Lea  Dx, &Buffer
             Int  21h
           EndM
;---------------------------------------*
ClrScr  Macro  PageNum, Col
          ;Set Possition at (0,0)
          Mov  Ah, 02h
          Mov  Al, 3
          Mov  Dh, 0h
          Mov  Dl, 0h
          Int  10h
          ;Clear All Screan
          Mov  Ah, 09h
          Mov  Al, ' '
          Mov  Bh, &PageNum
          Mov  Bl, &Col
          Mov  Cx, 4000
          Int  10h
       EndM
;-----------------------------------*
GetCursorPos  Macro  PageNum, 
                Mov  Ah, 03h
                Mov  Bh, &PageNum
                Int  10h
              EndM
;-----------------------------------*
Press  Macro
         Mov  Ah, 00h
         Int  16h
       EndM
;-----------------------------------*

CSeg Segment
     Assume  Cs: CSeg, Ds: CSeg
     Org  100h

Start:
      Push Cs
      Pop  Ds                      ;suvienodinamos registru Cs ir Ds reiksmes
      Lea  Dx, FName               ;apskaiciuojama bylos vardo poslinkio reikme
      Mov  Si, Dx                  ;sutvarkomos pradines registru reiksmes                  
      Xor  Bx, Bx
      Xor  Cx, Cx
      Mov  Cl, Byte Ptr ParLen [Bx]    ;nuskaitomas komandines eilutes parametru ilgis

      Or   Cl, Cl
      Jnz  NextStep1
           Jmp  EndAll             ;jei param. nenurodyti, programos vykdymas nutraukiamas

      NextStep1:
      Cmp  Cl, 0Dh
      Jbe  NextStep2
           Jmp  EndAll             ;Jei buvo nurodyta >13 simboliu, darbas nutraukiamas

      NextStep2:
      Mov  Al, Byte Ptr CmdLine [Bx]   ;nuskaitomas parametru simbolis
      Cmp  Al, 20h
      Jne  MoveIt
           Inc  Bx                 ;jei tarpas, pakoreguojamas indeksinis rodiklis...
           Dec  Cx                 ;...ir nagrinejamu parametru skaicius
           Or   Cx, Cx
           Jne  NextStep2
                Jmp  EndAll                   ;jei jau isnagrineti visi param., darba baigti
 
      MoveIt:
           Or   Cl, Cl
           Jz   NextStep3
           Mov  Al, Byte Ptr CmdLine [Bx]     ;Nuskaitomas parametru simbolis

           Cmp  Al, '.'
           Jne  Pass1
                Mov  Ah, ArBuvo [0]           ;Atsizvelgiama i tasko simbolio pozicija
                Or   Ah, Ah
                Je   A1
                     Jmp  EndAll
                A1:
                     Mov  Ah, 1
                     Mov  Arbuvo [0], Ah
                     Jmp  Pass2
           Pass1:
           Cmp  Al, 'A'
           Jae  A2
                Jmp  EndAll
           A2:

           Cmp  Al, 'Z'
           Jbe   Pass2

           Cmp  Al, 'a'
           Jae  A3
                Jmp  EndAll
           A3:

           Cmp  Al, 'z'
           Jbe  Pass2
                Jmp  EndAll

           Pass2:                           ;jei simbolis yra tarp 'A'..'Z' arba 'a'..'z'...
           Mov  Byte Ptr Ds:[Si], Al        ;...irasyti ji i rezervuota atminties sriti
           Inc  Si                          ;pakoreguojamos registru reiksmes
           Inc  Bx
           Dec  Cx
           Jmp  MoveIt

      NextStep3:
      OpenF  FName, FH                      ;bandoma atidaryti parametru nurodyta byla
      Jnc  C
           Jmp  EndAll                      ;jei klaida, darbas nutraukiamas
      C:
      Mov  FH, Ax                           ;issaugomas bylos handle'as

      ClrScr  00h, 07h                      ;issvalomas ekranas

      Xor  Ax, Ax                           ;nustatoma pradine poslinkio reiksme: 00000000
      Mov  Dx, Ax
      NotTheEnd:
      Push Ax                               ;issaugoma poslinkio reiksme
      Push Dx

      ReadFromF  FH, ByteNum, Buffer        ;skaitoma is bylos po 16 baitu 

      Or   Ax, Ax
      Jnz  NoQuit
           Jmp  Quit                        ;jei perskaityta 0 b., pasiekta bylos pabaiga
      NoQuit:
      Mov  Di, Ax                           ;issaugomas nuskaitytu baitu skaicius
      Pop  Dx                               ;atstatoma issaugota poslinkio reiksme
      Pop  Ax
      Push Ax
      Push Dx

      Call ShowOffset                       ;ekrane pavaizduojamas poslinkis

      Mov  Ah, 02h                          ;poslinkis atskiriamas tarpu pora
      Mov  Dl, 20h
      Int  21h
      Int  21h

      Mov  Ax, Di
      Push Ax                               ;issaugomas nuskaitytu baitu skaicius
      Lea  Si, Buffer                       ;nustatoma nuskaitytu baitu buferio posl. reiksme
      Mov  Cx, Ax
      Xor  Ax, Ax
      Mov  Bx, 10h                          ;nustatoma daliklio reiksme

      Call DisplayNum                       ;pavaizduojami nuskaitytu baitu simboliu kodai

      Pop  Ax                               ;atstatomas issaugotas nuskaitytu baitu skaicius
      Mov  Cx, Ax
      Mov  Ah, 02h                          ;atspausdinamas tarpas
      Mov  Dl, 20h
      Int  21h
      Cmp  Cx, 10h
      Je   GoOn
           Push Ax                          ;jei buvo nuskaityta maziau nei 16 baitu...
           Push Cx                          ;...atitinkamai apskaiciuoti...
           Mov  Ax, 49                      ;...spausdinamu simboliu pozicija
           Inc  Ax
           Sub  Ax, Cx
           Add  Cx, Cx
           Sub  Ax, Cx
           Sub  Ax, 2
           Mov  Cx, Ax
           Mov  Ah, 02h
           Mov  Dl, 20h
           PutSpace:
             Int  21h                       ;atspausdinamas tarpas
           Loop  PutSpace
           Pop  Cx
           Pop  Ax
      GoOn:
      Lea  Si, Buffer

      Call DisplayChar                      ;pavaizduojami nuskaitytu baitu simboliai

      Mov  Ah, 09h                          ;pereinama i kita ekrano eilute
      Lea  Dx, NewLine
      Int  21h
      Pop  Dx                               ;atstatoma issaugoto poslinkio reiksme
      Pop  Ax
      Add  Dx, 10h                          ;pakoreguojama poslinkio reikme
      Jnc  NoError
           ClC                              ;jei kintama posl. reiksme netelpa registre Dx... 
           Xor  Dx, Dx                      ;...atitinkamai pakoreguoti registru reiksmes
           Inc  Ax
           Jmp  NotTheEnd
      NoError:

      Push Ax
      Push Dx
      GetCursorPos  00h                     ;Nuskaitoma zymeklio ekrane pozicija
      Cmp  Dh, 17h
      Je  TryAgain
           Pop  Dx
           Pop  Ax
           Jmp  NotTheEnd
      TryAgain:
      Pop  Dx
      Pop  Ax
      Push Ax
      Push Dx                               ;jei pasiekta ekrano pabaiga...
      Press                                 ;...laukiama klaviso paspaudimo
      ClrScr  00h, 07h                      ;isvalomas ekranas
      Pop  Dx
      Pop  Ax
      Jmp  NotTheEnd

      EndAll:      
           Mov  Ah, 09h                     ;pereinama i kita ekrano eilute
           Lea  Dx, NewLine
           Int  21h
           Lea  Dx, Error                   ;atspausdinamas klaidos pranesimas
           Int  21h
           Jmp  Finish
      Quit:
      Pop  Dx
      Pop  Ax

      CloseF  FH                            ;baigiamas darbas su aktyvia byla

      Press                                 ;laukiama klaviso paspaudimo
      ClrScr  00h, 07h                      ;isvalomas ekranas
      Mov  Ah, 09h                          ;atstspausdinamas darbo pabaigos pranesimas
      Lea  Dx, EndMessage
      Int  21h
      Press                                 ;laukiama klaviso paspaudimo
      ClrScr  00h, 07h                      ;isvalomas ekranas
      Finish:
      Ret

ShowOffset Proc
             ;poslinkio reiksme saugoma registru poroje Ax:Dx
             Mov  Cx, 02h
             Again:
             Push Cx
             Push Dx
             Mov  Bx, 10h
             Mov  Cx, 04h
             InPut:
               Xor  Dx, Dx
               Div  Bx
               Push Dx
             Loop  InPut
             Mov  Cx, 04h
             OutPut:
               Pop  Dx
               Mov  Ah, 02h
               Cmp  Dl, 9
               Ja   B1
                    Add  Dl, 30h
                    Jmp  B2
               B1:
               Add  Dl, 37h
               B2:
               Int  21h             
             Loop  OutPut
             Pop  Dx
             Mov  Ax, Dx
             Pop  Cx
             Loop  Again
             Ret
           EndP

DisplayNum  Proc
              ShowNum:
                Push Cx
                Mov  Cx, 02h
                Lodsb
                Cmp  Al, 32
                Jae  B
                     Mov  Al, 20h
                B:
                  Xor  Ah, Ah
                  Xor  Dx, Dx
                  Div  Bx
                  Push Dx
                Loop  B

                Mov  Cx, 02h
                PrintIt:
                  Pop  Dx
                  Cmp  Dl, 9
                  Ja   Change
                       Add  Dl, 30h
                       Jmp  NoChange
                  Change:
                  Add  Dl, 37h
                  NoChange:
                  Mov  Ah, 02h
                  Int  21h  
                Loop  PrintIt
        
                Mov  Ah, 02h
                Mov  Dl, 20h
                Int  21h
                Pop  Cx
              Loop  ShowNum
              Ret
            EndP

DisplayChar Proc
              ShowChar:
                Mov  Dl, Byte Ptr Ds:[Si]
                Cmp  Dl, 32
                Jae  A
                     Mov  Dl, 20h
                A:
                Int  21h
                Inc  Si
              Loop  ShowChar
              Ret
            EndP

ArBuvo  DB  0
FName  DB  16 Dup (?)
FH  DW  ?
NewLine  DB  CR, LF, '$'
Error  DB  'Ivyko Klaida!!!$'
EndMessage  DB  'Bylos Pabaiga!!! Ateikite Rytoj!!! Geros Dienos!!!$'
Buffer  DB  16  Dup (?)

CSeg  EndS
End   Start
