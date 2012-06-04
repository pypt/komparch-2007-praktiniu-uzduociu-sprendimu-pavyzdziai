.Model Small

.Stack 1000

.Data

 Infor  DB "Paulius Kutkaitis (TM) | Programa, paprašanti vartotojo ivesti eilute, sudaryta iš žodžiu, atskirtu tarpais, tada ivesta eilute suskaidanti i žodžius, ir išspausdinanti ekrane rastus žodžius, kurie prasideda ‘a’, bei tokiu žodžiu kieki$"
 Prad DB "Iveskite Zhodzhiu Eilute : $"
 Prad2 DB "Zhodzhiai Ish 'a' raides: $"
 Info1 DB "Zhodis: '$"
 Info2 DB "' Ilgis: $"
 Info3 DB "Ish Viso Yra $"
 Info4 DB " Zhodzhiai Ish 'a' Raides$"
 Info5 DB "Nera Zhodzhiu Ish 'a' Raides$"
 NextE DB 0Dh,0Ah,"$"
 Eil DB 100,101 Dup(' ')
 Temp DB 40 Dup(0)
 Sk DB 3 Dup(' '),"$"
 CopyRight DB " /?"

.Code

 Main Proc
  Mov AX,@Data
  Mov DS,AX
;------------- Patikrina " /?"
  Call PSP
;------------- Parasho Texta "Iveskite...'
  Mov AH,09h
  Mov DX,OffSet Prad
  Int 21h
;------------- Nuskaito Yvesta Eilute
  Mov AH,0Ah
  Mov DX,OffSet Eil
  Int 21h
  Call WriteLn
;------------- Parasho Texta "Zhodzhiai..."
  Toliau:
   Mov AH,09h
   Mov DX,OffSet Prad2
   Int 21h
   Call WriteLn
;------------- Triname Tarpus
   Mov DI,OffSet Eil
   Mov CL,[DI+1]
   Add DI,2
   Tarpai:
    Cmp CL,0
    JE Viskas
    Mov AL,[DI]
    Cmp AL,' '
    JNE Zodis
    Dec CL
    Inc DI
    Cmp CL,0
    JA Tarpai
   Call Galas
;------------- Rastas Zhodis
   Zodis:
    Mov SI,OffSet Temp
    XOr AX,AX
    Formuok:
     Mov BL,[DI]
     Mov [SI],BL
     Inc DI
     Inc SI
     Inc AX
     Dec CL
     Cmp CL,0
     JE Ruosk
     Mov BL,[DI]
     Cmp BL,' '
     JNE Formuok
;------------- Suformuotas Zhodis Iki Galo
     Ruosk:
      Push DI
      XOr BX,BX
      Mov DI,OffSet Temp
      Mov BX,[DI]
      Mov BH,'a'
      Cmp BL,BH
      JE Write_Zodi
      Pop DI
      Jmp Tarpai
;------------- The End
   Call Galas
;------------- Atspausdina Rasta  Zhodi
   Write_Zodi:
    Inc CH
    Mov BL,'$'
    Mov [SI],BL
    Push SI
    Push CX
    Push DX
    Push AX
    Mov AH,09h
    Mov DX,OffSet Info1 ; "Zhodis..."
    Int 21h
    Mov DX,OffSet Temp ; Pats Zhodis
    Int 21h
    Mov DX,OffSet Info2 ; "Ilgis..."
    Int 21h
    Pop AX
    Call Skaicius
    Call WriteLn
    Pop DX
    Pop CX
    Pop SI
    Pop DI
    Jmp Tarpai
   Viskas:
    Call Galas
 EndP Main

 Skaicius Proc ; Atspausdina Skaichiu
  Push CX
  Mov SI,OffSet Sk
  Mov CX,3
  Mov DH,' '
  Trink:
   Mov [SI],DH
   Inc SI
   Loop Trink
  Dec SI
  Mov BH,0Ah
  Skaic:
   Div BH
   Add AH,'0'
   Mov [SI],AH
   Dec SI
   Mov AH,0
   Cmp AX,0
   JNZ Skaic
  Inc SI
  Mov AH,09h
  Mov DX,SI
  Int 21h
  Pop CX
  Ret
 EndP

 WriteLn Proc ; Perkelia Kursoriu Y Kita Eilute
  Mov AH,09h
  Mov DX,OffSet NextE
  Int 21h
  Ret
 EndP WriteLn

 Galas Proc
  XOr AX,AX
  Mov AL,CH
  Cmp AL,00h
  JNE Toliau2
  Mov AH,09h
  Mov DX,OffSet Info5
  Int 21h
  Call The_End
  Toliau2:
   Push AX
   Mov DX,OffSet Info3
   Mov AH,09h
   Int 21h
   Pop AX
   Call Skaicius
   Mov DX,OffSet Info4
   Mov AH,09h
   Int 21h
  Call The_End
 EndP Galas

 The_End Proc
  Mov AH,4Ch
  Int 21h
 EndP The_End

 PSP Proc
  Mov AH,62h
  Int 21h
  Mov ES,BX
  Mov DI,81h
  Mov AL,ES:[DI]
  Cmp AL,' '
  JNE Baik
  Mov AL,ES:[DI+1]
  Cmp AL,'/'
  JNE Baik
  Mov AL,ES:[DI+2]
  Cmp AL,'?'
  JNE Baik
  Mov AH,09h
  Mov DX,OffSet Infor
  Int 21h
  Call The_End
  Baik:Ret
 EndP PSP

End

