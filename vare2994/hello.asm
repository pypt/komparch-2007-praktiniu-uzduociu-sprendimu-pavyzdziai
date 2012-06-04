 .MODEL small
 .STACK 100h
 .DATA
 .CODE

 mov si, 81h
 mov ah, 02h
         
ciklas:
 mov al, byte ptr es:si
 mov dl, al
 int 21h

 inc si
 cmp al, 0dh
jne ciklas

 sub si, 81h
 dec si

 mov ah,4ch     
 int 21h        

END
