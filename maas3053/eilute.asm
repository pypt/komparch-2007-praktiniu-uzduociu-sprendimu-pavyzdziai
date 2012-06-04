CR  EQU  00001101b
LF  EQU  00001010b
BS  EQU  00001000b

DisplayStr  Macro  String
              Mov  Ah, 09h
              Lea  Dx, &String
              Int  21h
            EndM
;-----------------------------------*
DipslayChr  Macro  Character
              Mov  Ah, 02h
              Mov  Dl, &Character
              Int  21h
            EndM
;-----------------------------------*
DisplayNum  Macro  Number
              Mov  Ax, &Number
              Mov  Bx, 10h
              Xor  Cx, Cx
              Or   Ax, Ax
              Jnl  SkipNeg
                   Neg  Ax
                   Push Ax
                   Mov  Ah, 02h
                   Mov  Dl, '-'
                   Int  21h
                   Pop  Ax
               SkipNeg:
               Xor  Dx, Dx
               Div  Bx
               Push Dx
               Inc  Cx
               Or   Ax, Ax
               Jnz  SkipNeg
               BackWards:
               Or   Cx, Cx
               Je   Done
                    Pop  Dx
                    Cmp  Dl, 0Ah         
                    Je   One             
                    Cmp  Dl, 0Bh         
                    Je   One             
                    Cmp  Dl, 0Ch         
                    Je   One             
                    Cmp  Dl, 0Dh         
                    Je   One             
                    Cmp  Dl, 0Eh         
                    Je   One             
                    Cmp  Dl, 0Fh         
                    Je   One             
                    Add  Dl, 30h
                    Jmp  Two        
                    One:                 
                         Add  Dl, 37h
                    Two: 
                    Mov  Ah, 02h
                    Int  21h
                    Dec  Cx
                    Jmp  BackWards
               Done:
               Mov  Ah, 02h
               Mov  Dl, 'h'
               Int  21h
            EndM
;-----------------------------------*
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
          Mov  Cx, 4000
          Int  10h
       EndM
;-----------------------------------*
BackSpace  Macro
             Mov  Ah, 02h
             Mov  Dl, BS
             Int  21h
             Mov  Ah, 02h
             Mov  Dl, 20h
             Int  21h
             Mov  Ah, 02h
             Mov  Dl, BS
             Int  21h
           EndM

CSeg Segment
     Assume Cs: CSeg, Ds: CSeg
     Org 100h
