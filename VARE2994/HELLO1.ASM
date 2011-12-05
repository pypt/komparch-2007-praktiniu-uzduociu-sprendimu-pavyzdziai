   .MODEL small
   .STACK 100h
   .DATA
rastasMessage DB 'Parametras rastas',13,10,'$'
nerastasMessage DB 'Parametras nerastas',13,10,'$'
cikloMessage DB 'Radau raide!',13,10,'$'
   .CODE
   mov ax,@data
   mov ds,ax               
   cmp byte ptr es:[80h],0
   jz nerastas
   mov ah,9
   mov dx,OFFSET rastasMessage 
   int 21h

   mov cl, byte ptr es:[80h]
   dec cl
ciklas:
   mov ah,9                  
   mov dx, OFFSET cikloMessage
   int 21h      
   loop ciklas

   jmp galas

nerastas:
   mov ah,9                  
   mov dx,OFFSET nerastasMessage
   int 21h     
galas:
   mov ah,4ch     
   int 21h        
   END
