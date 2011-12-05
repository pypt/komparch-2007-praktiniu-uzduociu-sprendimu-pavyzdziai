.Model small
.Stack 20
.Data
   FileName db 'textas.txt',0
   Infor db 'Programa nuskaito duomenis is bylos Textas.txt ir isveda pirmasias dvi eilutes.',10,13,'Tomas Bukenas, programu sistemu I kursas 2002 m.$'
   FileBuf db 160 dup (?)
   Bool db 00h
   K dw 0
.Code
   Mov ax,@data
   Mov ds,ax

   Mov ah,62h
   Int 21h
   Mov es,bx
   Mov di,81h
   Mov al,es:[di]
   Cmp al,' '
   Jne Toliau

   Mov al,es:[di+1]
   Cmp al,'-'
   Jne Toliau

   Mov al,es:[di+2]
   Cmp al,'h'
   Jne Toliau

   Mov ah,09h
   Mov dx,OffSet Infor
   Int 21h

   Mov ah,4ch
   Int 21h
   Toliau:

   Mov dx,Offset FileName ; nuskaito failo pavadinima aprasyta duomenu segmente
   Mov ah,03dh ; bylos atidarymo kodas
   Mov al,00h
   Int 21h

   Push ax
   Pop bx

   Mov ah,03fh
   Mov cx,160
   Mov dx,offset FileBuf
   Mov si,dx
   Int 21h
   
;------------------------------------------------------
   
   Mov K,ax
   Mov ah,02h
   Kartoti:
      Mov dl,[si]
      Cmp dl,13
      Jne T1
      Cmp Bool,01h
      Je CiklPab
      Cmp k,80
      Jng CiklPab
      Mov Bool,01h
      Cmp K,80
      Jng T1
      Mov K,80
   T1:
      Int 21h
      Inc si
      Dec K
      Cmp K,00h
   Jne Kartoti
   CiklPab:
;------------------------------------------------------   
   Mov ah,03eh ; bylos uzdarymo kodas siunciamas i AH registra
   Int 21h
;------------------------------------------------------
   Mov ah,4ch
   Int 21h
End