Start:
     ClrScr  07h                     ;Isvalomas ekranas
     Mov  Ax, Cs
     Mov  Ds, Ax
     Mov  Es, Ax
     DisplayStr  InputMsg            ;Atspausdinamas pranesimas
     DisplayStr  NewLine             ;Pereinama i kita eilute
     BadChr1:
          Mov  Ah, 00h
          Int  16h                   ;Nuskaitomas paspausto klaviso kodas
     Cmp  Al, 20h                    
     Jne  Ok1
     Jmp  BadChr1
     Ok1:
     Cmp  Al, 08h
     Jne  Ok
          Jmp  BadChr1               ;Praleidziami tarpai ivedimo pradzioje
     Ok:
     Push Bx                         ;Issaugoma registro reiksme
     Lea  Bx, Buffer
     Again:
     Cmp  Al, 0Dh                    ;Jei klavisas ne ENTER, testi
     Jne  Part1
          Jmp  EndC
     Part1:
          Cmp  Al, 20h
          Jne  Ok3                   ;Atspausdinamas ir issaugojamas tarpas
               Cmp  Byte Ptr Es:[Bx - 1], 20h
               Je   BadChr1
               Cmp  Bx, offset Buffer
               Je   BadChr1
               Mov  Ah, 02h
               Mov  Dl, Al
               Int  21h
               Mov  Byte Ptr Es:[Bx], Al
               Inc  Bx
               BadChr2:
               Mov  Ah, 00h
               Int  16h
               Cmp  Al, 20h
               Jne  FinalTest
                    Jmp  BadChr2
               FinalTest:
               Cmp  Al, 08h
               Je   TryAgain2
          Cmp  Al, 0Dh
          Jne  Ok3
               Jmp  EndC
          Ok3:
          Mov  Ah, 02h
          Mov  Dl, Al
          Int  21h
          Mov  Byte Ptr Es:[Bx], Al  ;Atmintyje issaugomi ivedami simboliai
          Inc  Bx
          TryAgain2:
          Cmp  Al, 08h               ;Jei paspaustas klavisas BCKSPCE...
          Jne  GoOn2
               Cmp  Bx, offset Buffer
               Ja   GoOn1
                    Jmp  Part2
               GoOn1:
               Dec  Bx
               Push Ax
               Push Dx
               BackSpace
               Pop  Dx
               Pop  Ax
               Part2:
               Mov  Ah, 00h
               Int  16h
               Cmp  Al, 08h
               Jne  GetOut
               Jmp  TryAgain2
          GoOn2:
          Mov  Ah, 00h               
          Int  16h                   ;Nuskaitomas paspausto klaviso kodas
          Cmp  Al, 08h
          Je   TryAgain2
          GetOut:
          Cmp  Al, 0Dh
          Jne  Try2
                Jmp  FinalTest
          Try2:
          Jmp  Again                 
     EndC:
     Cmp  Byte Ptr Es:[Bx - 1], 20h
     Jne  Fin
          Dec  Bx
     Fin:
     DisplayStr  NewLine             ;Pereinama i kita eilute
     Push Dx                         ;Issaugoma registro reiksme
     Xor  Dx, Dx                     
     Push Si                         ;Issaugoma registro reiksme
     Lea  Si, MaxLength
     Mov  Word Ptr Ds:[Si], 0        ;Pradine ilgiausio zodzio reiksme
     Push Cx                         ;Issaugoma registro reiksme
     Mov  Cx, Bx
     Lea  Bx, Buffer
     NextW:
     Cmp  Bx, Cx
     Je   EndW
          Cmp  Byte Ptr Es:[Bx], 20h
          Je   Pass
               Inc  Dx
               Push Dx
               Mov  Dl, Byte Ptr Es:[Bx]  ;Zodziai spausdinami po viena simboli
               Mov  Ah, 02h
               Int  21h
               Pop  Dx
               Inc  Bx
               Jmp  NextW
          Pass:
          Cmp  Word Ptr Ds:[Si], Dx
          Jae  Denied
               Mov  Word Ptr Ds:[Si], Dx
          Denied:
          Xor  Dx, Dx
          Inc  Bx
          Push Dx
          DisplayStr  NewLine        ;Kiekvienas zodis vis naujoje eiluteje
          Pop  Dx
          Jmp  NextW
     EndW:
     Cmp  Word Ptr Ds:[Si], Dx
     Jae  FDenied
          Mov  Word Ptr Ds:[Si], Dx
     FDenied:
     Pop  Cx                         ;Atstatoma registro reiksme
     Mov  Dx, Word Ptr Ds:[Si]       
     Push Dx
     DisplayStr  NewLine             ;Pereinama i kita eilute
     DisplayStr  OutPutMsg           ;Atspausdinamas pranesimas
     Pop  Dx
     DisplayNum  Dx                  ;Isvedamas ilgiausio zodzio ilgis
     Pop  Si                         ;Atstatomos kitu registru reiksmes
     Pop  Dx
     Pop  Bx
     Ret

InPutMsg  DB  'Iveskite simboliu eilute:$'
OutPutMsg  DB  'Ilgiausio simboliu eilutes zodzio ilgis yra: $'
NewLine  DB  CR, LF, '$'
MaxLength  DW  ?
Buffer  DB  ?

CSeg EndS
End  Start
