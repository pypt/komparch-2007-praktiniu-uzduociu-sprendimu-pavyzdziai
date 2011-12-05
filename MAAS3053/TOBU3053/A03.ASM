.Model small
.Stack
.Data
   Eilute1 db 'Iveskite eilute.',10,13,'$'
   NaujaL db 10,13,'Mazuju raidziu skaiciu: $'
   Duom db 255,?, 255 dup (?)
   K db ?
   Nulis db 0h
.Code
Skaicius Proc
   Cmp dl,0Ah
EndP
   Mov ax,@data
   Mov ds,ax
   Mov dx,offset Eilute1
   Mov ah,09h
   Int 21h
     
   
   Mov ah,0ah
   Mov dx,offset Duom
   Int 21h
   
   Mov si,dx
   Sub cx,cx
   Mov cl,[si+1]
   Inc si
   Mov al,0h
   
Kartoti:
   Inc si
   Mov bl,[si]
      
   Cmp bl,'a'
   Jl Toliau
   Cmp bl,'z'
   Jg Toliau
   Inc al
Toliau:
   Dec cx
   Cmp cx,0h
   Jnz Kartoti

; Isvedame skaiciu
   Push ax   
   Mov dx,offset NaujaL
   Mov ah,09h
   Int 21h
   Pop ax   

   Mov ah,0h
   Mov bl,10h
   Div bl
   Mov dx,ax

   Mov ah,02h
   Cmp al,0h
   Jng Toliau1
   Cmp dl,0Ah
   Jl TT1
   Add dl,07h
TT1:
   Add dl,30h
   Int 21h
Toliau1:
   Mov dl,dh
   Cmp dl,0Ah
   Jl TT2
   Add dl,07h
TT2:
   Add dl,30h
   Int 21h
   
   Mov ah,4ch
   Int 21h
End