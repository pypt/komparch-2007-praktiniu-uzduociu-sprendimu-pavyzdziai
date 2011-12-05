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

CSeg  Segment 
        Assume Cs: CSeg, Ds: CSeg 
        Org     100h 

Start: 
      ClrScr  07h
      Mov  Ax, 0FFF0h
      Add  Ax, 10h


      ;Mov  Ax, 059Fh
      ;Mov  Dx, 1234h
      ;Call ShowOffset
      ;Mov  Ah, 02h
      ;Mov  Dl, 20h
      ;Int  21h
      ;Int  21h
      
      Mov  Ah, 00h
      Int  16h
      ;Push Cs
      ;Pop  Ds
      ;Lea  Si, FName 
      ;Mov  Ax, 0B800h 
      ;Mov  Es, Ax
      ;Mov  Di, 44*2+1*160
      ;Mov  Cx, 16
      ;Again:
      ;  Lodsb
      ;  Cmp  Al, 32
      ;  Jae  A1
      ;      Mov  Al, 20h
      ;  A1:
      ;  Stosb
      ;  Mov  Byte Ptr Es:[Di], 07h
      ;  Inc  Di
      ;Loop Again
      Ret

ShowOffset Proc
             ;Ax:Dx
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
               Ja   A1
                    Add  Dl, 30h
                    Jmp  A2
               A1:
               Add  Dl, 37h
               A2:
               Int  21h             
             Loop  OutPut
             Pop  Dx
             Mov  Ax, Dx
             Pop  Cx
             Loop  Again
             Ret
           EndP

 FName     DB     'fogy-4545A56:&6984689W74487Y765J/97'
 Clean     DB     27, '[2J', '$' 

 CSeg     EndS 
 End      Start 
