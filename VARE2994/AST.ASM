
.MODEL small
.STACK 100h
.DATA
 msgIvedimas DB 'Iveskite eilute:',13,10,'$'
 varMasyvas DW 32
.CODE
 mov ax,@data
 mov ds,ax

 mov dx, OFFSET msgIvedimas
 mov ah, 9
 int 21h

 mov dx, OFFSET varMasyvas
 mov ah, 0Ah
 int 21h

 mov ah, 2
 mov dl, 0Dh
 int 21h
 mov dl, 0Ah
 int 21h

 mov si, OFFSET varMasyvas
 inc si
 mov cl, byte ptr ds:[si]
 mov ch, 0
 
 mov bx, 1
ciklas:
 inc si
 mov al, byte ptr ds:[si]
 cmp al, ','
 jne nelygu
  inc bx
  mov ah, 2
  mov dl, 0Dh
  int 21h
  mov dl, 0Ah
  int 21h
  jmp galas
 nelygu:
  mov ah, 2
  mov dl, al
  int 21h
 galas:
loop ciklas 

 mov ah, 2
 mov dl, 0Dh
 int 21h
 mov dl, 0Ah
 int 21h

 mov cx, bx	;'uzkuriam' ciklo kintamaji
 mov bx, 0	;naudosime bx deshimtainiams skaiciams atvaizduoti

ciklas2:	;na cia gal ir ne pats gudriausias budas paversti hex i dec, bet visai nesunkus ir greitas
 inc bx		;prie musu deshimtainio skaiciaus pridedam vieneta
 cmp bl, 9	;ar nesigavo virsh 9?
 ja des1	;jei taip, tai kankinsimes toliau
 jmp enddes1	;jei ne - suksim cikla toliau
 des1:
  inc bh	;jei buvo 10, tai vieneta keliam vyresniajam skaitmeniui
  mov bl, 0	;o pati skaitmeni prilyginam nuliui
  cmp bh, 9	;kadangi nusiuntem 'dovanele' vyriasniam skaitmeniui, teks ir ji analogishkai patikrint
  ja des2
  jmp enddes1
  des2:	
   mov bh, 0   
 enddes1:
loop ciklas2

 mov ah, 2
 mov dl, bh
 add dl, 30h
 int 21h
 mov dl, bl
 add dl, 30h
 int 21h

 mov ah, 4ch     
 int 21h        
END